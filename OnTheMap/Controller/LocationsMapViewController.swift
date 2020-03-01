//
//  LocationsMapViewController.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 1/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit
import MapKit

class LocationsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (LocationModel.studentLocations.count > 0) {
            populateMapData()
        } else {
            fetchLocationsData()
        }
    }
    
    private func populateMapData() {
        let locations = LocationModel.studentLocations
        var annotations = [MKPointAnnotation]()
        
        for location in locations {

            let lat = CLLocationDegrees(location.latitude)
            let long = CLLocationDegrees(location.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = location.firstName
            let last = location.lastName
            let mediaURL = location.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        self.mapView.showAnnotations(annotations, animated: true)
    }
        
    // MARK: - MKMapViewDelegate

    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
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

    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle {
                let mediaUrl = URL(string: toOpen ?? "")
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
        }
    }
    
    private func handleGetStudentLocationsResponse(success: Bool, error: Error?) {
        activityIndicator.stopAnimating()
        if (success) {
            self.populateMapData()
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
        activityIndicator.startAnimating()
        UdacityClient.getStudentLocations(completion: handleGetStudentLocationsResponse(success:error:))
    }

    @IBAction func openAddLocationModal(_ sender: Any) {
        performSegue(withIdentifier: "openAddLocationModalSegue", sender: nil)
    }
}
