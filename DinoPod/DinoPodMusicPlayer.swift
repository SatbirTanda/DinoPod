//
//  DinoPodMusicPlayer.swift
//  
//
//  Created by Satbir Tanda on 7/29/15.
//
//

import MediaPlayer
import AVFoundation

class DinoPodMusicPlayer: NSObject {
    
    private var musicPlayer: AVPlayer! {
        willSet (oldMusicPlayer) {
            oldMusicPlayer.pause()
            NSNotificationCenter.defaultCenter().removeObserver(self,
                                                                name: AVPlayerItemDidPlayToEndTimeNotification,
                                                                object: oldMusicPlayer.currentItem)
        }
        didSet {
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                            selector:"trackEnded",
                                                            name: AVPlayerItemDidPlayToEndTimeNotification,
                                                            object: musicPlayer.currentItem)
            musicPlayer.play()
            updatePlayerInfoCenter()
            NSNotificationCenter.defaultCenter().postNotificationName("musicPlayerStateChanged", object: nil)
        }
    }
    
    private var songsQuery: MPMediaQuery!
    private var selectedSongIndex: Int!
    
    // MARK: meta data:
    
    var currentSongTitle: String?
    var currentSongArtistName: String?
    var currentSongArtworkImage: UIImage?
    var currentSongDuration: NSTimeInterval?
    
    // END meta data
    
    var songRepeats: Bool {
        get {
            return DinoPodHistory.getRepeat()
        }
        set {
            DinoPodHistory.setRepeat(newValue)
        }
    }
    var shuffle: Bool {
        get {
            return DinoPodHistory.getShuffle()
        }
        set {
            DinoPodHistory.setShuffle(newValue)
        }
    }
    
    var rate: Float? {
        get {
            if musicPlayer != nil {
                return musicPlayer!.rate
            }
            return 0
        }
    }
    
    var trackTime: Float64? {
        get {
            if musicPlayer != nil {
                return CMTimeGetSeconds(musicPlayer!.currentTime())
            }
            return 0
        }
    }

    
    init(songsQuery: MPMediaQuery, selectedSongIndex: Int) {
        super.init()
        self.songsQuery = songsQuery
        self.selectedSongIndex = selectedSongIndex
        self.supplyNewSongToPlayer()
    }
    
    // MARK: Alter Player's state
    
    func nextTrack() {
        if selectedSongIndex != nil {
            if let totalSongCount = songsQuery?.collections?.count {
                if shuffle {
                    let randomIndex = Int(arc4random_uniform(UInt32(totalSongCount)))
                    selectedSongIndex = randomIndex
                } else {
                    if selectedSongIndex + 1 >= totalSongCount {
                        selectedSongIndex = 0
                    } else {
                        selectedSongIndex = selectedSongIndex + 1
                    }
                }
            }
            supplyNewSongToPlayer()
        }
    }
    
    func previousTrack() {
        if selectedSongIndex != nil {
            if let totalSongCount = songsQuery?.collections?.count {
                if shuffle {
                    let randomIndex = Int(arc4random_uniform(UInt32(totalSongCount)))
                    selectedSongIndex = randomIndex
                } else {
                    if selectedSongIndex - 1 < 0 {
                        selectedSongIndex = totalSongCount - 1
                    } else {
                        selectedSongIndex = selectedSongIndex - 1
                    }
                }
            }
            supplyNewSongToPlayer()
        }
    }
    
    func playPauseTrack() {
        if (musicPlayer.rate != 0) && (musicPlayer.error == nil) {
            musicPlayer.pause()
        } else {
            musicPlayer.play()
            updatePlayerInfoCenter()
        }
    }
    
    func changeRateTo(rate: Float) {
        musicPlayer?.rate = rate
        updatePlayerInfoCenter()
    }
    
    private func supplyNewSongToPlayer() {
        if let songURL = songsQuery.collections?[selectedSongIndex].representativeItem?.valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL {
            let playerItem = AVPlayerItem(URL: songURL)
            getMetaData(playerItem)
            musicPlayer = AVPlayer(playerItem: playerItem)
        }
    }
    
    // MARK: Selectors 
    
    func trackEnded() {
        if songRepeats {
            let zero = CMTimeMakeWithSeconds(0,1) 
            musicPlayer?.seekToTime(zero)
            playPauseTrack()
        } else {
            nextTrack()
        }
    }
        
    // MARK: Querying Player
    
    func getSongsQuery() -> MPMediaQuery {
        return songsQuery
    }
    
    func getSelectedSongIndex() -> Int {
        return selectedSongIndex
    }
    
    // MARK: Acquiring meta data
    
    private func getMetaData(playerItem: AVPlayerItem) {
        let songMetaData = playerItem.asset.commonMetadata
        getSongTitle(songMetaData)
        getSongArtist(songMetaData)
        getSongArtwork(songMetaData, playerItem: playerItem)
        getSongDuration()
    }
    
    private func getSongTitle(songMetaData: [AVMetadataItem]) {
        if let songTitleItem = AVMetadataItem.metadataItemsFromArray(songMetaData, withKey: AVMetadataCommonKeyTitle, keySpace: AVMetadataKeySpaceCommon).first  {
            if let songTitle = songTitleItem.stringValue {
                currentSongTitle = songTitle
            }
        } else if selectedSongIndex != nil {
            if let songTitle = songsQuery?.collections?[selectedSongIndex!].representativeItem?.valueForProperty(MPMediaItemPropertyTitle) as? String {
                currentSongTitle = songTitle
            }
        }
    }
    
    private func getSongArtist(songMetaData: [AVMetadataItem]) {
        if let artistItem = AVMetadataItem.metadataItemsFromArray(songMetaData, withKey: AVMetadataCommonKeyArtist, keySpace: AVMetadataKeySpaceCommon).first {
            if let artist = artistItem.stringValue {
                currentSongArtistName = artist
            }
        } else if selectedSongIndex != nil {
            if let artist = songsQuery?.collections?[selectedSongIndex!].representativeItem?.valueForProperty(MPMediaItemPropertyArtist) as? String {
                currentSongArtistName = artist
            }
        }
    }
    
    private func getSongArtwork(songMetaData: [AVMetadataItem], playerItem: AVPlayerItem) {
        playerItem.asset.loadValuesAsynchronouslyForKeys(["commonMetadata"]) {
            if let artworkItem = AVMetadataItem.metadataItemsFromArray(songMetaData, withKey: AVMetadataCommonKeyArtwork, keySpace: AVMetadataKeySpaceCommon).first {
                if let artworkData = artworkItem.dataValue {
                    if let artworkImage = UIImage(data: artworkData) {
                        self.currentSongArtworkImage = artworkImage
                    }
                } 
            } else {
                self.currentSongArtworkImage = UIImage(named: "defaultArtwork")
            }
        }
    }
    
    private func getSongDuration() {
        if selectedSongIndex != nil {
            if let duration = songsQuery?.collections?[selectedSongIndex!].representativeItem?.valueForProperty(MPMediaItemPropertyPlaybackDuration)?.doubleValue {
                currentSongDuration = duration
            }
        }
    }
    
    private func updatePlayerInfoCenter() {
        if musicPlayer != nil {
            let title = currentSongTitle ?? "Unknown Track"
            let artist = currentSongArtistName ?? "Unknown Artist"
            let artwork = MPMediaItemArtwork(image: currentSongArtworkImage ?? UIImage(named: "defaultArtwork")!)
            let duration = currentSongDuration ?? 0

            let currentRate = rate ?? 0
            let currentTime = trackTime ?? 0
            let info: [String: AnyObject] =
            [MPMediaItemPropertyTitle: title,
                MPMediaItemPropertyArtist: artist,
                MPMediaItemPropertyArtwork: artwork,
                MPMediaItemPropertyPlaybackDuration: duration,
                MPNowPlayingInfoPropertyPlaybackRate: currentRate,
                MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime]
            
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info
        }
    }

}