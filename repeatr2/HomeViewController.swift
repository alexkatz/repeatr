import UIKit
import AVFoundation

class HomeViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.orange
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let errorMessage = "Couldn't start audio session. Try closing and relaunching the app!"
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
      try audioSession.setPreferredIOBufferDuration(0.001)
      try audioSession.setActive(true)
      throw AudioError.AudioEngineError
    } catch AudioError.AudioEngineError {
      return handleError(errorMessage: errorMessage)
    } catch let error as NSError {
      return handleError(errorMessage: errorMessage, description: error.localizedDescription)
    }
  }
  
  func handleError(errorMessage: String, description: String? = nil) {
    print(errorMessage)
    
    let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default))
    present(alertController, animated: true)
  }
}

