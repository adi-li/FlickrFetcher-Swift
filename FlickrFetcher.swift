//
//  FlickrFetcher.swift
//  FlickrPhotoDisplayer
//
//  Created by Harry on 4/12/2015.
//  Copyright © 2015 Snaptee. All rights reserved.
//

import Foundation

// REVIEW: you deleted the key in  FlickrAPIKey.h but not here...
let FlickrAPIKey = "f3333822775812370a74dc8e72034ad9"

// REVIEW: Constants can be placed inside the class with a struct called Constants.
//         You can use extension to exten the class to store those constants if they are too much.
//         You can also save them in different struct to categorize them.
// key paths to photos or places at top-level of Flickr results
let FLICKR_RESULTS_PHOTOS = "photos.photo"
let FLICKR_RESULTS_PLACES = "places.place"

// keys (paths) to values in a photo dictionary
let FLICKR_PHOTO_TITLE = "title"
let FLICKR_PHOTO_DESCRIPTION = "description._content"
let FLICKR_PHOTO_ID = "id"
let FLICKR_PHOTO_OWNER = "ownername"
let FLICKR_PHOTO_UPLOAD_DATE = "dateupload" // in seconds since 1970
let FLICKR_PHOTO_PLACE_ID = "place_id"

// keys (paths) to values in a places dictionary (from TopPlaces)
let FLICKR_PLACE_NAME = "_content"
let FLICKR_PLACE_ID = "place_id"

// keys applicable to all types of Flickr dictionaries
let FLICKR_LATITUDE = "latitude"
let FLICKR_LONGITUDE = "longitude"
let FLICKR_TAGS = "tags"




let FLICKR_PLACE_NEIGHBORHOOD_NAME = "place.neighbourhood._content"
let FLICKR_PLACE_NEIGHBORHOOD_PLACE_ID = "place.neighbourhood.place_id"
let FLICKR_PLACE_LOCALITY_NAME = "place.locality._content"
let FLICKR_PLACE_LOCALITY_PLACE_ID = "place.locality.place_id"
let FLICKR_PLACE_REGION_NAME = "place.region._content"
let FLICKR_PLACE_REGION_PLACE_ID = "place.region.place_id"
let FLICKR_PLACE_COUNTY_NAME = "place.county._content"
let FLICKR_PLACE_COUNTY_PLACE_ID = "place.county.place_id"
let FLICKR_PLACE_COUNTRY_NAME = "place.country._content"
let FLICKR_PLACE_COUNTRY_PLACE_ID = "place.country.place_id"
let FLICKR_PLACE_REGION = "place.region"



// REVIEW: So as enum, can locate within the class to act namespaced MVC
enum FlickrPhotoFormat: Int {
    // REVIEW: No need to repeat `FlickrPhotoFormat`
    case FlickrPhotoFormatSquare = 1    // thumbnail
    case FlickrPhotoFormatLarge = 2     // normal size
    case FlickrPhotoFormatOriginal = 64  // high resolution
}

class FlickrFetcher {
    // REVIEW: The URL prefix are all the same in `"https://api.flickr.com/services/rest/"`,
    //         why not make them in this function?
    //         Besides, how do you make sure the `query` parameter has `"?"` already?
    class func URLForQuery(query: String) -> NSURL? {
        var q = "\(query)&format=json&nojsoncallback=1&api_key=\(FlickrAPIKey)"
        q = q.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
        // REVIEW: no Need to write `init`, just use `NSURL(string: q)`
        return NSURL.init(string: q)
    }

    class func URLforTopPlaces() -> NSURL? {
        return URLForQuery("https://api.flickr.com/services/rest/?method=flickr.places.getTopPlacesList&place_type_id=7")
    }

    class func URLforPhotosInPlace(flickrPlaceId placeID: String, maxResults max: Int) -> NSURL? {
        return URLForQuery("https://api.flickr.com/services/rest/?method=flickr.photos.search&place_id=\(placeID)&per_page=\(max)&extras=original_format,tags,description,geo,date_upload,owner_name,place_url")
    }

    class func URLforRecentGeoreferencedPhotos() -> NSURL? {
        return URLForQuery("https://api.flickr.com/services/rest/?method=flickr.photos.search&license=1,2,4,7&has_geo=1&extras=original_format,description,geo,date_upload,owner_name")
    }

    // REVIEW: Just use [String: AnyObject] instead of Dictionary<String, AnyObject>,
    //         or use a Photo struct/class may be better
    class func urlStringForPhoto(photo: Dictionary<String, AnyObject>, format: FlickrPhotoFormat) -> String? {
        let farm = photo["farm"]
        let server = photo["server"]
        let photo_id = photo["id"]
        var secret = photo["secret"]
        var fileType = "jpg"
        if format == .FlickrPhotoFormatOriginal {
            secret = photo["originalsecret"]
            if let type = photo["originalformat"] as? String {
                fileType = type
            }
//            fileType = photo["originalformat"]
        }

        guard (farm != nil && server != nil && photo_id != nil && secret != nil) else {
            return nil
        }

        var formatString = "s"

        // REVIEW: Just add a function to the enum so you can just use the enum value to get the string
        switch format {
        case .FlickrPhotoFormatSquare:
            formatString = "s"
        case .FlickrPhotoFormatLarge:
            formatString = "b"
        case .FlickrPhotoFormatOriginal:
            formatString = "o"
        }

        return "https://farm\(farm!).static.flickr.com/\(server!)/\(photo_id!)_\(secret!)_\(formatString).\(fileType)"
    }

    class func URLforPhoto(photo: [String: AnyObject],format: FlickrPhotoFormat) -> NSURL? {
        guard let url =  urlStringForPhoto(photo, format: format) else {
            return nil
        }
        return NSURL.init(string: url)
    }

    class func URLforInformationAboutPlace(flickrPlaceId: AnyObject) -> NSURL? {
        return URLForQuery("https://api.flickr.com/services/rest/?method=flickr.places.getInfo&place_id=\(flickrPlaceId)")
    }

    func extractNameOfPlace(placeId: String, fromPlaceInformation place: [String: String]) -> String? {
        var name: String?

        switch placeId {
        case place[FLICKR_PLACE_NEIGHBORHOOD_PLACE_ID]!:
            name = place["FLICKR_PLACE_NEIGHBORHOOD_NAME"]
        case place[FLICKR_PLACE_LOCALITY_PLACE_ID]!:
            name = place["FLICKR_PLACE_LOCALITY_NAME"]
        case place[FLICKR_PLACE_COUNTY_PLACE_ID]!:
            name = place["FLICKR_PLACE_COUNTY_NAME"]
        case place[FLICKR_PLACE_REGION_PLACE_ID]!:
            name = place["FLICKR_PLACE_REGION_NAME"]
        case place[FLICKR_PLACE_COUNTRY_PLACE_ID]!:
            name = place["FLICKR_PLACE_COUNTRY_NAME"]
        default:
            name = nil
        }
        return name
    }

    class func extractRegionNameFromPlaceInformation(place: [String: String]) -> String {
        return place[FLICKR_PLACE_REGION_NAME]!
    }

}
