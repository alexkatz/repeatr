import UIKit

class WaveformCollectionViewLayout: UICollectionViewLayout {
  var layoutAttributes = [UICollectionViewLayoutAttributes]()
  var bounds: CGSize!
  
  required convenience init(bounds: CGSize) {
    self.init()
    self.bounds = bounds
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return layoutAttributes.filter { layoutAttributes in
      rect.intersects(layoutAttributes.frame)
    }
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    let filteredLayoutAttributes = layoutAttributes.filter { $0.indexPath.item == indexPath.item }
    return filteredLayoutAttributes.first
  }
  
  override var collectionViewContentSize : CGSize {
    if let cellCount = collectionView?.numberOfItems(inSection: 0) {
      let height = bounds.height
      let width = bounds.width * CGFloat(cellCount)
      return CGSize(width: width, height: height)
    }
    
    return CGSize.zero
  }
  
  override func prepare() {
    if let cellCount = collectionView?.numberOfItems(inSection: 0) {
      for i in 0..<cellCount {
        let indexPath = IndexPath(item: i, section: 0)
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let cellSize = bounds
        let x = (cellSize?.width)! * CGFloat(i)
        let y = CGFloat(0)
        
        layoutAttributes.frame = CGRect(
          origin: CGPoint(
            x: x,
            y: y),
          size: cellSize!)
        
        self.layoutAttributes.append(layoutAttributes)
      }
    }
  }
}
