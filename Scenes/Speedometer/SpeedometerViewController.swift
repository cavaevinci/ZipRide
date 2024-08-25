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
    
    @State private var value = 25.0
    
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        let hostingController = UIHostingController(rootView: GaugeView(coveredRadius: 225, maxValue: 100, steperSplit: 10, value: $value))

        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let speed = location.speed * 3.6 // Convert m/s to km/h
            value = speed
        }
    }
}
