import UIKit

extension TracksViewController: LoopRecordViewDelegate {
  @objc func dismissActiveLoopRecord() {
    DispatchQueue.main.async {
      self.collectionView.isScrollEnabled = true
      self.armedCellY = nil
      UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 0.6,
        initialSpringVelocity: 0.3,
        options: .curveEaseInOut,
        animations: {
//          self.loopRecordCancelView.isHidden = true
//          UIView.animate(withDuration: 0.35) {
//            for constraint in self.loopRecordViewPassiveConstraints {
//              constraint.isActive = true
//            }
//            self.view.layoutIfNeeded()
//            self.collectionView.collectionViewLayout = TracksCollectionViewLayout(bounds: self.collectionView.bounds.size)
//            self.collectionView.contentOffset = self.currentCollectionViewOffset
//          }
      },
        completion: { finished in
          if finished {
            for cell in self.visibleCells {
              cell.track?.isArmedForLoopRecord = false
              cell.enabled = true
            }
          }
      })
    }
  }
}
