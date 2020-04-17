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

    // MARK: - Properties

    @IBOutlet weak var tableView: UITableView!
    var results: [SurfLodge] = []
    var location: CLLocationCoordinate2D?
    var highestRated: SurfLodge?

    // MARK: - VWA

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        //find the highest rated lodge
        if results.count > 1 {
            highestRated = results.max { $0.rating < $1.rating }
        }

        //order the results by distance
        //unwrap user location set by the segue
        guard let userLocation = location else {
            return
        }

        results.orderByDistanceWith(userLocation: userLocation)

        //results array is now ready to display - reload table view.
        tableView.reloadData()
    }

    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //initialise cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "lodgeCell",
                                                       for: indexPath) as? LodgeTableViewCell else {
            return UITableViewCell()
        }

        //configure cell
        cell.configureCellWith(lodge: results[indexPath.row], userCoordinate: location,
                               highestRated: highestRated)

        //return cell
        return cell
    }

}
