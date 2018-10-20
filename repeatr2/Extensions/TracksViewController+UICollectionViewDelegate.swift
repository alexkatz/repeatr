import UIKit

extension TracksViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) as? TrackCollectionViewCell {
      //      self.selectCell(cell)
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let yOffset = scrollView.contentOffset.y
    let topInset = view.safeAreaInsets.top
    currPulledDownRatio = (-yOffset - topInset) / (topInset + addTrackOffsetDelta)
    
    addTrackIndicatorView.snp.updateConstraints { make in
      make.height.equalTo(currPulledDownRatio > 0 ? -yOffset : 0)
    }
    
    addTrackIndicatorView.alpha = currPulledDownRatio
    createTrackLabel.alpha = currPulledDownRatio - 0.5
    
    if currPulledDownRatio >= 1 && prevPulledDownRatio < 1 {
      impactGenerator.impactOccurred()
      animator.addAnimations { self.createTrackLabel.transform = CGAffineTransform(scaleX: 1.25, y: 1.25) }
      animator.addAnimations({ self.createTrackLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) }, delayFactor: 0.2)
      animator.startAnimation()
    }
    
    prevPulledDownRatio = currPulledDownRatio
    
    view.layoutIfNeeded()
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if currPulledDownRatio >= 1 {
      createTrack()
    }
  }
}

