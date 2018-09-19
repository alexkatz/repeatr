import AVFoundation

struct LoopPoint {
  let uuid = UUID().uuidString
  let intervalFromStart: UInt64
  let audioTime: Double?
  let audioPlayer: AVAudioPlayer
}
