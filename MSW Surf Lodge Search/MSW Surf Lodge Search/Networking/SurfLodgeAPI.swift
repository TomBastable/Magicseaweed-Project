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
    
    //MARK: - Properties
    let downloader = JSONDownloader()
    let decoder = JSONDecoder()
    
    //MARK: - Get Lodges
    ///This function takes a coordinate that will be used to find surf lodges local to it. It will then return the results in a completion block.
    func getLodges(location: CLLocationCoordinate2D, completion: @escaping (LodgeResults?, Error?) -> Void) {
        
        //init endpoint
        let endpoint = LodgeURL.nearbySearch(location: location)
        
        //perform request
        performRequest(with: endpoint) { results, error in
            
            //guard data unwrap
            guard let data = results else { completion(nil, error) ; return }
            
            //ensure the decoder exchanges camel case for dashes (eg: placeId = place_id)
            self.decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            //do try catch the decode
            do{
                
                let lodgeArray = try self.decoder.decode(LodgeResults.self, from: data)
                
                //no error, complete with results
                completion(lodgeArray, nil)
                
                //error caught, complete with error
            } catch { completion(nil, error) }
        }
    }
    
    //MARK: - Get Details
    ///This function takes a place id and retrieves more detailed information about that place. It then returns the results. Used only to retrieve Opening hours, however the classes have been modelled for expansion should it be required.
    func getDetails(placeId: String, completion: @escaping (DetailResults?, Error?) -> Void) {
        
        //init endpoint
        let endpoint = LodgeURL.placeDetails(placeId: placeId)
        
        //perform request
        performRequest(with: endpoint) { results, error in
            
            //guard data unwrap
            guard let data = results else { completion(nil, error) ; return }
            
            //ensure the decoder exchanges camel case for dashes (eg: placeId = place_id)
            self.decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            //do try catch the decode
            do{
                
                let detailArray = try self.decoder.decode(DetailResults.self, from: data)
                
                //no error, complete with results
                completion(detailArray, nil)
                
                //error caught, complete with error
            } catch { completion(nil, error) }
        }
    }
    
    //MARK: - Perform Request
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
