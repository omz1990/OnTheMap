//
//  LocationsListViewController.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 1/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit

class LocationsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (LocationModel.studentLocations.count == 0) {
            fetchLocationsData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationModel.studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StudentLocationCell = tableView.dequeueReusableCell(withIdentifier: "StudentLocationCell") as! StudentLocationCell
        let studentLocation = LocationModel.studentLocations[indexPath.row]
        cell.name?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell.link?.text = studentLocation.mediaURL
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = LocationModel.studentLocations[indexPath.row]
        openMediaLink(studentLocation.mediaURL)
    }
    
    private func openMediaLink(_ mediaLink: String?) {
        let mediaUrl = URL(string: mediaLink ?? "")
        if let url = mediaUrl {
            UIApplication.shared.open(url, options: [:]) { (success) in
                if (!success) {
                    self.showAlert(title: "Error", message: "Invalid URL")
                }
            }
        } else {
            self.showAlert(title: "Error", message: "Invalid URL")
        }
    }
    
    private func handleGetStudentLocationsResponse(success: Bool, error: Error?) {
        activityIndicator.stopAnimating()
        if (success) {
            self.tableView.reloadData()
        } else {
            self.showAlert(title: "Error", message: error?.localizedDescription ?? "Could not fetch locations")
        }
    }
    
    @IBAction func refreshLocatioData(_ sender: Any) {
        fetchLocationsData()
    }
    
    private func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true)
    }
    
    private func fetchLocationsData() {
        self.activityIndicator?.startAnimating()
        UdacityClient.getStudentLocations(completion: handleGetStudentLocationsResponse(success:error:))
    }
    
    @IBAction func openAddLocationModal(_ sender: Any) {
        if (LocationModel.studentLocations.contains{$0.uniqueKey == UdacityClient.Session.accountId}) {
            let message = "You have already posted a student location. Would you like to Overwrite your current location?"
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "openAddLocationModalSegue", sender: nil)
            }))
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alertVC, animated: true)
        } else {
            self.performSegue(withIdentifier: "openAddLocationModalSegue", sender: nil)
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        UdacityClient.logout {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
