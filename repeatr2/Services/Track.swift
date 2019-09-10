import Foundation
import AVFoundation

class Track: NSObject {
  let uuid = UUID().uuidString
  let noiseFloor: Float = -50.0
  let loopService = OldLooper.sharedInstance
  
  var isMuted = false
  
  var audioPlayer: AVAudioPlayer?
  var audioRecorder: AVAudioRecorder!
  var cursorTimer: Timer?
  var meterTimer: Timer?
  var loopPoints = [LoopPoint]()
  var internalLoopStartTime: UInt64? // used only if nothing is already looping, otherwise current loop time is taken from loopService
  var internalRecordStartTime: UInt64?
  var currentVolumeLevel: Float = 0
  
  var hasAudio: Bool {
    return self.audioPlayer != nil
  }
  
  var audioURL: URL? { return audioPlayer?.url }
  
  var isArmedForLoopRecord = false {
    didSet {
      if isArmedForLoopRecord != oldValue {
        loopRecordDelegate?.didChangeIsArmed(isArmedForLoopRecord)
        if isArmedForLoopRecord {
          NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Constants.notificationLoopRecordArmed), object: self))
        }
      }
    }
  }
  
  var isLoopRecording = false {
    didSet {
      if isLoopRecording != oldValue {
        DispatchQueue.main.async {
          self.loopRecordDelegate?.didChangeIsLoopRecording(self.isLoopRecording)
          self.moreView?.enabled = !self.isLoopRecording
        }
      }
    }
  }
  
  var isPlayingLoop = false {
    didSet {
      self.loopPlaybackDelegate?.isPlayingLoop = self.isPlayingLoop
    }
  }
  
  var loopExists = false {
    didSet {
      self.loopPlaybackDelegate?.loopExists = self.loopExists
    }
  }
  
  var loopStartTime: UInt64 {
    return self.internalLoopStartTime ?? self.loopService.currentLoopStartTime!
  }
  
  lazy var audioFileURL: URL = {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
    let documentsDirectory = paths[0]
    let audioFilePath = (documentsDirectory as NSString).appendingPathComponent("\(uuid).caf")
    return URL(fileURLWithPath: audioFilePath)
  }()
  
  var volumeLevel: Float {
    get { return audioPlayer?.volume ?? 0 }
    set { audioPlayer?.volume = newValue }
  }
  
  var muted = false {
    didSet {
      if muted {
        currentVolumeLevel = volumeLevel;
        volumeLevel = 0
      } else {
        volumeLevel = currentVolumeLevel
      }
    }
  }
  
  weak var recordDelegate: RecordDelegate?
  weak var playbackDelegate: PlaybackDelegate?
  weak var meterDelegate: MeterDelegate?
  weak var moreView: BottomControlView? // TODO: make a delegate for this? ...
  weak var loopRecordDelegate: LoopRecordDelegate?
  
  weak var loopPlaybackDelegate: LoopPlaybackDelegate? {
    didSet {
      loopPlaybackDelegate?.isPlayingLoop = isPlayingLoop
      loopPlaybackDelegate?.enabled = loopExists
    }
  }
  
  override init() {
    super.init()
    
    let recordSettings = [
      AVFormatIDKey: Int(kAudioFormatLinearPCM),
      AVSampleRateKey: NSNumber(value: 44100.0 as Float),
      AVNumberOfChannelsKey: NSNumber(value: 1 as Int32),
      AVLinearPCMBitDepthKey: NSNumber(value: 16 as Int32),
      AVLinearPCMIsBigEndianKey: NSNumber(value: false as Bool),
      AVLinearPCMIsFloatKey: NSNumber(value: false as Bool)
      ] as [String : Any]
    
    do {
      audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: recordSettings)
      audioRecorder.delegate = self
      audioRecorder.prepareToRecord()
      audioRecorder.isMeteringEnabled = true
    } catch let error as NSError {
      print("There was a problem setting play and record audio session category: \(error.localizedDescription)")
    }
  }
  
  func playAudioWithStartPercent(_ percent: Double) {
    guard let audioPlayer = audioPlayer else { return }
    let audioTime = audioPlayer.duration * percent
    
    if isArmedForLoopRecord && !isLoopRecording { // first sample marks downbeat of 1 in loop in this case
      startLoopRecord()
    }
    
    if isLoopRecording {
      loopPoints.append(LoopPoint(
        intervalFromStart: mach_absolute_time() - loopStartTime,
        audioTime: audioTime,
        audioPlayer: audioPlayer))
    }
    
    audioPlayer.currentTime = audioTime
    audioPlayer.play()
    startCursorTimer()
  }
  
  func stopAudio() {
    if audioRecorder.isRecording {
      audioRecorder.stop()
      recordDelegate?.isRecording = false
      meterTimer?.invalidate()
      meterTimer = nil
      meterDelegate?.dbLevel = nil
      moreView?.enabled = true
    } else if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
      if isLoopRecording {
        loopPoints.append(LoopPoint(
          intervalFromStart: mach_absolute_time() - loopStartTime,
          audioTime: nil,
          audioPlayer: audioPlayer))
      }
      
      audioPlayer.pause()
      cursorTimer?.invalidate()
      cursorTimer = nil
      playbackDelegate?.currentTime = nil
    }
  }
  
  func recordAudio() {
    guard !audioRecorder.isRecording else { return }
    
    clearLoop()
    audioRecorder.record()
    playbackDelegate?.audioURL = nil
    recordDelegate?.isRecording = true
    loopRecordDelegate?.enabled = false
    moreView?.enabled = false
    loopPlaybackDelegate?.loopExists = false
    
    if meterTimer == nil {
      let interval = 0.001
      meterTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
        self.audioRecorder.updateMeters()
        self.meterDelegate?.dbLevel = self.audioRecorder.averagePower(forChannel: 0)
      }
      meterTimer?.tolerance = interval * 0.1
      RunLoop.main.add(self.meterTimer!, forMode: RunLoop.Mode.common)
    }
  }
  
  func startLoopRecord() {
    clearLoop()
    isArmedForLoopRecord = false
    isLoopRecording = true
    loopService.currentlyRecordingTrackService = self
    
    let currentTime = mach_absolute_time()
    internalRecordStartTime = currentTime
    if loopService.currentLoopStartTime == nil { // this is the first recorded loop, making it the master track, begins with internal loopStartTime
      internalLoopStartTime = currentTime
    }
  }
  
  func finishLoopRecord() {
    if let audioPlayer = audioPlayer {
      loopPoints.append(LoopPoint(
        intervalFromStart: mach_absolute_time() - loopStartTime,
        audioTime: nil,
        audioPlayer: audioPlayer))
    }
    
    isLoopRecording = false
    loopExists = true
    addToLoopPlayback()
    loopService.currentlyRecordingTrackService = nil
  }
  
  func startCursorTimer() {
    if cursorTimer == nil {
      let interval = 0.001
      cursorTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
        if let audioPlayer = self.audioPlayer {
          self.playbackDelegate?.currentTime = audioPlayer.currentTime
        }
      }
      cursorTimer?.tolerance = interval * 0.1
      RunLoop.main.add(cursorTimer!, forMode: RunLoop.Mode.common)
    }
  }
  
  func updateRecordTime(currentTime: UInt64) {
    guard
      let internalRecordStartTime = internalRecordStartTime,
      let masterLoopLength = loopService.masterLoopLength
      else { return }
    
    let currentRecordTime = currentTime - internalRecordStartTime
    let distance =  currentRecordTime > masterLoopLength ? 0 : currentRecordTime.distance(to: masterLoopLength)
    let distanceThreshold = 10000
    
    if distance < distanceThreshold && isLoopRecording {
      isLoopRecording = false
      DispatchQueue.main.async {
        self.finishLoopRecord()
        NotificationCenter.default.post(
          Notification(
            name: Notification.Name(rawValue: Constants.notificationEndLoopRecord),
            object: self,
            userInfo: nil
          )
        )
      }
    }
  }
  
  func addToLoopPlayback() {
    isPlayingLoop = true
    startCursorTimer()
    
    loopService.addLoopPoints(loopPoints, trackService: self)
    
    if !loopService.isPlayingLoop {
      loopService.startLoopPlayback()
    }
  }
  
  
  func removeFromLoopPlayback() {
    if loopService.activeTrackServices.contains(self) {
      isPlayingLoop = false
      loopService.removeLoopPoints(loopPoints, trackService: self) // TODO: supply simply a track uuid, rename loop service's method to "remove track"
      cursorTimer?.invalidate()
      cursorTimer = nil
      playbackDelegate?.removeCursor()
    }
  }
  
  func clearLoop() {
    removeFromLoopPlayback()
    isLoopRecording = false
    loopPoints.removeAll()
  }
}


extension Track: AVAudioRecorderDelegate {
  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    guard flag else { return }
    playbackDelegate?.audioURL = recorder.url
    loopRecordDelegate?.enabled = true
    do {
      try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
      audioPlayer?.prepareToPlay()
    } catch let error as NSError {
      print("Error setting audio player URL: \(error.localizedDescription)")
    }
  }
}
