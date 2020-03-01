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
    var studentInformation: StudentLocation!

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
        self.dismiss(animated: true, completion: nil)
    }
}
