//
//  ViewController.swift
//  DinoPod
//
//  Created by Satbir Tanda on 6/20/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation


class DinoPodViewController: UIViewController, UINavigationControllerDelegate {
    
    //Should have an audio session instance to handle background events etc.
    
    // MARK : Initialization
    
    var musicPlayer: DinoPodMusicPlayer? {
        willSet {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "musicPlayerStateChanged", object: nil)
        }
        didSet {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCurrentViewUI", name: "musicPlayerStateChanged", object: nil)
        }
    }
    
    @IBOutlet weak var selectButton: UIView!
    @IBOutlet weak var forwardsButton: UIImageView! 
    @IBOutlet weak var playPauseButton: UIImageView!
    @IBOutlet weak var rewindsButton: UIImageView!
    @IBOutlet weak var menuButton: UIImageView! 
    @IBOutlet weak var scrollWheel: UIImageView! { //Doesnt highlight in blue
        didSet {
            scrollWheel.userInteractionEnabled = true
            scrollWheel.addGestureRecognizer(ScrollWheelGestureRecognizer(target: self, action: "scroll:"))
        }
    }
    
    private let MINIMUM_SECTOR_DISTANCE: CGFloat = 25
    private var currentView: UIViewController?
    
    override func awakeFromNib() {
        var setCategoryError: NSError?
        let success: Bool
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            success = true
        } catch let error as NSError {
            setCategoryError = error
            success = false
        }
        if success {
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            self.becomeFirstResponder()
        } else {
            print("\(setCategoryError)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        if let navigationViewController = childViewControllers.first as? UINavigationController {
            navigationViewController.delegate = self
        }
    }
    
    // MARK: Initialize
    
    private func setupVC() {
        if let dinopodColor = DinoPodHistory.getDinoPodColor() {
            view.backgroundColor = dinopodColor
        }
        if let scrollWheelImage = DinoPodHistory.getScrollWheelImage()  {
            scrollWheel.image = scrollWheelImage
        }
        if let menuButtonImage = DinoPodHistory.getMenuButtonImage() {
            menuButton.image = menuButtonImage
        }
        if let forwardButtonImage = DinoPodHistory.getForwardButtonImage() {
            forwardsButton.image = forwardButtonImage
        }
        if let playPauseButtonImage = DinoPodHistory.getPlayPauseButtonImage() {
            playPauseButton.image = playPauseButtonImage
        }
        if let rewindButtonImage = DinoPodHistory.getRewindButtonImage() {
            rewindsButton.image = rewindButtonImage
        }
    }
    
    // MARK: Selector methods
    
    func updateCurrentViewUI() {
        if let mpvc = currentView as? MusicPlayerViewController {
            mpvc.updateUI(musicPlayer?.currentSongTitle, songArtist: musicPlayer?.currentSongArtistName, songArtwork: musicPlayer?.currentSongArtworkImage)
        }
    }
    
    // MARK: Remote control events
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event != nil {
            if event!.type == .RemoteControl {
                switch event!.subtype {
                case .RemoteControlPause:
                    musicPlayer?.playPauseTrack()
                case .RemoteControlPlay:
                    musicPlayer?.playPauseTrack()
                case .RemoteControlPreviousTrack:
                    musicPlayer?.previousTrack()
                case .RemoteControlNextTrack:
                    musicPlayer?.nextTrack()
                case .RemoteControlBeginSeekingBackward:
                    musicPlayer?.changeRateTo(-5.0)
                case .RemoteControlBeginSeekingForward:
                    musicPlayer?.changeRateTo(5.0)
                case .RemoteControlEndSeekingBackward, .RemoteControlEndSeekingForward:
                    musicPlayer?.changeRateTo(1.0)
                default:
                    break
                }
            }
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // MARK: Gestures - All actions depend on the current view
    
    func scroll(gesture: ScrollWheelGestureRecognizer) { //Cant Scroll through sections
        switch gesture.state {
            case .Changed:
                if gesture.distance >= MINIMUM_SECTOR_DISTANCE {
                    if gesture.rotation > 0 {
                        scrollDown()
                    } else if gesture.rotation < 0 {
                        scrollUp()
                    }
                }
            default: break
        }
    }
    
    private func scrollDown() {
        if let cv = currentView as? UITableViewController {
            if cv.tableView.indexPathForSelectedRow != nil {
                if cv.tableView.indexPathForSelectedRow!.row + 1 < cv.tableView.numberOfRowsInSection(0) {
                    let newRow = cv.tableView.indexPathForSelectedRow!.row + 1
                    let newIndexPath = NSIndexPath(forRow: newRow, inSection: 0)
                    cv.tableView.selectRowAtIndexPath(newIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
                }
            }
        }
        else if let cvc = currentView as? UICollectionViewController {
            if let currentIndexPath = cvc.collectionView?.indexPathsForSelectedItems()?.first  {
                if currentIndexPath.row + 1 < cvc.collectionView?.numberOfItemsInSection(0) {
                    let newRow = currentIndexPath.row + 1
                    let newIndexPath = NSIndexPath(forRow: newRow, inSection: 0)
                    cvc.collectionView?.selectItemAtIndexPath(newIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredVertically)
                }
            }
        }
        else if let mpvc = currentView as? MusicPlayerViewController {
            //increase volume
            if let slider = mpvc.mpVolumeView.subviews.last as? UISlider {
                slider.value += 0.10
            }
        }
    }
    
    private func scrollUp() {
        if let cv = currentView as? UITableViewController {
            if cv.tableView.indexPathForSelectedRow != nil {
                if cv.tableView.indexPathForSelectedRow!.row - 1 >= 0 {
                    let newRow = cv.tableView.indexPathForSelectedRow!.row - 1
                    let newIndexPath = NSIndexPath(forRow: newRow, inSection: 0)
                    cv.tableView.selectRowAtIndexPath(newIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
                }
            }
        }
        else if let cvc = currentView as? UICollectionViewController {
            if let currentIndexPath = cvc.collectionView?.indexPathsForSelectedItems()?.first {
                if currentIndexPath.row - 1 >= 0 {
                    let newRow = currentIndexPath.row - 1
                    let newIndexPath = NSIndexPath(forRow: newRow, inSection: 0)
                    cvc.collectionView?.selectItemAtIndexPath(newIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredVertically)
                }
            }
        }
        else if let mpvc = currentView as? MusicPlayerViewController {
            //decrease volume
            if let slider = mpvc.mpVolumeView.subviews.last as? UISlider {
                slider.value -= 0.10
            }
        }
    }
    
    @IBAction func selectButtonTapped(tap: UITapGestureRecognizer) {
        if let table_view_controlller = currentView as? UITableViewController {
            let tableView = table_view_controlller.tableView
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                if let cell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
                    if table_view_controlller is AlbumsTableViewController {
                        table_view_controlller.performSegueWithIdentifier(PossibleSegues.ShowAlbumsSongs, sender: cell)
                    } else if table_view_controlller is ArtistsTableViewController {
                        table_view_controlller.performSegueWithIdentifier(PossibleSegues.ShowArtistsAlbums, sender: cell)
                    } else if table_view_controlller is SongsTableViewController {
                        table_view_controlller.performSegueWithIdentifier(PossibleSegues.PlayMusic, sender: cell)
                    } else if table_view_controlller is SettingsTableViewController {
                        if musicPlayer != nil {
                            if cell.textLabel?.text == PossibleSegues.Repeat {
                                if musicPlayer!.songRepeats {
                                    cell.accessoryType = .None
                                    musicPlayer!.songRepeats = false
                                } else {
                                    cell.accessoryType = .Checkmark
                                    musicPlayer!.songRepeats = true
                                }
                            } else if cell.textLabel?.text == PossibleSegues.Shuffle {
                                if musicPlayer!.shuffle {
                                    cell.accessoryType = .None
                                    musicPlayer!.shuffle = false
                                } else {
                                    cell.accessoryType = .Checkmark
                                    musicPlayer!.shuffle = true
                                }
                            }
                        }
                    } else {
                        if let identifier = cell.textLabel?.text {
                            if identifier == PossibleSegues.NowPlaying {
                                if musicPlayer != nil {
                                        table_view_controlller.performSegueWithIdentifier(identifier, sender: cell)
                                }
                            } else {
                                table_view_controlller.performSegueWithIdentifier(identifier, sender: cell)
                            }
                        }
                    }
                }
            }
        } else if let collection_view_controller = currentView as? UICollectionViewController {
            if let collectionView = collection_view_controller.collectionView {
                if let selectedIndexPath = collectionView.indexPathsForSelectedItems()?.first {
                    //check class of collection view and change things accordingly
                    if let cell = collectionView.cellForItemAtIndexPath(selectedIndexPath) as? ColorCollectionViewCell {
                        if collection_view_controller is DinoPodColorsCollectionViewController {
                            if let color = cell.colorView.backgroundColor {
                                DinoPodHistory.setDinoPodColor(color)
                                UIView.animateWithDuration(2.0,
                                    delay: 0.0,
                                    options: ([.CurveEaseOut, .AllowUserInteraction]),
                                    animations: { self.view.backgroundColor = color },
                                    completion: nil )
                            }
                        }
                    } else if let cell = collectionView.cellForItemAtIndexPath(selectedIndexPath) as? ImageCollectionViewCell {
                        if collection_view_controller is ScrollWheelColorsCollectionViewController {
                            if let image = cell.imageView.image {
                                DinoPodHistory.setScrollWheelImage(cell.imageName)
                                UIView.animateWithDuration(2.5,
                                    delay: 0.0,
                                    options: ([.CurveEaseIn, .AllowUserInteraction]),
                                    animations: {
                                        self.scrollWheel.alpha = 0.0
                                        self.scrollWheel.image = image
                                        self.scrollWheel.alpha = 1.0
                                    },
                                    completion: nil )
                            }
                        } else if collection_view_controller is MenuColorsCollectionViewController {
                            if let image = cell.imageView.image {
                                DinoPodHistory.setMenuButtonImage(cell.imageName)
                                UIView.animateWithDuration(2.5,
                                    delay: 0.0,
                                    options: ([.CurveLinear, .AllowUserInteraction]),
                                    animations: {
                                        self.menuButton.alpha = 0.0
                                        self.menuButton.image = image
                                        self.menuButton.alpha = 1.0
                                    },
                                    completion: nil )
                            }
                        } else if collection_view_controller is ForwardButtonColorsCollectionViewController {
                            if let image = cell.imageView.image {
                                DinoPodHistory.setForwardButtonImage(cell.imageName)
                                UIView.animateWithDuration(2.5,
                                    delay: 0.0,
                                    options: ([.CurveLinear, .AllowUserInteraction]),
                                    animations: {
                                        self.forwardsButton.alpha = 0.0
                                        self.forwardsButton.image = image
                                        self.forwardsButton.alpha = 1.0
                                    },
                                    completion: nil)
                            }
                            
                        } else if collection_view_controller is PlayPauseButtonColorsCollectionViewController {
                            if let image = cell.imageView.image {
                                DinoPodHistory.setPlayPauseButtonImage(cell.imageName)
                                UIView.animateWithDuration(2.5,
                                    delay: 0.0,
                                    options: ([.CurveLinear, .AllowUserInteraction]),
                                    animations: {
                                        self.playPauseButton.alpha = 0.0
                                        self.playPauseButton.image = image
                                        self.playPauseButton.alpha = 1.0
                                    },
                                    completion: nil)
                            }
                        } else if collection_view_controller is RewindButtonColorsCollectionViewController {
                            if let image = cell.imageView.image {
                                DinoPodHistory.setRewindButtonImage(cell.imageName)
                                UIView.animateWithDuration(2.5,
                                    delay: 0.0,
                                    options: ([.CurveLinear, .AllowUserInteraction]),
                                    animations: {
                                        self.rewindsButton.alpha = 0.0
                                        self.rewindsButton.image = image
                                        self.rewindsButton.alpha = 1.0
                                    },
                                    completion: nil )
                            }
                        }
                    }
                }
            }
        }
    }

    @IBAction func menuButtonTapped(tap: UITapGestureRecognizer) {
        if let navigationViewController = currentView?.navigationController {
            navigationViewController.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func forwardsButtonTapped(tap: UITapGestureRecognizer) {
        if let mpvc = currentView as? MusicPlayerViewController {
            musicPlayer?.nextTrack()
            mpvc.updateUI(musicPlayer?.currentSongTitle, songArtist: musicPlayer?.currentSongArtistName, songArtwork: musicPlayer?.currentSongArtworkImage)
        }
    }
    
    @IBAction func playPauseButtonTapped(tap: UITapGestureRecognizer) {
        if currentView is MusicPlayerViewController {
            musicPlayer?.playPauseTrack()
        }
    }
    
    @IBAction func rewindsButtonTapped(tap: UITapGestureRecognizer) {
        if let mpvc = currentView as? MusicPlayerViewController {
            musicPlayer?.previousTrack()
            mpvc.updateUI(musicPlayer?.currentSongTitle, songArtist: musicPlayer?.currentSongArtistName, songArtwork: musicPlayer?.currentSongArtworkImage)
        }
    }

    @IBAction func forwardsButtonPressed(press: UILongPressGestureRecognizer) {
        if currentView is MusicPlayerViewController {
            switch press.state {
            case .Began:
                fallthrough
            case .Changed:
                musicPlayer?.changeRateTo(5.0)
            case .Cancelled, .Ended, .Failed:
                musicPlayer?.changeRateTo(1.0)
            default:
                break
            }
        }
    }
    
    @IBAction func rewindsButtonPressed(press: UILongPressGestureRecognizer) {
        if currentView is MusicPlayerViewController {
            switch press.state {
            case .Began:
                fallthrough
            case .Changed:
                musicPlayer?.changeRateTo(-5.0)
            case .Cancelled, .Ended, .Failed:
                musicPlayer?.changeRateTo(1.0)
            default:
                break
            }
        }
    }
    
    
    // MARK: Navigation
    
    private struct PossibleSegues {
        static let PlayMusic = "Play Music"
        static let ShowArtistsAlbums = "Show Artist's Albums"
        static let ShowAlbumsSongs = "Show Album's Songs"
        static let NowPlaying = "NOW PLAYING"
        static let Repeat = "REPEAT"
        static let Shuffle = "SHUFFLE"
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        if let curr_table_view = viewController as? UITableViewController {
            if curr_table_view.tableView.indexPathForSelectedRow == nil {
                curr_table_view.clearsSelectionOnViewWillAppear = false
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                curr_table_view.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            }
        } else if let curr_collect_view = viewController as? UICollectionViewController {
            if curr_collect_view.collectionView?.indexPathsForSelectedItems()?.first == nil {
                curr_collect_view.clearsSelectionOnViewWillAppear = false
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                curr_collect_view.collectionView?.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.None)
            }
        }
        currentView = viewController
        unfreezeButtons()
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        freezeButtons()
    }
    
    private func freezeButtons() {
        menuButton.userInteractionEnabled = false
        forwardsButton.userInteractionEnabled = false
        playPauseButton.userInteractionEnabled = false
        rewindsButton.userInteractionEnabled = false
        selectButton.userInteractionEnabled = false
        scrollWheel.userInteractionEnabled = false
    }
    
    private func unfreezeButtons() {
        menuButton.userInteractionEnabled = true
        forwardsButton.userInteractionEnabled = true
        playPauseButton.userInteractionEnabled = true
        rewindsButton.userInteractionEnabled = true
        selectButton.userInteractionEnabled = true
        scrollWheel.userInteractionEnabled = true
    }
    
}

