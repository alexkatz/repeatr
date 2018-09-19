import UIKit

class Constants {
  static let greenColor = UIColor(red: 0.0/255.0, green: 200.0/255.0, blue: 0.0/255.0, alpha: 1)
  static let redColor = UIColor(red: 214.0/255.0, green: 40.0/255.0, blue: 91.0/255.0, alpha: 1)
  static let darkerRedColor = UIColor(red: 194.0/255.0, green: 20.0/255.0, blue: 71.0/255.0, alpha: 1)
  static let whiteColor = UIColor.white
  static let blackColor = UIColor.black
  static let blackSelectedColor = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1)
  
  static let dimAlpha = CGFloat(0.6)
  static let dimmerAlpha = CGFloat(0.3)
  
  static let recordButtonHeight = CGFloat(44)
  
  static let cellHeight = CGFloat(44 * 4)
  
  static let defaultAnimationDuration = 0.40
  
  static let bookmarkViewWidth = CGFloat(44)

  static let font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.ultraLight)
  
  static let notificationTrackSelected = "notificationTrackSelected"
  static let notificationLoopRecordArmed = "notificationLoopArmed"
  static let notificationEndLoopRecord = "notificationEndLoopRecord"
  static let notificationDestroyTrack = "notificationDestroyTrack"
  
  static let trackServiceUUIDKey = "trackServiceUUIDKey"
}
