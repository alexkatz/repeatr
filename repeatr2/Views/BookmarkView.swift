import UIKit

class BookmarkView: UIView {
  var cursorView: UIView!
  var percentX: CGFloat?
  
  var color = UIColor.white {
    didSet {
      cursorView.backgroundColor = color
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addCursorView()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if let superview = superview {
      percentX = center.x / superview.bounds.width
    }
  }
  
  convenience init() {
    self.init(frame: CGRect.zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    addCursorView()
  }
  
  func addCursorView() {
    cursorView = UIView()
    cursorView.backgroundColor = color
    addSubview(cursorView)
    cursorView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.equalTo(2)
      make.height.equalToSuperview()
    }
  }
}
