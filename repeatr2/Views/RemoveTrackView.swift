import UIKit

class RemoveTrackView : BottomControlView {
  var touch: UITouch?
  
  override func setup() {
    label.text = "REMOVE"
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    touch = touches.first
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if touch == touches.first, let touch = touch , bounds.contains(touch.location(in: self)) {
      if let track = track {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.notificationDestroyTrack), object: self, userInfo: [Constants.trackServiceUUIDKey: track.uuid])
      }
    }
  }
}
