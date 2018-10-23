import UIKit

class MuteAllView: BottomControlView {
  let loopService = OldLooper.sharedInstance
  let muteAllText = "MUTE ALL"
  let unmuteAllText = "UNMUTE ALL"
  
  override func setup() {
    super.setup()
    label.text = muteAllText
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    loopService.areAllTracksMuted = !loopService.areAllTracksMuted
    label.text = loopService.areAllTracksMuted ? unmuteAllText : muteAllText
  }
}
