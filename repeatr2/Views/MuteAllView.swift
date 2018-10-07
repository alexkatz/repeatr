import UIKit

class MuteAllView: BottomControlView {
  let loopService = Looper.sharedInstance
  let muteAllText = "MUTE ALL"
  let unmuteAllText = "UNMUTE ALL"
  
  override func setup() {
    super.setup()
    label.text = muteAllText
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    loopService.setAllTracksMuted(!loopService.areAllTracksMuted)
    label.text = loopService.areAllTracksMuted ? unmuteAllText : muteAllText
  }
}
