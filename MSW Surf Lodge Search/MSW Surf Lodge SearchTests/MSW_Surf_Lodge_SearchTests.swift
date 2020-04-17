//
//  MSW_Surf_Lodge_SearchTests.swift
//  MSW Surf Lodge SearchTests
//
//  Created by Tom Bastable on 28/02/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import XCTest
import MapKit
@testable import MSW_Surf_Lodge_Search

class MSWSearchTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNearbyEndpointURL() {
        // This is assuming the API Key is empty. If the API Key is present,
        //please modify the url it should equal or temporarily remove the API key.
        let location = CLLocationCoordinate2D(latitude: 50.41563, longitude: -5.07521)
        let nearbyRequestURL = LodgeURL.nearbySearch(location: location)
        //key will need to be added to the end of the string below
        XCTAssertTrue(nearbyRequestURL.request.description == "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=50.41563,-5.07521&keyword=surf&type=lodging&radius=1000&key=")
    }

    func testNearbyAPICall() {
        //this test needs to be conducted with a valid network connection with an
        //API key installed (Install the API Key in Endpoint.swift // Line 14)
        let surfLodgeAPI = SurfLodgeAPI()
        //call the api
        surfLodgeAPI.getLodges(location: CLLocationCoordinate2D(latitude: 50.41563,
                                                                longitude: -5.07521)) { (_, error) in
            XCTAssertTrue(error == nil)
        }
    }

    func testDetailEndpointURL() {
        // This test case assumes the API Key is empty. If the API Key is present,
        //please modify the url it should equal or temporarily remove the API key.
        let detailsRequestURL = LodgeURL.placeDetails(placeId: "ChIJy7adMN7dakgR47sILhSc5QM")
        //key will need to be added to the end of the string below
        XCTAssertTrue(detailsRequestURL.request.description == "https://maps.googleapis.com/maps/api/place/details/json?place_id=ChIJy7adMN7dakgR47sILhSc5QM&key=")
    }

    func testDetailAPICall() {
        //this test needs to be conducted with a valid network connection
        //with an API key installed (Install the API Key in Endpoint.swift // Line 14)
        let surfLodgeAPI = SurfLodgeAPI()
        //call the API
        surfLodgeAPI.getDetails(placeId: "ChIJy7adMN7dakgR47sILhSc5QM") { (_, error) in
            XCTAssertTrue(error == nil)
        }
    }

}
