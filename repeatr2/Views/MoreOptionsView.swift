import UIKit

class MoreOptionsView: BottomControlView, MoreOptionsDelegate {
  weak var trackSelectorDelegate: TrackSelectorDelegate?
  
  override func setup() {
    super.setup()
    label.text = "MORE"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    trackSelectorDelegate?.toggleTrackEditMode()
  }
}
