import UIKit

class TrackCollectionViewCell: UICollectionViewCell {
  static let identifier = "TrackCollectionViewCell"
  
  var track: Track?
  
  func initialize() {
    contentView.backgroundColor = UIColor.orange
  }
}
