import UIKit

// TODO: reimplement this
class VolumeControlView: BottomControlView, UIGestureRecognizerDelegate {
  var activeTouch: UITouch?
  
  var filledView = UIView()
  var backgroundView = UIView()
  var panGestureRecognizer: UIPanGestureRecognizer!
  
  var fillColor: UIColor? {
    didSet {
      if let fillColor = fillColor {
        filledView.backgroundColor = fillColor
      }
    }
  }
  
  weak var delegate: AudioVolumeDelegate? {
    didSet {
      if let delegate = delegate {
        self.volumeLevel = delegate.volumeLevel ?? 0
      }
    }
  }
  
  var volumeLevel: Float = 1 {
    didSet {
      if volumeLevel > 1 {
        volumeLevel = 1
      } else if volumeLevel < 0 {
        volumeLevel = 0
      }
      setNeedsLayout()
    }
  }
  
  var centerLabelText: String? {
    didSet {
      label.text = centerLabelText
      label.isHidden = centerLabelText == nil
    }
  }
 
  override func layoutSubviews() {
    super.layoutSubviews()
    filledView.snp.updateConstraints { make in make.width.equalTo(bounds.width * CGFloat(volumeLevel)) }
  }
  
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if let pan = gestureRecognizer as? UIPanGestureRecognizer {
      let velocity = pan.velocity(in: self)
      return abs(velocity.x) > abs(velocity.y)
    }
    
    return false
  }
  
  override func willMove(toWindow newWindow: UIWindow?) {
    super.willMove(toWindow: newWindow)
    if newWindow == nil {
      removeGestureRecognizer(panGestureRecognizer)
    } else {
      addGestureRecognizer(panGestureRecognizer)
    }
  }
  
  @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
    let velocityInView = recognizer.velocity(in: self)
    volumeLevel += Float(velocityInView.x * 0.0001)
    delegate?.volumeLevel = volumeLevel
  }
  
  override func setup() {
    super.setup()
    backgroundView.removeFromSuperview()
    filledView.removeFromSuperview()
    
    addSubview(backgroundView)
    backgroundView.snp.makeConstraints { make in make.edges.equalToSuperview() }
    
    filledView.backgroundColor = UIColor.Theme.white.withAlphaComponent(Constants.dimmerAlpha)
    addSubview(filledView)
    filledView.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.left.equalToSuperview()
      make.height.equalTo(2)
      make.width.equalTo(0)
    }
    
    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(VolumeControlView.handlePan(_:)))
    panGestureRecognizer.delegate = self
    
    label.text = "TRACK VOLUME"
  }
  
}
