//
//  ResultsViewController.swift
//  MSW Surf Lodge Search
//
//  Created by Tom Bastable on 28/02/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import UIKit
import MapKit

class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    var results:[SurfLodge] = []
    var location:CLLocationCoordinate2D?
    var highestRated:SurfLodge?
    
    //MARK: - VWA
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //find the highest rated lodge
        findHighestRated()
        
        //order the results by distance
        orderResultsByDistance()
        
        //results array is now ready to display - reload table view.
        self.tableView.reloadData()
    }
    
    //MARK: - Find Highest Rated
    ///This function sets the highest rated lodge to the highestRated property ready for display within the tableview.
    func findHighestRated(){
        
        //if there's more than one result
        if results.count > 1 {
            
            //find the highest rated result
            highestRated = results.max { $0.rating < $1.rating }
            
        }
    }
    
    //MARK: - Order Results by Distance
    ///Caluclates the distance for each lodge, sets its distance property and finally orders the array by that property.
    func orderResultsByDistance(){
        
        //loop through the results
        for result in results{
            
            //convert lodge coordinates to a CLLocation (CLLocation has a 'distance from' function)
            let lodgeLocation = CLLocation(latitude: result.geometry.location.lat, longitude: result.geometry.location.lng)
            
            //unwrap user location set by the segue
            guard let userLocation = location else { return }
            
            //calculate the distance from the two CLLocations
            let distance = lodgeLocation.distance(from: CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude))
            
            //set the lodges distance property, ready to order the array by that property
            result.distance = distance
        }
        
        //order the array by the distance property via a closure.
        results = results.sorted(by: { $0.distance < $1.distance })
        
    }
    
    //MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //initialise cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "lodgeCell", for: indexPath) as! LodgeTableViewCell
        
        //configure cell
        cell.configureCell(with: results[indexPath.row], userCoordinate:location, highestRated: highestRated)
        
        //return cell
        return cell
    }

}
