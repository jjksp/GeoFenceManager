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

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    // set initial location in Honolulu
    let initialLocation = CLLocation(latitude: 35.64703911754285, longitude: 139.72100891066896)
    let annotations = [
        Annotation(title: "a", coordinate: CLLocationCoordinate2D(latitude: 35.657039976178427, longitude: 139.7020093657471)),
        Annotation(title: "b", coordinate: CLLocationCoordinate2D(latitude: 35.647039224276535,
                                                                  longitude: 139.656100511702883)),
        Annotation(title: "c", coordinate: CLLocationCoordinate2D(latitude: 35.67603911754285,
                                                                  longitude: 139.721009891066896)),
        Annotation(title: "d", coordinate: CLLocationCoordinate2D(latitude: 35.678039433015687, longitude: 139.70100995833742)),
        Annotation(title: "e", coordinate: CLLocationCoordinate2D(latitude: 35.637039224276535,
                                                                  longitude: 139.7710095827881)),
        Annotation(title: "f", coordinate: CLLocationCoordinate2D(latitude: 35.617039325842233,
                                                                  longitude: 139.7200091911255)),
        Annotation(title: "g", coordinate: CLLocationCoordinate2D(latitude: 35.60703954577244, longitude: 139.74100961428225)),
        Annotation(title: "h", coordinate: CLLocationCoordinate2D(latitude: 35.687039800894, longitude: 139.70110946614992))
    ]
    
    
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
        
    }
    
    let regionRadius: CLLocationDistance = 15000
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
