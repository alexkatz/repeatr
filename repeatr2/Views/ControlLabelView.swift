import UIKit

class ControlLabelView: UIView, Disablable {
  
//  var trackService: TrackService?
  
  var enabled = false {
    didSet {
      self.alpha = self.enabled ? 1 : Constants.dimAlpha
      self.isUserInteractionEnabled = self.enabled
    }
  }
  
  lazy var label: UILabel = { [unowned self] in
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = Constants.font
    label.textColor = UIColor.white
    label.textAlignment = .center
    self.addSubview(label)
    label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    return label
    }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup()
  }
  
  func setup() {
    
  }
  
}
