import UIKit
import SnapKit
import AVFoundation

class HomeViewController: UIViewController {
  var collectionView: UICollectionView!
  var bottomContainerView: UIView!
  var recordView: UIView!
  var loopView: UIView!
  var muteView: UIView!
  var moreView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let errorMessage = "Couldn't start audio session. Try closing and relaunching the app!"
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(AVAudioSession.Category(rawValue: AVAudioSession.Category.playAndRecord.rawValue), mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
      try audioSession.setPreferredIOBufferDuration(0.001)
      try audioSession.setActive(true)
      throw AudioError.AudioEngineError
    } catch AudioError.AudioEngineError {
      handleError(errorMessage: errorMessage)
    } catch let error as NSError {
      handleError(errorMessage: errorMessage, description: error.localizedDescription)
    }
    
    bottomContainerView = UIView(frame: CGRect.zero)
    bottomContainerView.alpha = 0
    view.addSubview(bottomContainerView)
    bottomContainerView.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalTo(view.layoutMarginsGuide.snp.bottom).offset(-44)
    }
    
    recordView = UIView(frame: CGRect.zero)
    recordView.backgroundColor = Constants.darkerRedColor
    bottomContainerView.addSubview(recordView)
    recordView.snp.makeConstraints { make in
      make.width.equalToSuperview().multipliedBy(0.25)
      make.height.equalToSuperview()
      make.top.equalToSuperview()
      make.left.equalToSuperview()
    }
    
    loopView = UIView(frame: CGRect.zero)
    loopView.backgroundColor = Constants.redColor
    bottomContainerView.addSubview(loopView)
    loopView.snp.makeConstraints { make in
      make.size.equalTo(recordView.snp.size)
      make.top.equalToSuperview()
      make.left.equalTo(recordView.snp.right)
    }
    
    muteView = UIView(frame: CGRect.zero)
    muteView.backgroundColor = UIColor.orange
    bottomContainerView.addSubview(muteView)
    muteView.snp.makeConstraints { make in
      make.size.equalTo(recordView.snp.size)
      make.top.equalToSuperview()
      make.left.equalTo(loopView.snp.right)
    }
    
    moreView = UIView(frame: CGRect.zero)
    moreView.backgroundColor = UIColor.green
    bottomContainerView.addSubview(moreView)
    moreView.snp.makeConstraints { make in
      make.size.equalTo(recordView.snp.size)
      make.top.equalToSuperview()
      make.left.equalTo(muteView.snp.right)
    }
    
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIView.animate(withDuration: 2) {
      self.bottomContainerView.alpha = 1
    }
  }
  
  func handleError(errorMessage: String, description: String? = nil) {
    print(errorMessage)
    let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default))
    present(alertController, animated: true)
  }
}

