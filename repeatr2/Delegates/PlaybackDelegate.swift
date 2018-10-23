import Foundation

protocol PlaybackDelegate: Disablable {
  var audioURL: URL? { get set }
  var currentTime: TimeInterval? { get set }
  func removeCursor()
}
