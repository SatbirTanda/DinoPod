//
//  AlbumsTableViewController.swift
//  DinoPod
//
//  Created by Satbir Tanda on 7/12/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumsTableViewController: UITableViewController {
    
    // MARK: - Table view data source
    
    var albumsQuery: MPMediaQuery?

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumsQuery?.collections?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Album", forIndexPath: indexPath) 

        if let albumName = albumsQuery?.collections?[indexPath.row].representativeItem?.valueForProperty(MPMediaItemPropertyAlbumTitle) as? String {
            cell.textLabel?.text = albumName
        }
        if let albumArtist = albumsQuery?.collections?[indexPath.row].representativeItem?.valueForProperty(MPMediaItemPropertyArtist) as? String {
            cell.detailTextLabel?.text = albumArtist
        }
        if let albumArtwork = albumsQuery?.collections?[indexPath.row].representativeItem?.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
            if cell.imageView != nil {
                if let albumImage = albumArtwork.imageWithSize(cell.imageView!.frame.size) {
                    cell.imageView?.image = albumImage
                }
            }
        } else {
            cell.imageView?.image = UIImage(named: "defaultArtwork")
        }
        
        return cell
    }

    
    // MARK: - Navigation

    private struct Segues {
        static let AlbumSongs = "Show Album's Songs"
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Segues.AlbumSongs {
                if let songsTVC = segue.destinationViewController as? SongsTableViewController {
                    if let cell = sender as? UITableViewCell {
                        let query = MPMediaQuery.songsQuery()
                        query.addFilterPredicate(MPMediaPropertyPredicate(value: cell.textLabel?.text, forProperty: MPMediaItemPropertyAlbumTitle))
                        songsTVC.songsQuery = query
                    }
                }
            }
        }
    }
    

}
