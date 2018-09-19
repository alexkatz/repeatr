import UIKit

class RecordView: ControlLabelView, RecordDelegate {
  var isRecording: Bool = false {
    didSet {
      self.label.alpha = self.isRecording ? Constants.dimAlpha : 1
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    self.trackService?.recordAudio()
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//    self.trackService?.stopAudio()
  }
  
  override func setup() {
    self.label.text = "RECORD"
    self.label.textColor = Constants.redColor
    self.enabled = true
  }
}
