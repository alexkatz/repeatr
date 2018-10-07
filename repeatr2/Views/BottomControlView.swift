import UIKit

class BottomControlView: UIView, Disablable {
  var trackService: Track?
  
  var enabled = false {
    didSet {
      alpha = enabled ? 1 : Constants.dimAlpha
      isUserInteractionEnabled = enabled
    }
  }
  
  var label = UILabel()

  convenience init(bottomMargin: CGFloat = 0) {
    self.init(frame: CGRect.zero)
    layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: bottomMargin, right: 0)
    isMultipleTouchEnabled = false
    setup()
  }

  func setup() {
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.hindMaduraiLight(ofSize: UIFont.Size.thirteen)
    label.textColor = UIColor.Theme.white
    label.textAlignment = .center
    addSubview(label)
    label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor).isActive = true
    enabled = false
  }
}
