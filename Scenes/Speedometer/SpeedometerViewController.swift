//
//  SpeedometerViewController.swift
//  ZipRide
//
//  Created by Ivan Evačić on 25.08.2024..
//

import UIKit
import SwiftUI
import CoreLocation

class SpeedometerViewController: UIViewController, CLLocationManagerDelegate {
        
    private let locationManager = CLLocationManager()
    private var hostingController = UIHostingController(rootView: ContentView())
    @State private var value = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        hostingController = UIHostingController(rootView: ContentView(value: value))

        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print(" LOCATION ---", location)
            let speed = location.speed * 3.6 // Convert m/s to km/h
            print(" speed ---", speed)
            let w = 10.0
            value = w
             value = 50
            print(" value ---", value)

            //value = 20
            print(" SPEED---", speed)
        }
    }
    
}
