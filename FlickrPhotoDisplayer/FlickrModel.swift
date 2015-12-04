//
//  FlickrModel.swift
//  FlickrPhotoDisplayer
//
//  Created by Harry on 3/12/2015.
//  Copyright © 2015 Snaptee. All rights reserved.
//

import Foundation

let FlickrInfoDownloaded = "FlickrInfoDownloadComplete"
let FlickrPhoto = "FlickrPhoto"

struct Photo {
    var unique: String
    var title: String
    var subtitle: String
    var imageURL: NSURL
    var thumbnailURL: NSURL
    var owner: String

    init(unique: String, title: String, subtitle: String?, owner: String, thumbnailURL: NSURL, imageURL: NSURL) {
        if let s = subtitle {
            self.subtitle = s
        } else {
            self.subtitle = "NO SUBTITLE"
        }
        self.unique = unique
        if title == "" {
            self.title = "NO TITLE"
        } else {
            self.title = title
        }
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
        self.owner = owner
    }
}

class FlickrModel {

    var photographer = [String: [Photo]]()


    init() {
        fetch()
    }

    private func fetch() {
        let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfig.allowsCellularAccess = false
        let session = NSURLSession.init(configuration: sessionConfig)
        let request = NSURLRequest.init(URL: FlickrFetcher.URLforRecentGeoreferencedPhotos()!)
        let task = session.downloadTaskWithRequest(request) { (localFile, response, error) -> Void in
            if let e = error {
                print("Flickr background fetch failed: \(e.localizedDescription)")
            } else {
                if let photos = self.flickrPhotosAtURL(localFile!) {
                    self.loadImagesFromFlickrArray(photos)
                }
            }
        }
        task.resume()
    }


    private func flickrPhotosAtURL(url: NSURL) -> Array<[String: AnyObject]>? {
        let flickrJSONData = NSData.init(contentsOfURL: url)
        guard flickrJSONData != nil else {
            return nil
        }
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(flickrJSONData!, options: []) as! [String: AnyObject]
            let photos = jsonResult["photos"]!
            return photos["photo"] as? Array<[String: AnyObject]>
        } catch let e as NSError {
            print("\(e)")
        }
        return nil
    }

    private func loadImagesFromFlickrArray(photos: Array<[String: AnyObject]>) {
        for photo in photos {
            if let unique = photo[FLICKR_PHOTO_ID] as? String {
                if let title = photo[FLICKR_PHOTO_TITLE] as? String {
                    if let imageURL = FlickrFetcher.URLforPhoto(photo, format: .FlickrPhotoFormatLarge) {
                        if let thumbnailURL = FlickrFetcher.URLforPhoto(photo, format: .FlickrPhotoFormatSquare) {
                            if let photographer = photo[FLICKR_PHOTO_OWNER] as? String {
                                if var photosBelongsTo = self.photographer[photographer] {
                                    photosBelongsTo.append(Photo.init(unique: unique, title: title, subtitle: photo[FLICKR_PHOTO_DESCRIPTION] as? String, owner: photographer, thumbnailURL: thumbnailURL, imageURL: imageURL))
                                    self.photographer[photographer] = photosBelongsTo
                                } else {
                                    self.photographer[photographer] = [Photo.init(unique: unique, title: title, subtitle: photo[FLICKR_PHOTO_DESCRIPTION] as? String, owner: photographer, thumbnailURL: thumbnailURL, imageURL: imageURL)]
                                }
                            }
                        }
                    }
                }
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName(FlickrInfoDownloaded, object: self)
    }

}