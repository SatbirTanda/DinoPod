//
//  SongsTableViewController.swift
//  DinoPod
//
//  Created by Satbir Tanda on 7/11/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit
import MediaPlayer

class SongsTableViewController: UITableViewController {
    
    // MARK: - Table view data source
    
    var songsQuery: MPMediaQuery?
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsQuery?.collections?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Song", forIndexPath: indexPath)

        if let songTitle = songsQuery?.collections?[indexPath.row].representativeItem?.valueForProperty(MPMediaItemPropertyTitle) as? String {
            cell.textLabel?.text = songTitle
        } else {
            cell.textLabel?.text = "Unknown Track"
        }
        
        if let songArtist = songsQuery?.collections?[indexPath.row].representativeItem?.valueForProperty(MPMediaItemPropertyArtist) as? String {
            cell.detailTextLabel?.text = songArtist
        } else {
            cell.detailTextLabel?.text = "Unknown Artist"
        }
        
        if let mediaArtwork = songsQuery?.collections?[indexPath.row].representativeItem?.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
            if cell.imageView != nil {
                if let songAlbumArtwork = mediaArtwork.imageWithSize(cell.imageView!.frame.size) {
                    cell.imageView?.image = songAlbumArtwork
                }
            }
        } else {
            cell.imageView?.image = UIImage(named: "defaultArtwork")
        }
        
        return cell
    }

    // MARK: Naviagtion
    
    private struct Segues {
        static let PlayMusic = "Play Music"
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Segues.PlayMusic {
                if let mpvc = segue.destinationViewController as? MusicPlayerViewController {
                    if sender is UITableViewCell {
                        mpvc.songsQuery = songsQuery
                        if let selectedIndexPath = tableView.indexPathForSelectedRow {
                            mpvc.selectedSongIndex = selectedIndexPath.row
                        }
                    }
                }
            }
        }
    }

}
