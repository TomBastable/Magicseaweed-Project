//
//  SurfLodge.swift
//  MSW Surf Lodge Search
//
//  Created by Tom Bastable on 29/02/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import Foundation

///Distance class - this will be used as a subclass SurfLodge will use. Does not conform to Codable as distance is a property that will be set in code as opposed to through a JSON response. Arrays will be ordered by distance when displayed.
class Distance {
    var distance:Double = 0.0
}

///present to easily parse results via codable. contains an array of SurfLodge.
class LodgeResults: Codable{
    let results: [SurfLodge]?
}

///Contains all surf lodge data relevant to his project. Easy to expand - use camel casing to represent underscores. eg: place_id == placeId.
class SurfLodge: Distance, Codable {
    
    let name:String
    let rating: Double
    let geometry: Geometry
    let placeId: String
    var openingHours: OpeningHours?
    
}

///only used for the lodge location, however this can be expanded to also include Viewport data.
class Geometry:Codable{
    let location: Location
}

///used  to store lat and lng data.
class Location: Codable{
    let lat:Double
    let lng:Double
}

///used to parse the result from the details API
class DetailResults:Codable{
    let result:Details
    
}

///can be expanded heavily, however the only information needed is opening hours, which is modelled further in "OpeningHours"
class Details:Codable{
    let openingHours:OpeningHours?
    let placeId: String
}

///contains a boolean value openNow that easily determines if a place is open at the current Date() and also optionally contains an array of formatted opening times for display.
class OpeningHours:Codable{
    let openNow:Bool?
    let weekdayText:[String]?
}
