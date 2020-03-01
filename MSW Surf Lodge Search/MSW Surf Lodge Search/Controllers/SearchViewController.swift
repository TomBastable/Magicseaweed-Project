//
//  SearchViewController.swift
//  MSW Surf Lodge Search
//
//  Created by Tom Bastable on 28/02/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UIViewController, UITabBarDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate {
    
    //MARK: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tabBar: UITabBar!
    let locationManager = CLLocationManager()
    let lodgeAPIClient = SurfLodgeAPI()
    var results:[SurfLodge]?
    var selectedLocation:CLLocationCoordinate2D?
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: .medium)
    
    //MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get permission to use location services
        self.locationManager.requestWhenInUseAuthorization()
        
        //initilise tap recogniser
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.locationSelected))
        
        //set tap delegate
        gestureRecognizer.delegate = self
        
        //add tap recogniser to map.
        mapView.addGestureRecognizer(gestureRecognizer)
        
        //add activity indicator to navigation bar
        let refreshBarButton: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.isHidden = true
        self.navigationItem.leftBarButtonItem = refreshBarButton
    }
    
    //MARK: - Location Selected
    ///This function is called when a user taps a location on the map instead of using their device location or entering a location manually. Called via a tap gesture recogniser.
    @objc func locationSelected(gestureReconizer: UILongPressGestureRecognizer){
        
        //remove any previous annotations
        mapView.removeAnnotations(mapView.annotations)
        
        //get tap location
        let location = gestureReconizer.location(in: mapView)
        
        //convert to coordinate
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        
        // init annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        //add annotation
        mapView.addAnnotation(annotation)
        
        //disable user interaction to save multiple searches from happening
        self.disableUserInteraction()
        
        //call the api
        getResults(withLocation: coordinate)
        
    }
    
    //MARK: - Tab Bar Delegate Methods
    ///DidSelect - Determine if the user is selecting "Use my Location" or "Enter Location"
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        // ** USING DEVICE LOCATION ** \\
        if item.tag == 0{
            
            //remove any previous annotations
            mapView.removeAnnotations(mapView.annotations)
            
            //check access permissions
            if CLLocationManager.locationServicesEnabled() {
                
                switch CLLocationManager.authorizationStatus() {
                    
                    case .restricted, .denied, .notDetermined:
                        //display an alert advising the user to enable location services in settings
                        self.displayAlertWith(error: LocationError.locationPermissionsError)
                        enableUserInteraction()
                        return
                    
                    case .authorizedAlways, .authorizedWhenInUse:
                        //does have access to location services
                        //get device coordinates
                        guard let coordinate = locationManager.location?.coordinate else {
                            //error getting coordinate despite having access - inform user
                            return
                        }
                        //move the map to the users location
                        self.mapView.moveMapWith(coordinate: coordinate, andScale: 10000)
                        
                        //disable user interaction to save multiple searches from happening
                        self.disableUserInteraction()
                        
                        //call the api
                        getResults(withLocation: coordinate)
                    
                @unknown default:
                    break
                    
                }
            //Location services are not enabled
            }else{
                
                //display an alert advising the user to enable location services in settings
                self.displayAlertWith(error: LocationError.locationPermissionsError)
                
            }
            
        // ** ENTERING LOCATION MANUALLY ** \\
        }else if item.tag == 1{
            //remove any previous annotations
            mapView.removeAnnotations(mapView.annotations)
            
            //prompt the user to input lon / lat
            self.displayLongLatInput { (coordinate, error) in
                
                //if there's no error
                if error == nil{
                    
                    //unwrap optional coordinate
                    guard let coordinate = coordinate else{ return }
                    
                    //move map
                    self.mapView.moveMapWith(coordinate: coordinate, andScale: 10000)
                    
                    //disable user interaction to save multiple searches from happening
                    self.disableUserInteraction()
                    
                    //call the api
                    self.getResults(withLocation: coordinate)
                    
                //Error is present
                }else{
                    //display error
                    guard let error = error else { return }
                    self.displayAlertWith(error: error)
                    
                    //re enable user interaction
                    self.enableUserInteraction()
                }
                
            }
        }
    }
    
    //MARK: - Get Results
    ///This function calls the Places API "NearbySearch" endpoint using a given coordinate. Retrieves an array of modelled results. Then processes those results through the Places API Details Endpoint in order to retrieve the opening hours for each result.
    func getResults(withLocation location: CLLocationCoordinate2D){
        
        //call API
        lodgeAPIClient.getLodges(location: location) { (results, error) in
            
            //no error present
            if error == nil{
                
                //safely unwrap results
                guard let results = results?.results else { return }
                
                //check if results are empty
                if results.isEmpty {
                    
                    //dispatch to main thread
                    DispatchQueue.main.async {
                        
                        //display error to user
                        self.displayAlertWith(error: LocationError.noResults)
                        self.enableUserInteraction()
                    }
                    return
                }
                //initialise Dispatch Group to manage an async loop
                let detailGroup = DispatchGroup()
                
                //begin looping through results to retrieve opening hour details from the detail endpoint
                for i in 0...results.count - 1{
                    
                    //enter Dispatch Group
                    detailGroup.enter()
                    
                    //call API Details Endpoint
                    self.lodgeAPIClient.getDetails(placeId: results[i].placeId) { (details, error) in
                        
                        //assign current result
                        let result = results[i]
                        
                        //set the opening hours
                        result.openingHours = details?.result.openingHours
                        
                        //leave the dispatch group
                        detailGroup.leave()
                    }
                }
                //use the dispatch group to process next steps in the main queue once all details have been retrieved.
                detailGroup.notify(queue: .main) {
                    
                    //set properties ready to push to resultsController
                    self.results = results
                    self.selectedLocation = location
                    
                    //results are present and unwrapped - perform segue to the results controller
                    self.performSegue(withIdentifier: "resultsSegue", sender: self)
                    
                    //enable user interaction after pushing segue
                    self.enableUserInteraction()
                    
                }
                
            //error is present
            }else{
                //unwrap error
                guard let error = error else { return }
                
                //display error
                DispatchQueue.main.async {
                    
                    self.displayAlertWith(error: error)
                    
                }
                
                //re enable user interaction
                self.enableUserInteraction()
            }
        }
    }
    
    
    //MARK: - Enable / Disable User Interaction Functions
    ///These are used when a search is in progress. These have been added to conform to DRY.
    
    func enableUserInteraction(){
        
        DispatchQueue.main.async {
            //indicate to the user that the view has stopped processing data
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            
            //re enable tab bar interaction
            self.tabBar.isUserInteractionEnabled = true
            
            //re enable map interaction
            self.mapView.isUserInteractionEnabled = true
            
            //deselect tab bar ready for fresh input
            self.tabBar.selectedItem = nil
            
            //remove all any annotations from the map
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }

    func disableUserInteraction(){
        
        //indicate to the user that the view is processing potential results
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        //disable tab bar interaction to avoid clashing
        self.tabBar.isUserInteractionEnabled = false
        
        //disable map view interaction to avoid clashing
        self.mapView.isUserInteractionEnabled = false
    }
    
    //MARK: - Prepare for Segue
    ///Manage any properties that need to be shared via the results segue - called when results are present.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //if the segue is the results segue
        if segue.identifier == "resultsSegue" {
            
            //initialise the destination
            let destination = segue.destination as! ResultsViewController
            
            //set the results to the destination controller, after unwrapping the optionals
            guard let results = self.results, let location = self.selectedLocation else { return }
            destination.results = results
            destination.location = location
            
        }
    }

}
