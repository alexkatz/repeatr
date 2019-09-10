// NOTE: waveform drawing influenced by: https://github.com/fulldecent/FDWaveformView

import UIKit
import AVFoundation

func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

class WaveformView: UIView, PlaybackDelegate, MeterDelegate {
  var totalSamples = 0
  var bookmarkViews = [BookmarkView]()
  var isPlacingBookmark = false
  var didInitialize = false
  var hasAudio = false
  var currentBounds: CGRect!
  var uncommittedBookmarkDelta: CGFloat = 0
  
  var waveColor = UIColor.white.withAlphaComponent(0.5)
  var bookmarkColor = UIColor.white.withAlphaComponent(0.5)
  var meterColor = UIColor.white.withAlphaComponent(0.5)
  
  var asset: AVURLAsset?
  var assetTrack: AVAssetTrack?
  var cursor: UIView?
  var activeTouch: UITouch?
  var uncommittedBookmarkView: BookmarkView?
  
  var track: Track {
    didSet {
      audioURL = track.audioURL
    }
  }
  
  lazy var plotImageView: UIImageView = {
    let plotImageView = UIImageView()
    plotImageView.alpha = 0
    insertSubview(plotImageView, at: 0)
    return plotImageView
  }()
  
  lazy var meterView: UIView = {
    let meterView = UIView()
    addSubview(meterView)
    meterView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.equalToSuperview()
      make.height.equalTo(0)
      
    }
    meterView.backgroundColor = meterColor
    return meterView
  }()
  
  lazy var bookmarkBaseView: UIView = {
    let bookmarkBaseView = UIView()
    addSubview(bookmarkBaseView)
    bookmarkBaseView.backgroundColor = bookmarkBaseColor
    bookmarkBaseView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview()
      make.width.equalToSuperview()
      make.height.equalToSuperview().multipliedBy(0.20)
    }
    return bookmarkBaseView
  }()
  
  lazy var label: UILabel = {
    let label = UILabel()
    label.textColor = UIColor.Theme.white
    label.font = UIFont.hindMaduraiRegular(ofSize: UIFont.Size.thirteen)
    label.textAlignment = .center
    label.numberOfLines = 2
    return label
  }()
  
  var audioURL: URL? {
    didSet {
      enabled = audioURL != nil
      
      guard let audioURL = audioURL else {
        clear()
        return
      }
      
      asset = AVURLAsset(url: audioURL)
      assetTrack =  asset?.tracks(withMediaType: AVMediaType.audio).first!
      
      let audioFormatDescriptionRef = assetTrack!.formatDescriptions[0] as! CMAudioFormatDescription
      let audioStreamBasicDescription = (CMAudioFormatDescriptionGetStreamBasicDescription(audioFormatDescriptionRef)?.pointee)! as AudioStreamBasicDescription
      totalSamples = Int(audioStreamBasicDescription.mSampleRate * (Double(asset!.duration.value) / Double(asset!.duration.timescale)))
      
      setNeedsLayout()
      drawWaveform()
      currentBounds = bounds
      
      UIView.animate(withDuration: Constants.defaultAnimationDuration, animations: {
        self.plotImageView.alpha = 1
        self.bookmarkBaseView.alpha = 1
      })
      
    }
  }
  
  var currentTime: TimeInterval? {
    didSet {
      guard let currentTime = currentTime else {
        removeCursor()
        return
      }
      
      if let asset = asset {
        setCursorPositionWithPercent(CGFloat(currentTime / asset.duration.seconds))
      }
    }
  }
  
  var dbLevel: Float? {
    didSet {
      guard let dbLevel = dbLevel else {
        meterView.alpha = 0
        return
      }
      
      hasAudio = true
      label.removeFromSuperview()
      meterView.alpha = 1
      let noiseFloor = 0 - track.noiseFloor
      let heightPercent = CGFloat((noiseFloor - abs(dbLevel)) / noiseFloor)
      meterView.snp.updateConstraints { make in make.height.equalTo(heightPercent > 0 ? bounds.height * heightPercent : 0) }
      setNeedsLayout()
    }
  }
  
  var cursorColor = UIColor.white.withAlphaComponent(0.5) {
    didSet {
      cursor?.backgroundColor = cursorColor
    }
  }
  
  var bookmarkBaseColor = UIColor.white.withAlphaComponent(0.5) {
    didSet {
      bookmarkBaseView.backgroundColor = bookmarkBaseColor
    }
  }
  
  var enabled = true {
    didSet {
      isUserInteractionEnabled = enabled
    }
  }
  
  var dimmed = false {
    didSet {
      alpha = enabled ? 1 : 0.5
      bookmarkBaseView.alpha = enabled && audioURL != nil ? 1 : 0
    }
  }
  
  // MARK: inits
  
  required init(track: Track) {
    self.track = track
    super.init(frame: CGRect.zero)
    
    isMultipleTouchEnabled = true
    
    cursor = UIView()
    cursor?.backgroundColor = cursorColor
    addSubview(cursor!)
    
    let introText = "Hold RECORD below to record some audio."
    let range = (introText as NSString).range(of: " RECORD ")
    let attributedString = NSMutableAttributedString(string: introText)
    attributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.Theme.red], range: range)
    label.attributedText = attributedString
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if bounds != currentBounds {
      drawWaveform()
      currentBounds = bounds
    }
    
    func addInfoLabel(_ label: UILabel) {
      addSubview(label)
      label.snp.makeConstraints { make in
        make.center.equalToSuperview()
        make.width.lessThanOrEqualToSuperview().offset(32)
      }
    }
    
    label.removeFromSuperview()
    label.alpha = 0
    
    if !didInitialize && !hasAudio {
      didInitialize = true
      addInfoLabel(label)
      label.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
      label.alpha = 1
      UIView.animate(withDuration: Constants.defaultAnimationDuration, animations: {
        self.label.transform = CGAffineTransform(scaleX: 1, y: 1)
      })
    } else if !hasAudio {
      addInfoLabel(label)
      label.alpha = 1
    }
    
    for bookmarkView in bookmarkViews {
      if let percentX = bookmarkView.percentX {
        bookmarkView.frame = CGRect(
          x: (bounds.width * percentX) - (Constants.bookmarkViewWidth / 2),
          y: 0,
          width: Constants.bookmarkViewWidth,
          height: bounds.height)
      }
    }
  }
  
  override func willMove(toSuperview newSuperview: UIView?) {
    if newSuperview != nil {
      addGestureRecognizer(WaveformGestureRecognizer(waveformView: self))
    } else {
      gestureRecognizers?.removeAll()
    }
  }
  
  // MARK: Methods

  func touchesBegan(_ touches: Set<UITouch>) {
    if touches.count == 1 {
      activeTouch = touches.first
    } else {
      activeTouch = touches.max { a, b -> Bool in
        a.timestamp > b.timestamp
      }
    }
    
    NotificationCenter.default.post(
      Notification(
        name: Notification.Name(rawValue: Constants.notificationTrackSelected),
        object: self,
        userInfo: [Constants.trackServiceUUIDKey: track.uuid]
      )
    )
    
    if let location = activeTouch?.location(in: self) {
      if bookmarkBaseView.frame.contains(location) && audioURL != nil {
        bookmarkBaseView.backgroundColor = bookmarkBaseColor
        if let bookmarkView = bookmarkViews.filter({ $0.frame.contains(location) }).first {
          uncommittedBookmarkView = bookmarkView
        } else {
          let bookmarkView = createBookmarkAtLocation(location)
          uncommittedBookmarkView = bookmarkView
        }
      } else if !track.isPlayingLoop {
        if bookmarkViews.count == 0 {
          let percent = Double(location.x / bounds.width)
          track.playAudioWithStartPercent(percent)
        } else {
          let currentPercent = CGFloat(location.x / bounds.width)
          if let bookmarkView = bookmarkViews.filter({ $0.percentX < currentPercent }).last, let startPercent = bookmarkView.percentX {
            track.playAudioWithStartPercent(Double(startPercent))
          } else {
            track.playAudioWithStartPercent(0)
          }
        }
      }
    }
  }
  
  func touchesMoved(_ touches: Set<UITouch>) {
    if touches.filter({ $0 == activeTouch }).count == 0 {
      return
    }
    
    if let uncommittedBookmarkView = uncommittedBookmarkView {
      if let location = touches.first?.location(in: self), let previousLocation = touches.first?.previousLocation(in: self) {
        let deltaX = location.x - previousLocation.x
        uncommittedBookmarkDelta += abs(location.x - previousLocation.x)
        uncommittedBookmarkView.center = CGPoint(x: uncommittedBookmarkView.center.x + deltaX, y: uncommittedBookmarkView.center.y)
      }
    }
  }
  
  func touchesEnded(_ touches: Set<UITouch>) {
    if activeTouch != nil && touches.contains(self.activeTouch!) {
      if !track.isPlayingLoop {
        track.stopAudio()
      }
      
      activeTouch = nil
      
      if let uncommittedBookmarkView = uncommittedBookmarkView {
        if !isPlacingBookmark && uncommittedBookmarkDelta < 1 {
          uncommittedBookmarkView.isUserInteractionEnabled = false
          UIView.animate(withDuration: Constants.defaultAnimationDuration, delay: 0, options: [.beginFromCurrentState], animations: {
            uncommittedBookmarkView.alpha = 0
          }, completion: { finished in
            uncommittedBookmarkView.removeFromSuperview()
          })
          
          if let index = bookmarkViews.firstIndex(of: uncommittedBookmarkView) {
            bookmarkViews.remove(at: index)
          }
        }
        
        bookmarkViews.sort { a, b in
          a.percentX < b.percentX
        }
        
        self.uncommittedBookmarkView = nil
        isPlacingBookmark = false
        uncommittedBookmarkDelta = 0
      }
    }
  }
  
  func createBookmarkAtLocation(_ location: CGPoint) -> BookmarkView {
    let bookmarkView = BookmarkView(
      frame: CGRect(
        x: location.x - (Constants.bookmarkViewWidth / 2),
        y: 0,
        width: Constants.bookmarkViewWidth,
        height: bounds.height))
    bookmarkView.color = bookmarkColor
    bookmarkViews.append(bookmarkView)
    addSubview(bookmarkView)
    isPlacingBookmark = true
    return bookmarkView
  }
  
  func setCursorPositionWithPercent(_ percent: CGFloat) {
    if cursor?.alpha == 0 {
      cursor?.alpha = 1
    }
    
    cursor?.frame = CGRect(x: bounds.width * percent, y: 0, width: 2, height: bounds.height)
  }
  
  func removeCursor() {
    cursor?.alpha = 0
  }
  
  func clear() {
    plotImageView.alpha = 0
    
    for bookmarkView in bookmarkViews {
      bookmarkView.removeFromSuperview()
    }
    
    bookmarkViews.removeAll()
    
    plotImageView.alpha = 0
    bookmarkBaseView.alpha = 0
    asset = nil
    assetTrack = nil
  }

  func drawWaveform() {
    let widthPixels = Int(frame.width * UIScreen.main.scale)
    let heightPixels = Int(frame.height * UIScreen.main.scale)
    
    downsampleAssetForWidth(widthPixels) { samples, maxSample in
      if let samples = samples, let maxSample = maxSample {
        self.plotWithSamples(samples, maxSample: maxSample, imageHeight: heightPixels) { image in
          self.plotImageView.frame = self.bounds
          self.plotImageView.image = image
        }
      }
    }
  }
  
  func plotWithSamples(_ samples: Data, maxSample: Float, imageHeight: Int, done: ((UIImage?) -> ())?) {
    let s = (samples as NSData).bytes.bindMemory(to: Float.self, capacity: samples.count)
    let sampleCount = samples.count / 4
    let imageSize = CGSize(width: sampleCount, height: imageHeight)
    UIGraphicsBeginImageContext(imageSize)
    let context = UIGraphicsGetCurrentContext()
    
    context?.setShouldAntialias(false)
    context?.setAlpha(1)
    context?.setLineWidth(1)
    context?.setStrokeColor(waveColor.cgColor)
    
    let sampleAdjustmentFactor = Float(imageHeight) / (maxSample - track.noiseFloor) / 2
    let halfImageHeight = Float(imageHeight) / 2
    
    for i in 0..<sampleCount {
      let sample: Float = s[i]
      var pixels = (sample - track.noiseFloor) * sampleAdjustmentFactor
      if pixels == 0 {
        pixels = 1
      }
      
      context?.move(to: CGPoint(x: CGFloat(i), y: CGFloat(halfImageHeight - pixels)))
      context?.addLine(to: CGPoint(x: CGFloat(i), y: CGFloat(halfImageHeight + pixels)))
      context?.strokePath()
    }
    
    done?(UIGraphicsGetImageFromCurrentImageContext())
  }
  
  func downsampleAssetForWidth(_ widthInPixels: Int, done: ((Data?, Float?) -> ())?) {
    if let asset = asset, let assetTrack = assetTrack , totalSamples > 0 && widthInPixels > 0 {
      do {
        let reader = try AVAssetReader(asset: asset)
        reader.timeRange = CMTimeRangeMake(start: CMTime(seconds: 0, preferredTimescale: asset.duration.timescale), duration: CMTime(seconds: Double(self.totalSamples), preferredTimescale: asset.duration.timescale))
        
        let outputSettings: [String: AnyObject] = [
          AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM as UInt32),
          AVLinearPCMBitDepthKey: 16 as AnyObject,
          AVLinearPCMIsBigEndianKey: false as AnyObject,
          AVLinearPCMIsFloatKey: false as AnyObject,
          AVLinearPCMIsNonInterleaved: false as AnyObject]
        let output = AVAssetReaderTrackOutput(track: assetTrack, outputSettings: outputSettings)
        output.alwaysCopiesSampleData = false
        reader.add(output)
        
        let bytesPerInputSample = 2
        var sampleMax = track.noiseFloor
        var tally = Float(0)
        var tallyCount = Float(0)
        let downsampleFactor = Int(totalSamples / widthInPixels)
        let fullAudioData = NSMutableData(capacity: Int(asset.duration.value / Int64(downsampleFactor)) * 2)!
        
        reader.startReading()
        
        while reader.status == .reading {
          let trackOutput = reader.outputs[0] as! AVAssetReaderTrackOutput
          if let sampleBufferRef = trackOutput.copyNextSampleBuffer(), let blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef) {
            let bufferLength = CMBlockBufferGetDataLength(blockBufferRef)
            if let data = malloc(bufferLength) {
              CMBlockBufferCopyDataBytes(blockBufferRef, atOffset: 0, dataLength: bufferLength, destination: data)
              
              let samples = data.assumingMemoryBound(to: Int16.self)
              let sampleCount = bufferLength / bytesPerInputSample
              
              for i in 0..<sampleCount {
                let rawData = Float(samples[i])
                var sample = minMaxOrValue(decibel(rawData), min: Float(track.noiseFloor), max: 0)
                tally += sample
                tallyCount += 1
                
                if Int(tallyCount) == downsampleFactor {
                  sample = tally/tallyCount
                  sampleMax = sampleMax > sample ? sampleMax : sample
                  fullAudioData.append(&sample, length: MemoryLayout.size(ofValue: sample))
                  tally = 0
                  tallyCount = 0
                }
                CMSampleBufferInvalidate(sampleBufferRef);
              }
            }
          }
        }
        
        if reader.status == .completed {
          done?(fullAudioData as Data, sampleMax)
        }
      } catch let error as NSError {
        print("There was a problem downsampling the asset: \(error.localizedDescription)")
      }
    } else {
      done?(nil, nil)
    }
  }

  func decibel(_ amplitude: Float) -> Float {
    return 20.0 * log10(abs(amplitude)/32767.0)
  }
  
  func minMaxOrValue(_ x: Float, min: Float, max: Float) -> Float {
    return x <= min ? min : (x >= max ? max : x)
  }
}

















