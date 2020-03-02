//
//  ConfirmLocationViewController.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 1/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit
import MapKit

class ConfirmLocationViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapVIew: MKMapView!
    var studentInformation: StudentInformation!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateMapData()
    }
    
    private func populateMapData() {
        var annotations = [MKPointAnnotation]()
        
        let lat = CLLocationDegrees(studentInformation.latitude)
        let long = CLLocationDegrees(studentInformation.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = studentInformation.mapString
        
        annotations.append(annotation)
        
        self.mapVIew.addAnnotation(annotation)
        // Zoom into the selected location
        self.mapVIew.showAnnotations(annotations, animated: true)
        // Make sure the title is shown without having to tap the pin
        self.mapVIew.selectAnnotation(annotation, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    @IBAction func finishTapped(_ sender: Any) {
        setSendingData(true)
        if (LocationModel.studentLocations.contains{$0.uniqueKey == UdacityClient.Session.accountId}) {
            let currentStudentInformation = LocationModel.studentLocations.filter{ $0.uniqueKey == UdacityClient.Session.accountId }.first
            if let objectId = currentStudentInformation?.objectId {
                self.studentInformation.objectId = objectId
                UdacityClient.updateStudentLocation(studentInformation: studentInformation, completion: handleUpdateStudentLocationResponse(success:error:))
            }
            
        } else {
            UdacityClient.postStudentLocation(studentInformation: studentInformation, completion: handlePostStudentLocationResponse(objectId:error:))
        }
    }
    
    private func handlePostStudentLocationResponse(objectId: String?, error: Error?) {
        setSendingData(false)
        if let objectId = objectId {
            self.studentInformation.objectId = objectId
            LocationModel.studentLocations.insert(self.studentInformation, at: 0)
            self.dismiss(animated: true, completion: nil)
        } else {
            showAlert(title: "Error", message: error?.localizedDescription ?? "Could not send location. Try again.")
        }
    }
    
    private func handleUpdateStudentLocationResponse(success: Bool, error: Error?) {
        setSendingData(false)
        if (success) {
            LocationModel.studentLocations = LocationModel.studentLocations.filter { $0.uniqueKey != UdacityClient.Session.accountId }
            LocationModel.studentLocations.insert(self.studentInformation, at: 0)
            self.dismiss(animated: true, completion: nil)
        } else {
            showAlert(title: "Error", message: error?.localizedDescription ?? "Could not update location. Try again.")
        }
    }
    
    private func setSendingData(_ isSending: Bool) {
        if (isSending) {
            self.activityIndicator?.startAnimating()
        } else {
            self.activityIndicator?.stopAnimating()
        }
        self.finishButton?.isEnabled = !isSending
    }
    
    private func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true)
    }
}
