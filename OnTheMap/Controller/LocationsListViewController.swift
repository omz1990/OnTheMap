//
//  LocationsListViewController.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 1/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit

class LocationsListViewController: LocationsBaseViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Class variables
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: Initialise UI
    override func viewDidLoad() {
        super.viewDidLoad()
        // Only fetch the locations if they don't currently exist
        if (LocationModel.studentLocations.count == 0) {
            fetchLocationsData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationModel.studentLocations.count
    }
    
    // Update the table with data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StudentLocationCell = tableView.dequeueReusableCell(withIdentifier: "StudentLocationCell") as! StudentLocationCell
        let studentLocation = LocationModel.studentLocations[indexPath.row]
        cell.name?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell.link?.text = studentLocation.mediaURL
        cell.selectionStyle = .none
        return cell
    }
    
    // Handle Table Cell tap to open the URL
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = LocationModel.studentLocations[indexPath.row]
        openMediaLink(studentLocation.mediaURL)
    }
    
    private func handleGetStudentLocationsResponse(success: Bool, error: Error?) {
        activityIndicator.stopAnimating()
        if (success) {
            self.tableView.reloadData()
        } else {
            showAlert(title: "Error", message: error?.localizedDescription ?? "Could not fetch locations")
        }
    }
    
    // MARK: Handle API Responses
    private func fetchLocationsData() {
        self.activityIndicator?.startAnimating()
        UdacityClient.getStudentLocations(completion: handleGetStudentLocationsResponse(success:error:))
    }
    
    // MARK: UI Listeners
    @IBAction private func refreshLocatioData(_ sender: Any) {
        fetchLocationsData()
    }
    
    @IBAction private func openAddLocationModalTapped(_ sender: Any) {
        openAddLocationModal()
    }
    
    @IBAction private func logoutTapped(_ sender: Any) {
        logout()
    }
}
