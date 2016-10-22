//
//  ArtistsTableViewController.swift
//  DinoPod
//
//  Created by Satbir Tanda on 7/12/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtistsTableViewController: UITableViewController {
    
    // MARK: - Table view data source
    
    var artistsQuery: MPMediaQuery?

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistsQuery?.collections?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Artist", forIndexPath: indexPath) 

        if let artistName = artistsQuery?.collections?[indexPath.row].representativeItem?.valueForProperty(MPMediaItemPropertyArtist) as? String {
            cell.textLabel?.text = artistName
            //do we need another query to get the numbe of albums?
            let albumsQuery = MPMediaQuery.albumsQuery()
            albumsQuery.addFilterPredicate(MPMediaPropertyPredicate(value: artistName, forProperty: MPMediaItemPropertyArtist))
            if albumsQuery.collections?.count > 0 {
                cell.detailTextLabel?.text = "\(albumsQuery.collections!.count) Albums"
            } else {
                cell.detailTextLabel?.text = "0 Albums"
            }
        }
        if let artistArtwork = artistsQuery?.collections?[indexPath.row].representativeItem?.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
            if cell.imageView != nil {
                if let artistImage = artistArtwork.imageWithSize(cell.imageView!.frame.size) {
                    cell.imageView?.image = artistImage
                }
            }
        } else {
            cell.imageView?.image = UIImage(named: "defaultArtwork")
        }
        
        return cell
    }

    
    // MARK: - Navigation
    
    private struct Segues {
        static let ArtistsAlbums = "Show Artist's Albums"
    }


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Segues.ArtistsAlbums {
                if let albumsTVC = segue.destinationViewController as? AlbumsTableViewController {
                    if let cell = sender as? UITableViewCell {
                        let query = MPMediaQuery.albumsQuery()
                        query.addFilterPredicate(MPMediaPropertyPredicate(value: cell.textLabel?.text, forProperty: MPMediaItemPropertyAlbumArtist))
                        albumsTVC.albumsQuery = query
                    }
                }
            }
        }
    }
    

}
