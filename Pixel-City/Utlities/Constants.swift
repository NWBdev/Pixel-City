//
//  Constants.swift
//  Pixel-City
//
//  Created by Nathaniel Burciaga on 3/5/18.
//  Copyright © 2018 Nathaniel Burciaga. All rights reserved.
//

import Foundation

// flickr api key
let apiKey = "a502cc35a8fb9f78fc47a7b734f627fa"

func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    
}

