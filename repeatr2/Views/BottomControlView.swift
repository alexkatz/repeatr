import UIKit

class BottomControlView: UIView, Disablable {
  weak var track: Track?
  
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
    label.font = UIFont.hindMaduraiLight(ofSize: UIFont.Size.thirteen)
    label.textColor = UIColor.Theme.white
    label.textAlignment = .center
    addSubview(label)
    label.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(layoutMarginsGuide.snp.centerY)
    }
    
    enabled = false
  }
}
