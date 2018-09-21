import UIKit

class LoopRecordView: BottomControlView, LoopRecordDelegate {
  let loopText = "LOOP"
  
  var isLabelWhite = true
  var armedTimer: Timer?
  
  weak var delegate: LoopRecordViewDelegate?
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let trackService = trackService {
      if trackService.isLoopRecording {
        trackService.finishLoopRecord()
        delegate?.dismissActiveLoopRecord()
      } else if !trackService.isArmedForLoopRecord {
        trackService.isArmedForLoopRecord = true
      } else if trackService.isArmedForLoopRecord && !trackService.isLoopRecording {
        trackService.startLoopRecord()
      }
    }
  }
  
  override func setup() {
    super.setup()
    label.text = loopText
    backgroundColor = Constants.redColor
  }
  
  @objc func toggleRed() {
    isLabelWhite = !isLabelWhite
    label.textColor = isLabelWhite ? Constants.whiteColor : Constants.blackColor
  }
  
  func didChangeIsArmed(_ isArmed: Bool) {
    setArmed(isArmed)
  }
  
  func didChangeIsLoopRecording(_ isLoopRecording: Bool) {
    if isLoopRecording {
      armedTimer?.invalidate()
      label.textColor = Constants.blackColor
      isLabelWhite = false
    } else {
      label.textColor = Constants.whiteColor
      backgroundColor = Constants.redColor
      isLabelWhite = true
      setArmed(false)
    }
  }
  
  func setArmed(_ armed: Bool) {
    if armed {
      label.textColor = Constants.blackColor
      backgroundColor = Constants.redColor
      isLabelWhite = false
      let interval = 0.35
      armedTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(LoopRecordView.toggleRed), userInfo: nil, repeats: true)
      armedTimer?.tolerance = interval * 0.10
    } else {
      armedTimer?.invalidate()
      label.textColor = Constants.whiteColor
      isLabelWhite = true
    }
  }
}
