//
//  Endpoint.swift
//  MSW Surf Lodge Search
//
//  Created by Tom Bastable on 29/02/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import Foundation
import MapKit

// MARK: - API Key. Tester - Please configure the API Key using the property below.
// Paste between the quotation marks after value:
private let apiKey: URLQueryItem = URLQueryItem(name: "key", value: "AIzaSyDVccZszyu_J-hK99LoNS-P9tiaVBZ7xpo")

// MARK: - Endpoint Protocol

protocol Endpoint {

    //base url required
    var base: String { get }

    //url path required
    var path: String { get }

    //query items required
    var queryItems: [URLQueryItem] { get }

}

//extension of Endpoint to add components and request composition
extension Endpoint {

    var urlComponents: URLComponents {

        var components = URLComponents(string: base)!
        components.path = path
        components.queryItems = queryItems

        return components
    }

    var request: URLRequest {

        let url = urlComponents.url!
        return URLRequest(url: url)

    }

}

// MARK: - Lodge URL enum
///contains two cases - Nearby Search and Place Details
enum LodgeURL {

    ///nearby search requires an input of CLLocationCoordinate2D and will return lodges within 1km of that location.
    case nearbySearch(location: CLLocationCoordinate2D)

    ///place detail
    case placeDetails(placeId: String)

}

//extension of LodgeURL to conform to the previously laid out protocol
extension LodgeURL: Endpoint {

    //set base url
    var base: String {
        return "https://maps.googleapis.com"
    }

    //set path for each enum
    var path: String {

        switch self {

        case .nearbySearch: return "/maps/api/place/nearbysearch/json"
        case .placeDetails: return "/maps/api/place/details/json"

        }

    }

    //set the query items for each enum - each always appends the apikey at the end.
    var queryItems: [URLQueryItem] {

    switch self {

    case .nearbySearch(let location):

        var result = [URLQueryItem]()
        //set the location
        let locationItem = URLQueryItem(name: "location", value: "\(location.latitude),\(location.longitude)")
        result.append(locationItem)
        //set the keyword
        let keywordItem = URLQueryItem(name: "keyword", value: "surf")
        result.append(keywordItem)
        //set the type
        let typeItem = URLQueryItem(name: "type", value: "lodging, campground")
        result.append(typeItem)
        //set the radius
        let radiusItem = URLQueryItem(name: "radius", value: "1000")
        result.append(radiusItem)
        //append the api key
        result.append(apiKey)

        return result

    case .placeDetails(let placeId):

        var result = [URLQueryItem]()
        //set the place id query item
        let placeIdItem = URLQueryItem(name: "place_id", value: placeId)
        result.append(placeIdItem)
        //append api key
        result.append(apiKey)

        return result

        }
    }

}
