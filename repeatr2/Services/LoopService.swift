import AVFoundation

class LoopService {
  static let sharedInstance = LoopService()
  
  let playbackQueue = OperationQueue()
  
  var loopPoints = [LoopPoint]()
  var audioPlayersPendingRemoval = [AVAudioPlayer]()
  var activeTrackServices = [TrackService]()
  var isPlayingLoop = false
  var currentLoopStartTime: UInt64?
  var areAllTracksMuted = false
  
  var hasLoopPoints: Bool {
    return loopPoints.count > 0
  }
  
  var masterLoopLength: UInt64? {
    return loopPoints.last?.intervalFromStart
  }

  weak var currentlyRecordingTrackService: TrackService?
  
  func addLoopPoints(_ loopPointsToAdd: [LoopPoint], trackService: TrackService) {
    loopPoints = (loopPoints + loopPointsToAdd).sorted { a, b in
      a.intervalFromStart < b.intervalFromStart
    }
    
    if !activeTrackServices.contains(trackService) {
      activeTrackServices.append(trackService)
    }
  }
  
  func removeLoopPoints(_ loopPointsToRemove: [LoopPoint], trackService: TrackService) {
    loopPoints = loopPoints.filter { loopPoint in
      for loopPointToRemove in loopPointsToRemove {
        if loopPointToRemove.uuid == loopPoint.uuid {
          return false
        }
      }
      return true
    }
    
    if let audioPlayer = loopPointsToRemove.first?.audioPlayer {
      audioPlayersPendingRemoval.append(audioPlayer)
    }
    
    if loopPoints.count == 0 {
      pauseLoopPlayback()
    }
    
    if let index = activeTrackServices.index(of: trackService) {
      activeTrackServices.remove(at: index)
    }
    
    print("removed loop points: \(loopPoints.count)")
  }
  
  // TODO: refactor this using guards or something, perhaps make it more concise
  func startLoopPlayback() {
    isPlayingLoop = true
    var loopPoints = self.loopPoints
    playbackQueue.addOperation {
      var i = 0
      self.audioPlayersPendingRemoval.removeAll()
      self.currentLoopStartTime = mach_absolute_time()
      repeat { // poll loopPoints array at the nanosecond level to find next loop start time
        if self.loopPoints.count == 0 { // if no loop points, immediately pause
          self.pauseLoopPlayback()
        } else if i < loopPoints.count { // iterate i through loop points
          self.currentlyRecordingTrackService?.updateRecordTime(currentTime: mach_absolute_time())
          let loopPoint = loopPoints[i]
          if let currentLoopStartTime = self.currentLoopStartTime { // get most recent current loop start time, as it will be updated with each iteration of our while loop
            let intervalFromStart = mach_absolute_time() - currentLoopStartTime // get interval from start for this iteration of the while loop
            if  intervalFromStart >= loopPoint.intervalFromStart { // as soon as interval from start is reached on the next loop in line, it's time to affect playback!
              if let audioTime = loopPoint.audioTime { // if nil, pause rather than play
                if self.audioPlayersPendingRemoval.index(of: loopPoint.audioPlayer) == nil { // if loop point is pending removal, ignore it
                  loopPoint.audioPlayer.currentTime = audioTime
                  loopPoint.audioPlayer.play()
                } else { // if loop point is pending removal, pause it whether it is playing audio or not
                  loopPoint.audioPlayer.pause()
                }
              } else {
                loopPoint.audioPlayer.pause()
              }
              i += 1
            } // if we haven't reached the next loop point's interval from start, it's a no-op, move on to the next iteration of the while loop
          } else {
            break
          }
        } else {
          i = 0
          loopPoints = self.loopPoints
          self.audioPlayersPendingRemoval.removeAll()
          self.currentLoopStartTime = mach_absolute_time()
        }
      } while (self.isPlayingLoop)
      for loopPoint in loopPoints {
        loopPoint.audioPlayer.pause()
      }
      self.currentLoopStartTime = nil
    }
  }
  
  func pauseLoopPlayback() {
    isPlayingLoop = false
  }
  
  func setAllTracksMuted(_ muted: Bool) {
    for trackService in activeTrackServices {
      trackService.isMuted = muted
    }
    
    areAllTracksMuted = muted
  }
}
