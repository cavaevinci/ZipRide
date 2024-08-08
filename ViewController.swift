//
//  ViewController.swift
//  ZipRide
//
//  Created by Ivan Evačić on 08.08.2024..
//

import UIKit

class ViewController: UIViewController {

    let scooterConnectionManager = BTConnectionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        
        scooterConnectionManager.startScanning()
        
        scooterConnectionManager.onScooterInfoUpdated = { [weak self] scooterInfo in
            DispatchQueue.main.async {
                self?.updateUI(with: scooterInfo)
            }
        }
    }
    
    func updateUI(with scooterInfo: ScooterInfo) {
        print(" OVO JE SCOOTER INFO UPDATE UI ---", scooterInfo)
    }
}

