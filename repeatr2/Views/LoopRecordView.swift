import UIKit

class LoopRecordView: BottomControlView, LoopRecordDelegate {
  let loopText = "LOOP"
  
  var isLabelWhite = true
  var armedTimer: Timer?
  
  weak var delegate: LoopRecordViewDelegate?
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let track = track else { return }
    
    if track.isLoopRecording {
      track.finishLoopRecord()
      delegate?.dismissActiveLoopRecord()
    } else if !track.isArmedForLoopRecord {
      track.isArmedForLoopRecord = true
    } else if track.isArmedForLoopRecord && !track.isLoopRecording {
      track.startLoopRecord()
    }
  }
  
  override func setup() {
    super.setup()
    label.text = loopText
    backgroundColor = UIColor.Theme.red
  }
  
  @objc func toggleRed() {
    isLabelWhite = !isLabelWhite
    label.textColor = isLabelWhite ? UIColor.Theme.white : UIColor.Theme.black
  }
  
  func didChangeIsArmed(_ isArmed: Bool) {
    setArmed(isArmed)
  }
  
  func didChangeIsLoopRecording(_ isLoopRecording: Bool) {
    if isLoopRecording {
      armedTimer?.invalidate()
      label.textColor = UIColor.Theme.black
      isLabelWhite = false
    } else {
      label.textColor = UIColor.Theme.white
      backgroundColor = UIColor.Theme.red
      isLabelWhite = true
      setArmed(false)
    }
  }
  
  func setArmed(_ armed: Bool) {
    if armed {
      label.textColor = UIColor.Theme.black
      backgroundColor = UIColor.Theme.red
      isLabelWhite = false
      let interval = 0.35
      armedTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(LoopRecordView.toggleRed), userInfo: nil, repeats: true)
      armedTimer?.tolerance = interval * 0.10
    } else {
      armedTimer?.invalidate()
      label.textColor = UIColor.Theme.white
      isLabelWhite = true
    }
  }
}
