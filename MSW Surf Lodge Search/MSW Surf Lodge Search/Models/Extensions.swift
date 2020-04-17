//
//  Extensions.swift
//  MSW Surf Lodge Search
//
//  Created by Tom Bastable on 29/02/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    ///simplified function that moves the location of a map, sets a pin
    ///and displays a geofenced circle around the location.
    func moveMapWith(coordinate: CLLocationCoordinate2D, andScale scale: Double) {

        //create region
        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: scale, longitudinalMeters: scale)
        //display region
        self.setRegion(viewRegion, animated: true)
        //add geofenced circle
        let circle = MKCircle(center: coordinate, radius: 50)
        self.addOverlay(circle)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.addAnnotation(annotation)

        //show user location
        self.showsUserLocation = true

    }

}

extension UIViewController {
    ///displays a UIAlert which takes in Longitude and Latitude
    ///To Enable the User to manually search for lodges in a specific location.
    func displayLongLatInput(completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        let title: String = "Enter Location"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        //add the alerts OK action:
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            //empty long and lats initialised
            var long = ""
            var lat = ""
            //check if longitude text field is present
            if let textField1 = alert.textFields?[0] {
                if textField1.text == "" {
                    //empty coordinate
                    completion(nil, LocationError.fillOutAllFields)
                    return
                } else {
                    //unwrap longitude text
                    guard let longText = textField1.text else {return}
                    //assign longitude text
                    long = longText
                }
            } else {
                //error retrieving textfield
                completion(nil, LocationError.fillOutAllFields)
                return
            }
            //check if latitude text field is present
            if let textField2 = alert.textFields?[1] {
                if textField2.text == "" {
                    //empty coordinate
                    completion(nil, LocationError.fillOutAllFields)
                    return
                } else {
                    //unwrap latitude text
                    guard let latText = textField2.text else {return}
                    //assign latitude text
                    lat = latText
                }
            } else {
                //error retrieving second text field
                completion(nil, LocationError.fillOutAllFields)
                return
            }
            //ensure both long and lat are not blank
            if long != "" && lat != ""{
                //safely cast to doubles
                guard let longitude = Double(long), let latitude = Double(lat) else {
                    completion(nil, LocationError.coordinateError)
                    return
                }
                //create the coordinate
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                //check if coordinate is valid
                if CLLocationCoordinate2DIsValid(coordinate) {
                    //if the coordinate's valid - complete with coordinate
                    completion(coordinate, nil)
                } else {
                    //coordinate is invalid
                    completion(nil, LocationError.coordinateError)
                    return
                }}}))

        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            completion(nil, LocationError.userCancelledInput)
        }))
        alert.addTextField { (textField) in
            textField.placeholder = "Longitude"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Latitude"
        }
        self.present(alert, animated: true)
    }}

extension UIViewController {
///displays a UIAlert which shows the localised error message.
func displayAlertWith(error: Error?) {
    let title: String = "MSW"
    let subTitle: String = error != nil ? error!.localizedDescription : "Unkown Error"
    let buttonTitle: String = "OK"

    let alert = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)

    alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))

    self.present(alert, animated: true)

}

    func returnDeviceCoordinate() -> CLLocationCoordinate2D? {

        switch CLLocationManager.authorizationStatus() {
        case .restricted, .denied, .notDetermined:
            //display an alert advising the user to enable location services in settings
            displayAlertWith(error: LocationError.locationPermissionsError)
            return nil

        case .authorizedAlways, .authorizedWhenInUse:
            //does have access to location services
            //get device coordinates
            guard let coordinate = CLLocationManager().location?.coordinate else {
                //error getting coordinate despite having access - inform user
                displayAlertWith(error: LocationError.locationPermissionsError)
                return nil
            }
            return coordinate
        @unknown default:
            //display an alert advising the user to enable location services in settings
            return nil
        }
    }

}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}

extension Array where Element: SurfLodge {
    mutating func orderByDistanceWith(userLocation: CLLocationCoordinate2D) {
        //loop through the results
        for result in self {

            //convert lodge coordinates to a CLLocation (CLLocation has a 'distance from' function)
            let lodgeLocation = CLLocation(latitude: result.geometry.location.lat,
                                           longitude: result.geometry.location.lng)

            //calculate the distance from the two CLLocations
            let distance = lodgeLocation.distance(from: CLLocation(latitude: userLocation.latitude,
                                                                   longitude: userLocation.longitude))

            //set the lodges distance property, ready to order the array by that property
            result.distance = distance
        }

        //order the array by the distance property via a closure.
        self = self.sorted(by: { $0.distance < $1.distance })
    }
}
