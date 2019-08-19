//
//  ViewController.swift
//  GeoFenceManager
//
//  Created by datt on 29/11/18.
//  Copyright © 2018 datt. All rights reserved.
//

import UIKit
import MapKit

struct Annotation {
    let title : String
    let coordinate : CLLocationCoordinate2D
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    // set initial location in Honolulu
    let initialLocation = CLLocation(latitude: 35.702701251324285, longitude: 139.83813956844944)
    let annotations = [
        // water gate
        Annotation(title: "a", coordinate: CLLocationCoordinate2D(latitude: 35.69250927401511,
                                                                  longitude: 139.82028564064484)),
        // cross bridge
        Annotation(title: "b", coordinate: CLLocationCoordinate2D(latitude: 35.69388432949502,
                                                                  longitude: 139.83427211440693)),
        // cross pizza
        Annotation(title: "c", coordinate: CLLocationCoordinate2D(latitude: 35.69424303572127,
                                                                  longitude: 139.84347374188195)),
        // longway gate
        Annotation(title: "d", coordinate: CLLocationCoordinate2D(latitude: 35.69334626713055,
                                                                  longitude: 139.8532642735155)),
        // kameido gate
        Annotation(title: "e", coordinate: CLLocationCoordinate2D(latitude: 35.700128975589266,
                                                                  longitude: 139.84160178262596)),
        // bt-way gate
        Annotation(title: "f", coordinate: CLLocationCoordinate2D(latitude: 35.70326212347548,
                                                                  longitude: 139.83540040508683)),
        // view point
        Annotation(title: "g", coordinate: CLLocationCoordinate2D(latitude: 35.71104063674558,
                                                                  longitude: 139.83868889559488)),
        // end of bt-way
        Annotation(title: "h", coordinate: CLLocationCoordinate2D(latitude: 35.713670545610285,
                                                                  longitude: 139.8339776623277))
    ]

    
    @objc func handleTap(_ gestureReconizer: UILongPressGestureRecognizer)
    {
        
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: self.mapView)
        
        // Add annotation:
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinate
//        self.mapView.addAnnotation(annotation)
        
        
        print( coordinate )
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGeoFenceObserver()
        GeoFenceManager.shared.startLocation()
        centerMapOnLocation(location: initialLocation)
        GeoFenceManager.shared.stopAllMonitoringGeoFence()
        for obj in annotations {
            let annotation = MKPointAnnotation()
            annotation.title = obj.title
            annotation.coordinate = obj.coordinate
            mapView.addAnnotation(annotation)
            _ = GeoFenceManager.shared.startMonitoringGeoFence(radius: 100, location: obj.coordinate, identifier: obj.title, data: [:])
        }
        
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        gestureRecognizer.delegate = self
        self.mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    let regionRadius: CLLocationDistance = 5000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    fileprivate func addGeoFenceObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.GeoFenceDidEnterRegion(_:)), name:  NSNotification.Name(rawValue: GeoFenceManager.NotificationCenterGeoFenceDidEnterRegion), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.GeoFenceDidExitRegion(_:)), name:  NSNotification.Name(rawValue: GeoFenceManager.NotificationCenterGeoFenceDidExitRegion), object: nil)
    }
    
    @objc func GeoFenceDidEnterRegion(_ notification: NSNotification) {
        print(notification.userInfo ?? "")
        if let dict = notification.userInfo as NSDictionary? {
            if  let identifier = dict["identifier"] as? String /*,let _ = dict["data"] as? [String:Any] */ {
                self.showToast(message: "You Entered the Region: \(identifier)")
            }
        }
    }
    @objc func GeoFenceDidExitRegion(_ notification: NSNotification) {
        print(notification.userInfo ?? "")
        if let dict = notification.userInfo as NSDictionary? {
            if let identifier = dict["identifier"] as? String /*,let _ = dict["data"] as? [String:Any] */ {
                self.showToast(message: "You Left the Region: \(identifier)")
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-100, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}
