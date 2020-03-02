//
//  LocationsBaseViewController.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 2/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit

// A base class for the Location View Tabs to hold all the common functionality
open class LocationsBaseViewController: UIViewController {

    // MARK: Open Add Location Modal
    internal func openAddLocationModal() {
        // First check if the currently logged in user has already posted a location
        if (LocationModel.studentLocations.contains{$0.uniqueKey == UdacityClient.Session.accountId}) {
            // If they have posted before, display an alert
            let message = "You have already posted a student location. Would you like to Overwrite your current location?"
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertVC.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (action) in
                // Open the Add Location Modal if Overwrite is tapped
                self.performSegue(withIdentifier: "openAddLocationModalSegue", sender: nil)
            }))
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alertVC, animated: true)
        } else {
            // If the user has not posted a location before, directly open the Add Location Modal
            self.performSegue(withIdentifier: "openAddLocationModalSegue", sender: nil)
        }
    }
    
    // MARK: Open URL in Safari
    internal func openMediaLink(_ mediaLink: String?) {
        let mediaUrl = URL(string: mediaLink ?? "")
        if let url = mediaUrl {
            // Try to parse the string to a URL and display an error alert if it is not possible
            UIApplication.shared.open(url, options: [:]) { (success) in
                if (!success) {
                    self.showAlert(title: "Error", message: "Invalid URL")
                }
            }
        } else {
            // Show error alert of the link is empty
            self.showAlert(title: "Error", message: "Invalid URL")
        }
    }
    
    // MARK: Delete Session via API and Logout
    internal func logout() {
        UdacityClient.logout {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Show Alert Utility function
    internal func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true)
    }
}
