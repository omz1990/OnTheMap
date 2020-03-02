//
//  FindLocationViewController.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 1/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit
import CoreLocation

class FindLocationViewController: UIViewController {

    // MARK: Class variables
    @IBOutlet private weak var locationTextField: UITextField!
    @IBOutlet private weak var linkTextField: UITextField!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    private var locationCoords: CLLocationCoordinate2D!
    
    // MARK: UI Listeners
    @IBAction private func findLocationTapped(_ sender: Any) {
        setGeocodingLocation(true)
        getCoordinate(addressString: locationTextField?.text ?? "", completionHandler: handleGeocodingResult(locationCoordinate:error:))
    }
    
    @IBAction private func cancelTapper(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Geocode the provided address
    private func getCoordinate( addressString : String,
            completionHandler: @escaping(CLLocationCoordinate2D?, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                        
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
                
            completionHandler(nil, error as NSError?)
        }
    }
    
    // MARK: Handle API Responses
    private func handleGeocodingResult(locationCoordinate: CLLocationCoordinate2D?, error: NSError?) {
        setGeocodingLocation(false)
        if let location = locationCoordinate {
            self.locationCoords = location
            performSegue(withIdentifier: "confirmLocationSegue", sender: nil)
        } else {
            showAlert(title: "Error", message: error?.localizedDescription ?? "Enter valid location")
        }
    }
    
    // MARK: Class Utility Functions
    private func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true)
    }
    
    // Prepare the data for ConfirmLocationViewController and dispatch segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmLocationSegue" {
            let confirmLocationVC = segue.destination as! ConfirmLocationViewController
            let lat = Float(self.locationCoords?.latitude ?? 0)
            let long = Float(self.locationCoords?.longitude ?? 0)
            let studentInformation = StudentInformation(objectId: UdacityClient.Session.accountId, uniqueKey: UdacityClient.Session.accountId, firstName: UdacityClient.Session.firstName, lastName: UdacityClient.Session.lastName, mapString: locationTextField.text ?? "", mediaURL: linkTextField.text ?? "", latitude: lat, longitude: long, createdAt: "", updatedAt: "")
            confirmLocationVC.studentInformation = studentInformation
        }
    }
    
    // Update the UI state while geocoding is in progress
    private func setGeocodingLocation(_ isGeocoding: Bool) {
        if (isGeocoding) {
            self.activityIndicator?.startAnimating()
        } else {
            self.activityIndicator?.stopAnimating()
        }
        
        self.locationTextField?.isEnabled = !isGeocoding
        self.linkTextField?.isEnabled = !isGeocoding
    }
}
