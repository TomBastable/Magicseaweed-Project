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

    // MARK: - Properties

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tabBar: UITabBar!
    let locationManager = CLLocationManager()
    let lodgeAPIClient = SurfLodgeAPI()
    var results: [SurfLodge]?
    var selectedLocation: CLLocationCoordinate2D?
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: .medium)

    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()

        //get permission to use location services
        locationManager.requestWhenInUseAuthorization()

        //initilise tap recogniser
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.locationSelected))

        //set tap delegate
        tap.delegate = self

        //add tap recogniser to map.
        mapView.addGestureRecognizer(tap)

        //add activity indicator to navigation bar
        let refreshBarButton: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.isHidden = true
        navigationItem.leftBarButtonItem = refreshBarButton
    }

    // MARK: - Location Selected
    ///This function is called when a user taps a location on the map instead of
    ///using their device location or entering a location manually.
    ///Called via a tap gesture recogniser.
    @objc func locationSelected(gestureReconizer: UITapGestureRecognizer) {

        //remove any previous annotations
        mapView.removeAnnotations(mapView.annotations)

        //get tap location
        let location = gestureReconizer.location(in: mapView)

        //convert to coordinate
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

        // init annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        //add annotation
        mapView.addAnnotation(annotation)

        //disable user interaction to save multiple searches from happening
        userInteraction(false)

        //call the api
        getResults(withLocation: coordinate)
    }

    // MARK: - Tab Bar Delegate Methods
    ///DidSelect - Determine if the user is selecting "Use my Location" or "Enter Location"

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //remove any previous annotations
        mapView.removeAnnotations(mapView.annotations)
        // ** USING DEVICE LOCATION ** \\
        if item.tag == 0 {
            //check access permissions
            guard CLLocationManager.locationServicesEnabled() else {
                displayAlertWith(error: LocationError.locationPermissionsError)
                userInteraction(true)
                return
            }
            guard let location = returnDeviceCoordinate() else {
                userInteraction(true)
                return
            }
            processLocationInput(coordinate: location)
            userInteraction(true)
        // ** ENTERING LOCATION MANUALLY ** \\
        } else if item.tag == 1 {
            //prompt the user to input lon / lat
            displayLongLatInput { (coordinate, error) in
                guard let error = error else {
                    guard let coordinate = coordinate else {
                        self.userInteraction(true)
                        return
                    }
                    self.processLocationInput(coordinate: coordinate)
                    self.userInteraction(true)
                    return
                }
                self.userInteraction(true)
                self.displayAlertWith(error: error)
            }
        }
    }

    // MARK: - Process Location Input
    ///Moves the map and manages user interaction after a tab bar input has been actioned
    func processLocationInput(coordinate: CLLocationCoordinate2D) {
        //move map **MUST USE self. Due to completion handler in background**
        self.mapView.moveMapWith(coordinate: coordinate, andScale: 10000)

        //disable user interaction to save multiple searches from happening
        self.userInteraction(false)

        //call the api
        self.getResults(withLocation: coordinate)
    }

    // MARK: - Get Results ++ Change (Would abstract this functionality back to the lodgeAPIclient class)
    ///This function calls the Places API "NearbySearch" endpoint using a given coordinate.
    ///Retrieves an array of modelled results.
    ///Then processes those results through the Places API Details Endpoint in order to
    ///retrieve the opening hours for each result.
    func getResults(withLocation location: CLLocationCoordinate2D) {
        userInteraction(false)
        lodgeAPIClient.getResults(location: location) { (results, location, error) in
            //unwrap results, if not present then error will be present
            guard let results = results, let location = location else {
                self.userInteraction(true)
                DispatchQueue.main.async {
                    self.displayAlertWith(error: error)
                }
                return
            }
            //set properties ready to push to resultsController
            self.results = results
            self.selectedLocation = location
            //results are present and unwrapped - perform segue to the results controller
            self.performSegue(withIdentifier: "resultsSegue", sender: self)
            //enable user interaction
            self.userInteraction(true)
        }
    }

    // MARK: - Enable / Disable User Interaction Functions
    ///These are used when a search is in progress. These have been added to conform to DRY.
    func userInteraction(_ bool: Bool) {
        DispatchQueue.main.async {
            //indicate to the user that the view is processing potential results
            self.activityIndicator.isHidden = bool

            //disable tab bar interaction to avoid clashing
            self.tabBar.isUserInteractionEnabled = bool

            //disable map view interaction to avoid clashing
            self.mapView.isUserInteractionEnabled = bool

            if !bool {
                //disable
                self.activityIndicator.startAnimating()

            } else if bool {
                //enable
                self.activityIndicator.stopAnimating()
                //deselect tab bar ready for fresh input
                self.tabBar.selectedItem = nil

                //remove all any annotations from the map
                self.mapView.removeAnnotations(self.mapView.annotations)
            }
        }
    }

    // MARK: - Prepare for Segue
    ///Manage any properties that need to be shared via the results segue - called when results are present.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        //if the segue is the results segue
        if segue.identifier == "resultsSegue" {

            //initialise the destination ++Change to guard
            guard let destination = segue.destination as? ResultsViewController,
            let results = results, let location = self.selectedLocation else {
                return
            }

            destination.results = results
            destination.location = location

        }
    }
}
