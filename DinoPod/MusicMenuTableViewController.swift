//
//  MusicMenuTableViewController.swift
//  DinoPod
//
//  Created by Satbir Tanda on 7/14/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit
import MediaPlayer

class MusicMenuTableViewController: UITableViewController {
    
    // MARK: Navigation
    
    private struct Segues {
        static let Albums = "ALBUMS"
        static let Artists = "ARTISTS"
        static let Songs = "SONGS"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Segues.Albums {
                if let albumsTVC = segue.destinationViewController as? AlbumsTableViewController {
                    let query = MPMediaQuery.albumsQuery()
                    query.groupingType = MPMediaGrouping.Album
                    albumsTVC.albumsQuery = query
                }
            }
            else if identifier == Segues.Artists {
                if let artistsTVC = segue.destinationViewController as? ArtistsTableViewController {
                    let query = MPMediaQuery.artistsQuery()
                    query.groupingType = MPMediaGrouping.AlbumArtist
                    artistsTVC.artistsQuery = query
                }
            }
            else if identifier == Segues.Songs {
                if let songsTVC = segue.destinationViewController as? SongsTableViewController {
                    let query = MPMediaQuery.songsQuery()
                    query.groupingType = MPMediaGrouping.Title
                    songsTVC.songsQuery = query
                }
            }
        }
    }

}
