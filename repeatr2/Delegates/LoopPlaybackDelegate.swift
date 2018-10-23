protocol LoopPlaybackDelegate: Disablable {
  var loopExists: Bool { get set }
  var isPlayingLoop: Bool { get set }
}
