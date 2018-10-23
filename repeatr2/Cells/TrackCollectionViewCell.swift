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
          playbackView.track = track
          removeTrackView.track = track
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
  
  lazy var removeTrackView: RemoveTrackView = {
    let removeTrackView = RemoveTrackView()
    trackControlsView.addSubview(removeTrackView)
    removeTrackView.snp.makeConstraints { make in
      make.height.equalTo(Constants.bottomButtonsHeight)
      make.width.equalToSuperview().multipliedBy(0.25)
      make.leading.equalTo(playbackView.snp.trailing)
      make.bottom.equalToSuperview()
    }

    removeTrackView.track = track
    
    return removeTrackView
  }()
  
  lazy var trackControlsView: UIView = {
    let view = UIView()
    addSubview(view)
    view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    view.alpha = 0
    
    return view
  }()
  
  lazy var volumeControlView: VolumeControlView = {
    let volumeView = VolumeControlView(bottomMargin: 3)
    trackControlsView.addSubview(volumeView)
    volumeView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    volumeView.backgroundColor = UIColor.Theme.white.withAlphaComponent(0)
    volumeView.fillColor = UIColor.Theme.white.withAlphaComponent(Constants.dimAlpha)
    volumeView.centerLabelText = nil
    return volumeView
  }()
  
  lazy var playbackView: LoopPlaybackView = {
    let playbackView = LoopPlaybackView()
    trackControlsView.addSubview(playbackView)
    playbackView.snp.makeConstraints { make in
      make.width.equalToSuperview().multipliedBy(0.25)
      make.height.equalTo(CGFloat(Constants.bottomButtonsHeight))
      make.leading.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    playbackView.enabled = true
    playbackView.visualDelegate = self
    
    return playbackView
  }()

  func playbackView(_ playbackView: LoopPlaybackView, isPlayingLoop: Bool) {
    volumeControlView.fillColor = isPlayingLoop ? UIColor.Theme.green.withAlphaComponent(Constants.dimAlpha) : UIColor.Theme.white.withAlphaComponent(Constants.dimAlpha)
  }
}
