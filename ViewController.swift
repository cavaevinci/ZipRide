//
//  ViewController.swift
//  ZipRide
//
//  Created by Ivan Evačić on 08.08.2024..
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    let scooterConnectionManager = BTConnectionManager()
    
    let manufacturerLabel = UILabel()
    let modelLabel = UILabel()
    let serialNumberLabel = UILabel()
    let hardwareRevisionLabel = UILabel()
    let firmwareRevisionLabel = UILabel()
    let softwareRevisionLabel = UILabel()
    let batteryLevelLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        view.addSubview(manufacturerLabel)
        view.addSubview(modelLabel)
        view.addSubview(serialNumberLabel)
        view.addSubview(hardwareRevisionLabel)
        view.addSubview(firmwareRevisionLabel)
        view.addSubview(softwareRevisionLabel)
        view.addSubview(batteryLevelLabel)
        
        setupConstraints()
        
        scooterConnectionManager.startScanning()
        
        scooterConnectionManager.onScooterInfoUpdated = { [weak self] scooterInfo in
            DispatchQueue.main.async {
                self?.updateUI(with: scooterInfo)
            }
        }
    }
    
    func updateUI(with scooterInfo: ScooterInfo) {
        manufacturerLabel.text = "Manufacturer: \(scooterInfo.manufacturer)"
        modelLabel.text = "Model: \(scooterInfo.model)"
        serialNumberLabel.text = "Serial Number: \(scooterInfo.serialNumber)"
        hardwareRevisionLabel.text = "Hardware Revision: \(scooterInfo.hardwareRevision)"
        firmwareRevisionLabel.text = "Firmware Revision: \(scooterInfo.firmwareRevision)"
        softwareRevisionLabel.text = "Software Revision: \(scooterInfo.softwareRevision)"
        batteryLevelLabel.text = "Battery: \(scooterInfo.batteryLevel)%"
    }
    
    func setupConstraints() {
        manufacturerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)

        }

        modelLabel.snp.makeConstraints { make in
            make.top.equalTo(manufacturerLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        serialNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(modelLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        hardwareRevisionLabel.snp.makeConstraints { make in
            make.top.equalTo(serialNumberLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        firmwareRevisionLabel.snp.makeConstraints { make in
            make.top.equalTo(hardwareRevisionLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        softwareRevisionLabel.snp.makeConstraints { make in
            make.top.equalTo(firmwareRevisionLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        batteryLevelLabel.snp.makeConstraints { make in
            make.top.equalTo(softwareRevisionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

