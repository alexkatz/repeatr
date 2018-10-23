import UIKit

// TODO: reimplement this
class LoopPlaybackView: BottomControlView, LoopPlaybackDelegate {
  let playingText = "PLAYING"
  let pausedText = "PAUSED"
  
  var touch: UITouch?
  
  weak var visualDelegate: PlaybackVisualDelegate?
  
  var isPlayingLoop = false {
    didSet {
      label.text = isPlayingLoop ? playingText : pausedText
      label.textColor = isPlayingLoop ? UIColor.Theme.green : UIColor.Theme.white
      visualDelegate?.playbackView(self, isPlayingLoop: isPlayingLoop)
    }
  }
  
  var loopExists = false {
    didSet {
      enabled = loopExists
      if !loopExists {
        label.text = pausedText
      }
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    touch = touches.first
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if touch == touches.first, let touch = touch , bounds.contains(touch.location(in: self)) {
      if let track = track, track.isPlayingLoop {
        track.removeFromLoopPlayback()
      } else {
        track?.addToLoopPlayback()
      }
      
      self.touch = nil
    }
  }
  
  override func setup() {
    super.setup()
    label.text = pausedText
    enabled = false
  }
  
}
