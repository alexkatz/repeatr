import UIKit

class TrackCollectionViewCell: UICollectionViewCell, AudioVolumeDelegate, PlaybackVisualDelegate {
  static let identifier = "TrackCollectionViewCell"
  
  var waveformView: WaveformView?
  
  var track: Track? {
    didSet {
      guard let track = track else { return }
      
      if waveformView == nil {
        waveformView = WaveformView(track: track)
        contentView.addSubview(waveformView!)
        waveformView!.snp.makeConstraints { make in
          make.edges.equalToSuperview()
        }
      }
      
      waveformView?.track = track
      waveformView?.waveColor = UIColor.Theme.white.withAlphaComponent(Constants.dimAlpha)
      waveformView?.cursorColor = UIColor.Theme.green
      waveformView?.bookmarkColor = UIColor.Theme.white.withAlphaComponent(Constants.dimAlpha)
      waveformView?.bookmarkBaseColor = UIColor.Theme.white.withAlphaComponent(0.0)
      
      if trackControlsView == nil { addTrackControlsView() }
      
      volumeControlView.delegate = self
      volumeControlView.volumeLevel = volumeLevel ?? 0
      
      playbackView.track = track
      
      removeTrackView.track = track
      
      track.playbackDelegate = waveformView
      track.meterDelegate = waveformView
    }
  }
  
  var selectedForLoopRecord = false {
    didSet {
      waveformView?.backgroundColor = selectedForLoopRecord ? UIColor.Theme.blackSelected : UIColor.Theme.black
    }
  }
  
  var enabled = true {
    didSet {
      waveformView?.enabled = enabled
      waveformView?.dimmed = !enabled
    }
  }
  
  var editing = false {
    didSet {
      if let track = track {
        volumeControlView.volumeLevel = track.volumeLevel
        if editing {
          track.loopPlaybackDelegate = playbackView
          bringSubviewToFront(trackControlsView)
        }
      }
      
      waveformView?.enabled = !editing
      waveformView?.dimmed = editing
      trackControlsView.alpha = editing ? 1 : 0
    }
  }
  
  var volumeLevel: Float? {
    get { return track?.volumeLevel }
    set { track?.volumeLevel = newValue ?? 0 }
  }
  
  var removeTrackView: RemoveTrackView!
  var trackControlsView: UIView!
  var volumeControlView: VolumeControlView!
  var playbackView: LoopPlaybackView!
  
  func addTrackControlsView() {
    trackControlsView = UIView()
    addSubview(trackControlsView)
    trackControlsView.alpha = 0
    trackControlsView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    volumeControlView = VolumeControlView(bottomMargin: 3)
    trackControlsView.addSubview(volumeControlView)
    volumeControlView.backgroundColor = UIColor.Theme.white.withAlphaComponent(0)
    volumeControlView.fillColor = UIColor.Theme.white.withAlphaComponent(Constants.dimAlpha)
    volumeControlView.centerLabelText = nil
    volumeControlView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    playbackView = LoopPlaybackView(bottomMargin: 0)
    playbackView.enabled = true
    trackControlsView.addSubview(playbackView)
    playbackView.snp.makeConstraints { make in
      make.width.equalToSuperview().multipliedBy(0.25)
      make.height.equalTo(CGFloat(Constants.bottomButtonsHeight))
      make.leading.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    playbackView.enabled = true
    playbackView.visualDelegate = self
    
    removeTrackView = RemoveTrackView(bottomMargin: 0)
    removeTrackView.enabled = true
    trackControlsView.addSubview(removeTrackView)
    removeTrackView.snp.makeConstraints { make in
      make.height.equalTo(Constants.bottomButtonsHeight)
      make.width.equalToSuperview().multipliedBy(0.25)
      make.leading.equalTo(playbackView.snp.trailing)
      make.bottom.equalToSuperview()
    }
    
    removeTrackView.track = track
  }

  func playbackView(_ playbackView: LoopPlaybackView, isPlayingLoop: Bool) {
    volumeControlView.fillColor = isPlayingLoop
      ? UIColor.Theme.green.withAlphaComponent(Constants.dimAlpha)
      : UIColor.Theme.white.withAlphaComponent(Constants.dimAlpha)
  }
}
