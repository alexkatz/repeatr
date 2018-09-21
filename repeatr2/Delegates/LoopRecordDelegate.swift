protocol LoopRecordDelegate: Disablable {
  func didChangeIsLoopRecording(_ isLoopRecording: Bool)
  func didChangeIsArmed(_ isArmed: Bool)
}

