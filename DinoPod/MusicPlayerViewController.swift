//
//  MusicPlayerViewController.swift
//  DinoPod
//
//  Created by Satbir Tanda on 7/19/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class MusicPlayerViewController: UIViewController {
    
    var songsQuery: MPMediaQuery?
    var selectedSongIndex: Int?
    var holdTimer: NSTimer?
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView! {
        didSet {
            self.artworkImageView.contentMode = .ScaleAspectFit
        }
    }
    @IBOutlet weak var songProgressView: UIProgressView! {
        didSet {
            songProgressView.transform = CGAffineTransformMakeScale(1.0, 3.0)
        }
    }
    @IBOutlet weak var volumeProgressView: UIProgressView! {
        didSet {
            volumeProgressView.transform = CGAffineTransformMakeScale(1.0, 3.0)
            updateVolumeProgressView()
        }
    }
    private var audioSession = AVAudioSession.sharedInstance()
    var mpVolumeView = MPVolumeView(frame: CGRect(x: -50, y: -50, width: 0, height: 0))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        holdTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self,
            selector: "updateSongProgressView",
            userInfo: nil,
            repeats: true)
        audioSession.addObserver(self, forKeyPath: "outputVolume", options: [], context: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        holdTimer?.invalidate()
        holdTimer = nil
        audioSession.removeObserver(self, forKeyPath: "outputVolume")
        super.viewWillDisappear(animated)
    }

    private func setup() {
        view.addSubview(mpVolumeView)
        if let dpvc = self.parentViewController?.parentViewController as? DinoPodViewController {
            if selectedSongIndex != nil && songsQuery != nil {
                dpvc.musicPlayer = DinoPodMusicPlayer(songsQuery: songsQuery!, selectedSongIndex: selectedSongIndex!)
            } else if let musicPlayer = dpvc.musicPlayer {
                    songsQuery = musicPlayer.getSongsQuery()
                    selectedSongIndex = musicPlayer.getSelectedSongIndex()
            }
            
            updateUI(dpvc.musicPlayer?.currentSongTitle, songArtist: dpvc.musicPlayer?.currentSongArtistName, songArtwork: dpvc.musicPlayer?.currentSongArtworkImage)
        }
    }
    
    func updateUI(songTitle: String?, songArtist: String?, songArtwork: UIImage?) {
        if songTitle != nil {
            songNameLabel.text = songTitle
        } else {
            songNameLabel.text = "Unknown Track"
        }
        if songArtist != nil {
            artistNameLabel.text = songArtist
        } else {
            artistNameLabel.text = "Unknown Artist"
        }
        if songArtwork != nil {
            UIView.transitionWithView(self.artworkImageView, duration: 1.5, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: { self.artworkImageView.image = songArtwork }, completion: nil)
        } else {
            UIView.transitionWithView(self.artworkImageView, duration: 1.5, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: { self.artworkImageView.image = UIImage(named: "defaultArtwork") }, completion: nil)
        }
    }
    
    func updateSongProgressView() {
        if let dpvc = parentViewController?.parentViewController as? DinoPodViewController {
            if let musicPlayer = dpvc.musicPlayer {
                if let currentTime = musicPlayer.trackTime {
                    if let totalDuration = musicPlayer.currentSongDuration {
                        let progress = Float(currentTime/totalDuration)
                        songProgressView.setProgress(progress, animated: true)
                    }
                }
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "outputVolume" {
            updateVolumeProgressView()
        }
    }
    
    private func updateVolumeProgressView() {
        let volume = audioSession.outputVolume
        volumeProgressView.setProgress(volume, animated: true)
    }
    
    // MARK: Navigation
    
//    private struct Segues {
//        static let ShowOptions = "Show Options"
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let identifier = segue.identifier {
//            if identifier == Segues.ShowOptions {
//                if let tbvc = segue.destinationViewController as? UITableViewController {
//                    println("tbvc")
//                    if let ppc = tbvc.popoverPresentationController {
//                        println("ppc")
//                        ppc.delegate = self
//                    }
//                }
//            }
//        }
//    }
//
//    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
//        return .None
//    }
    
}
