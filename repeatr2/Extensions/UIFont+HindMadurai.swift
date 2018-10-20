import UIKit

extension UIFont {
  class func hindMaduraiLight(ofSize size: CGFloat) -> UIFont {
    guard let font = UIFont(name: "HindMadurai-Light", size: size) else { fatalError("Couldn't load font") }
    return font
  }
  
  class func hindMaduraiRegular(ofSize size: CGFloat) -> UIFont {
    guard let font = UIFont(name: "HindMadurai-Regular", size: size) else { fatalError("Couldn't load font") }
    return font
  }
  
  class func hindMaduraiSemiBold(ofSize size: CGFloat) -> UIFont {
    guard let font = UIFont(name: "HindMadurai-SemiBold", size: size) else { fatalError("Couldn't load font") }
    return font
  }
  
  class func hindMaduraiBold(ofSize size: CGFloat) -> UIFont {
    guard let font = UIFont(name: "HindMadurai-Bold", size: size) else { fatalError("Couldn't load font") }
    return font
  }
}
