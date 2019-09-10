import UIKit
import SnapKit
import AVFoundation

class TracksViewController: UIViewController, TrackSelectorDelegate {
  let addTrackOffsetDelta: CGFloat = 100
  let impactGenerator = UIImpactFeedbackGenerator()
  
  var editingTracks = false
  
  var prevPulledDownRatio: CGFloat = 0
  var currPulledDownRatio: CGFloat = 0
  
  var animator: UIViewPropertyAnimator!
  var collectionView: UICollectionView!
  var welcomeLabel: UILabel!
  var createTrackLabel: UILabel!
  var bottomContainerView: UIView!
  var recordView: RecordView!
  var loopRecordView: LoopRecordView!
  var muteAllView: MuteAllView!
  var moreView: MoreOptionsView!
  var addTrackIndicatorView: UIView!
  
  var tracks = [Track]()
  var selectedTrack: Track?
  
  var visibleCells: [TrackCollectionViewCell] {
    return collectionView.visibleCells.map({ cell in cell as! TrackCollectionViewCell })
  }
  
  override var prefersStatusBarHidden: Bool { return true }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let errorMessage = "Couldn't start audio session. Try closing and relaunching the app!"
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(AVAudioSession.Category(rawValue: AVAudioSession.Category.playAndRecord.rawValue), mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
      try audioSession.setPreferredIOBufferDuration(0.001)
      try audioSession.setActive(true)
    } catch AudioError.AudioEngineError {
      handleError(errorMessage: errorMessage)
    } catch let error as NSError {
      handleError(errorMessage: errorMessage, description: error.localizedDescription)
    }
    
    let timingParameters = UISpringTimingParameters(dampingRatio: 0.18, initialVelocity: CGVector(dx: 10, dy: 10))
    animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
    
    bottomContainerView = UIView(frame: CGRect.zero)
    bottomContainerView.alpha = 0
    view.addSubview(bottomContainerView)
    bottomContainerView.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalTo(view.layoutMarginsGuide.snp.bottom).offset(-Constants.bottomButtonsHeight)
    }
    
    recordView = RecordView(bottomMargin: view.layoutMargins.bottom)
    bottomContainerView.addSubview(recordView)
    recordView.snp.makeConstraints { make in
      make.width.equalToSuperview().multipliedBy(0.25)
      make.height.equalToSuperview()
      make.top.equalToSuperview()
      make.left.equalToSuperview()
    }
    
    loopRecordView = LoopRecordView(bottomMargin: view.layoutMargins.bottom)
    loopRecordView.backgroundColor = UIColor.Theme.red
    bottomContainerView.addSubview(loopRecordView)
    loopRecordView.snp.makeConstraints { make in
      make.size.equalTo(recordView.snp.size)
      make.top.equalToSuperview()
      make.left.equalTo(recordView.snp.right)
    }
    
    muteAllView = MuteAllView(bottomMargin: view.layoutMargins.bottom)
    bottomContainerView.addSubview(muteAllView)
    muteAllView.snp.makeConstraints { make in
      make.size.equalTo(recordView.snp.size)
      make.top.equalToSuperview()
      make.left.equalTo(loopRecordView.snp.right)
    }
    
    moreView = MoreOptionsView(bottomMargin: view.layoutMargins.bottom)
    moreView.trackSelectorDelegate = self
    bottomContainerView.addSubview(moreView)
    moreView.snp.makeConstraints { make in
      make.size.equalTo(recordView.snp.size)
      make.top.equalToSuperview()
      make.left.equalTo(muteAllView.snp.right)
    }
    
    let layoutBounds = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - view.layoutMargins.bottom - Constants.bottomButtonsHeight)
    let layout = TracksCollectionViewLayout(bounds: layoutBounds)
    collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    collectionView.register(TrackCollectionViewCell.self, forCellWithReuseIdentifier: TrackCollectionViewCell.identifier)
    collectionView.alwaysBounceVertical = true
    collectionView.dataSource = self
    collectionView.delegate = self
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.bottom.equalTo(bottomContainerView.snp.top)
    }
    
    welcomeLabel = UILabel(frame: CGRect.zero)
    welcomeLabel.font = UIFont.hindMaduraiLight(ofSize: UIFont.Size.thirteen)
    welcomeLabel.textAlignment = .center
    welcomeLabel.alpha = 0
    welcomeLabel.textColor = UIColor.Theme.white
    welcomeLabel.text = "Swipe down to create a new track."
    view.addSubview(welcomeLabel)
    welcomeLabel.snp.makeConstraints { make in
      make.center.equalTo(collectionView.snp.center)
    }
    
    addTrackIndicatorView = UIView(frame: CGRect.zero)
    addTrackIndicatorView.backgroundColor = UIColor.Theme.green
    view.addSubview(addTrackIndicatorView)
    addTrackIndicatorView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalToSuperview()
      make.height.equalTo(0)
    }
    
    createTrackLabel = UILabel(frame: CGRect.zero)
    createTrackLabel.font = UIFont.hindMaduraiRegular(ofSize: UIFont.Size.thirteen)
    createTrackLabel.text = "CREATE TRACK"
    createTrackLabel.textAlignment = .center
    addTrackIndicatorView.addSubview(createTrackLabel)
    createTrackLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
