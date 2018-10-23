import UIKit
import UIKit.UIGestureRecognizerSubclass

class WaveformGestureRecognizer: UIGestureRecognizer {
  weak var waveformView: WaveformView?
  
  init(waveformView: WaveformView) {
    self.waveformView = waveformView
    super.init(target: nil, action: nil)
    delaysTouchesEnded = false
    delaysTouchesBegan = false
  }
  
  override func reset() {
    super.reset()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesBegan(touches, with: event)
    waveformView?.touchesBegan(touches)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesMoved(touches, with: event)
    waveformView?.touchesMoved(touches)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesEnded(touches, with: event)
    waveformView?.touchesEnded(touches)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesCancelled(touches, with: event)
  }
  
  override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
    return false
  }
}
