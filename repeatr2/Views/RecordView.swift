import UIKit

class RecordView: BottomControlView, RecordDelegate {
  var isRecording = false {
    didSet {
      label.alpha = isRecording ? Constants.dimAlpha : 1
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.trackService?.recordAudio()
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.trackService?.stopAudio()
  }
  
  override func setup() {
    super.setup()
    label.text = "RECORD"
    label.textColor = UIColor.Theme.red
  }
}