//    NotificationCenter.default.addObserver(self, selector: #selector(TracksViewController.onTrackSelected(_:)), name: NSNotification.Name(rawValue: Constants.notificationTrackSelected), object: nil)
//    NotificationCenter.default.addObserver(self, selector: #selector(TracksViewController.onLoopRecordArmed(_:)), name: NSNotification.Name(rawValue: Constants.notificationLoopRecordArmed), object: nil)
//    NotificationCenter.default.addObserver(self, selector: #selector(TracksViewController.onDestroyTrack(_:)), name: NSNotification.Name(rawValue: Constants.notificationDestroyTrack), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(TracksViewController.dismissActiveLoopRecord), name: NSNotification.Name(rawValue: Constants.notificationEndLoopRecord), object: nil)
    UIView.animate(withDuration: 2) {
      self.bottomContainerView.alpha = 1
      self.welcomeLabel.alpha = 1
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self)
  }
  
  func toggleTrackEditMode() {
    guard tracks.count > 0 else { return }
    editingTracks = !editingTracks
    UIView.animate(
      withDuration: Constants.defaultAnimationDuration,
      delay: 0,
      options: [.allowUserInteraction, .beginFromCurrentState],
      animations: { self.visibleCells.forEach { $0.editing = self.editingTracks }},
      completion: nil
    )
  }
  
  func handleError(errorMessage: String, description: String? = nil) {
    print(errorMessage)
    let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default))
    present(alertController, animated: true)
  }
  
  func createTrack() {
    UIView.animate(withDuration: Constants.defaultAnimationDuration) { self.welcomeLabel.alpha = 0 }
    let newTrack = Track()
    collectionView.performBatchUpdates({
      tracks.insert(newTrack, at: 0)
      collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
    }, completion: { finished in
      if finished {
        for cell in self.visibleCells {
          if cell.track == self.tracks.first {
            UIView.animate(
              withDuration: Constants.defaultAnimationDuration,
              delay: 0,
              options: [.allowUserInteraction, .beginFromCurrentState],
              animations: { self.selectCell(cell) },
              completion: nil
            )
            break
          }
        }
      }
    })
  }
  
  func selectCell(_ cell: TrackCollectionViewCell) {
    if selectedTrack != cell.track {
      cell.track?.recordDelegate = self.recordView
      cell.track?.loopRecordDelegate = self.loopRecordView
      cell.track?.moreView = moreView
      recordView.track = cell.track
      loopRecordView.track = cell.track
      
      cell.selectedForLoopRecord = true
      
      selectedTrack = cell.track
      
      for visibleCell in visibleCells {
        visibleCell.selectedForLoopRecord = visibleCell == cell
        visibleCell.enabled = true
        visibleCell.editing = false
        visibleCell.track?.isArmedForLoopRecord = false
        loopRecordView.setArmed(false)
      }
      
      editingTracks = false
      loopRecordView.setArmed(false)
      loopRecordView.enabled = cell.track?.hasAudio ?? false
      recordView.enabled = true
    }
  }
}

