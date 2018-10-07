import UIKit

extension TracksViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) as? TrackCollectionViewCell {
      //      self.selectCell(cell)
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let yOffset = scrollView.contentOffset.y
    if yOffset < 0 {
      // center the text or whatever here, transform it with spring animation or something funky and kewl dawg
    }
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    
    if scrollView.contentOffset.y < -100 {
      shouldAddTrackOnDidEndDecelerating = true
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if shouldAddTrackOnDidEndDecelerating {
      createTrack()
      shouldAddTrackOnDidEndDecelerating = false
    }
  }
}

