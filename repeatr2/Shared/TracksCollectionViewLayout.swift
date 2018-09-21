import UIKit

class TracksCollectionViewLayout: UICollectionViewLayout {
  let cellBottomBorder = CGFloat(2)
  
  var layoutAttributes = [UICollectionViewLayoutAttributes]()
  var bounds: CGSize!
  
  required init(bounds: CGSize) {
    super.init()
    self.bounds = bounds
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return layoutAttributes.filter { rect.intersects($0.frame) }
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    let filteredLayoutAttributes = layoutAttributes.filter{ $0.indexPath.item == indexPath.item }
    return filteredLayoutAttributes.first
  }
  
  override var collectionViewContentSize : CGSize {
    if let cellCount = collectionView?.numberOfItems(inSection: 0) {
      let width = bounds.width
      let height = (CGFloat(cellCount) * Constants.cellHeight) + (CGFloat(cellCount) * cellBottomBorder)
      return CGSize(width: width, height: height)
    }
    
    return CGSize.zero
  }
  
  override func prepare() {
    if let cellCount = collectionView?.numberOfItems(inSection: 0) {
      layoutAttributes.removeAll()
      for i in 0..<cellCount {
        let indexPath = IndexPath(item: i, section: 0)
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        let cellSize = CGSize(width: bounds.width, height: Constants.cellHeight)
        let x = CGFloat(0)
        let y = cellSize.height * CGFloat(i) + (cellBottomBorder * CGFloat(i))

        attributes.frame = CGRect(
          origin: CGPoint(
            x: x,
            y: y),
          size: cellSize)
        
        layoutAttributes.append(attributes)
      }
    }
  }
  
}
