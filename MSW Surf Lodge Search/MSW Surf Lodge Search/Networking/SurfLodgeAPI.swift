//
//  SurfLodgeAPI.swift
//  MSW Surf Lodge Search
//
//  Created by Tom Bastable on 29/02/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import Foundation
import MapKit
class SurfLodgeAPI {

    // MARK: - Properties
    let downloader = JSONDownloader()
    let decoder = JSONDecoder()

    func getResults(location: CLLocationCoordinate2D,
                    completion: @escaping ([SurfLodge]?, CLLocationCoordinate2D?, Error?) -> Void) {

        //call API
        getLodges(location: location) { (results, error) in

            //no error present
            if error == nil {

                //safely unwrap results
                guard let results = results?.results else { return }

                //check if results are empty
                if results.isEmpty {
                    completion(nil, nil, LocationError.noResults)
                    return
                }
                //initialise Dispatch Group to manage an async loop
                let detailGroup = DispatchGroup()

                //begin looping through results to retrieve opening hour details from the detail endpoint
                for resultCount in 0...results.count - 1 {

                    //enter Dispatch Group
                    detailGroup.enter()

                    //call API Details Endpoint
                    self.getDetails(placeId: results[resultCount].placeId) { (details, _) in

                        //assign current result
                        let result = results[resultCount]

                        //set the opening hours
                        result.openingHours = details?.result.openingHours

                        //leave the dispatch group
                        detailGroup.leave()
                    }
                }
                //use the dispatch group to process next steps in the main queue once all details have been retrieved.
                detailGroup.notify(queue: .main) {
                    completion(results, location, nil)
                }

            //error is present
            } else {
                completion(nil, nil, error)
            }
        }
    }

    // MARK: - Get Lodges
    ///This function takes a coordinate that will be used to find surf lodges local to it.
    ///It will then return the results in a completion block.
    private func getLodges(location: CLLocationCoordinate2D, completion: @escaping (LodgeResults?, Error?) -> Void) {

        //init endpoint
        let endpoint = LodgeURL.nearbySearch(location: location)

        //perform request
        performRequest(with: endpoint) { results, error in

            //guard data unwrap
            guard let data = results else { completion(nil, error) ; return }

            //ensure the decoder exchanges camel case for dashes (eg: placeId = place_id)
            self.decoder.keyDecodingStrategy = .convertFromSnakeCase

            //do try catch the decode
            do {
                let lodgeArray = try self.decoder.decode(LodgeResults.self, from: data)

                //no error, complete with results
                completion(lodgeArray, nil)

                //error caught, complete with error
            } catch { completion(nil, error) }
        }
    }

    // MARK: - Get Details
    ///This function takes a place id and retrieves more detailed information about that place.
    ///It then returns the results. Used only to retrieve Opening hours.
    ///However the classes have been modelled for expansion should it be required.
    private func getDetails(placeId: String, completion: @escaping (DetailResults?, Error?) -> Void) {

        //init endpoint
        let endpoint = LodgeURL.placeDetails(placeId: placeId)

        //perform request
        performRequest(with: endpoint) { results, error in

            //guard data unwrap
            guard let data = results else { completion(nil, error) ; return }

            //ensure the decoder exchanges camel case for dashes (eg: placeId = place_id)
            self.decoder.keyDecodingStrategy = .convertFromSnakeCase

            //do try catch the decode
            do {
                let detailArray = try self.decoder.decode(DetailResults.self, from: data)

                //no error, complete with results
                completion(detailArray, nil)

                //error caught, complete with error
            } catch { completion(nil, error) }
        }
    }

    // MARK: - Perform Request
    ///unavailable for use elsewhere - internally used to handle a jsontask.
    private func performRequest(with endpoint: Endpoint, completion: @escaping (Data?, LocationError?) -> Void) {
         //start task with inputted endpoint urlrequest
         let task = downloader.jsonTask(with: endpoint.request) { json, error in
                //guard the data response
                 guard let json = json else {
                    //error unwrapping - complete with error
                     completion(nil, error)
                     return
                 }
                //no error, complete with data
                 completion(json, nil)
         }
         //resume task.
         task.resume()

     }
}
