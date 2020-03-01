//
//  LodgeTableViewCell.swift
//  MSW Surf Lodge Search
//
//  Created by Tom Bastable on 29/02/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import UIKit
import MapKit

class LodgeTableViewCell: UITableViewCell {
    
    //MARK: - Properties

    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var openingHoursLabel: UILabel!
    @IBOutlet weak var highestRatedLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    let lodgeAPIClient = SurfLodgeAPI()
    
    //MARK: - Configure Cell
    ///This function allows for the cell to be setup from the data source using a single line of code. This also ensures that you're conforming to MVC by allowing the cell (read: View) to manage its own contents.
    
    func configureCell(with lodge:SurfLodge, userCoordinate:CLLocationCoordinate2D?, highestRated:SurfLodge?){
        
        // ** NAME AND RATING ** \\
        //Set the name and rating properties
        nameLabel.text = lodge.name
        ratingLabel.text = "\(lodge.rating)"
        
        
        // ** HIGHEST RATED ** \\
        //check for highestrated surfLodge
        if let highestRated = highestRated {
            
            //check if the current lodge is the highest rated
            if highestRated.placeId == lodge.placeId{
                
                //if it is, show the highest rated label
                self.highestRatedLabel.isHidden = false
                
            }
        }
        
        // ** DISTANCE FROM LOCATION ** \\
        //safely unwrap coordinate
        guard let userCoordinate = userCoordinate else { return }
        
        //create CLLocation for lodge coordinate
        let lodgeLocation = CLLocation(latitude: lodge.geometry.location.lat, longitude: lodge.geometry.location.lng)
        
        //create CLLocation for user coordinate
        let userLoc = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        
        //get the distance between the two points (METERS)
        var distance = lodgeLocation.distance(from: userLoc)
        distanceLabel.text = String(format: "%.2f meters from location", distance)
        if distance > 1000 { distance = distance / 1000 ; distanceLabel.text = String(format: "%.2fkm from location", distance) }
        
        //convert to Miles from meters(Uncomment code and comment out the km code above)
        //let miles = distance * 0.000621371
        //distanceLabel.text = String(format: "%.2f miles from location", miles)
        
        
        // ** OPENING HOURS ** \\
        //safely unwrap opening hours and current day number
        guard let openingHours = lodge.openingHours?.weekdayText, let dayNumber = Date().dayNumberOfWeek() else{ return }
        
        //deal with the current day number to align with the Places API format
        var day = dayNumber - 2
        if dayNumber == 1 {
            day = 6
        }
        
        //set the opening hours to the label
        self.openingHoursLabel.text = openingHours[day]
        
        
        // ** IS OPEN OR CLOSED BOOL LABEL ** \\
        //check to see if isOpen is present
        guard let isOpen = lodge.openingHours?.openNow else { return }
        
        //if the lodge is open
        if isOpen {
            
            //unhide the label
            self.openLabel.isHidden = false
            
            //set the text
            self.openLabel.text = "OPEN"
            
            //set the background colour
            self.openLabel.backgroundColor = .green
            
        }else {
            //unhide the label
            self.openLabel.isHidden = false
            
            //set the text
            self.openLabel.text = "CLOSED"
            
            //set the background colour
            self.openLabel.backgroundColor = .red
        }
        
    }
    
    //MARK: - Prepare for cell reuse
    ///the cell is about to be reused, so you need to hide the open label and reset the opening hours text.
    override func prepareForReuse() {
        super.prepareForReuse()

        self.openingHoursLabel.text = "No Opening Hours Available"
        self.highestRatedLabel.isHidden = true
        self.openLabel.isHidden = true
    }

}
