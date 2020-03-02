//
//  LocationsMapViewController.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 1/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit
import MapKit

class LocationsMapViewController: LocationsBaseViewController, MKMapViewDelegate {

    // MARK: Class variables
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Initialise UI
    override func viewDidLoad() {
        super.viewDidLoad()
        // Only fetch the locations if they don't currently exist
        if (LocationModel.studentLocations.count > 0) {
            populateMapData()
        } else {
            fetchLocationsData()
        }
    }
    
    // Update the map with pins
    private func populateMapData() {
        let locations = LocationModel.studentLocations
        
        // Remove previous annotations
        mapView.removeAnnotations(mapView.annotations)
        
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
            
            // Add the annotation to the array of annotations
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        mapView.addAnnotations(annotations)
        // Animate to a location on the map with pins visible
        mapView.showAnnotations(annotations, animated: true)
    }
    
    // Set Map Pins UI
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

    // Handle Map Pin tap to open the URL
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle {
                openMediaLink(toOpen)
            }
        }
    }
    
    // MARK: Handle API Responses
    private func handleGetStudentLocationsResponse(success: Bool, error: Error?) {
        activityIndicator.stopAnimating()
        if success {
            populateMapData()
        } else {
            showAlert(title: "Error", message: error?.localizedDescription ?? "Could not fetch locations")
        }
    }
    
    private func fetchLocationsData() {
        activityIndicator?.startAnimating()
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
