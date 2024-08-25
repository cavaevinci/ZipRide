//
//  AppTypeViewController.swift
//  ZipRide
//
//  Created by Ivan Evačić on 25.08.2024..
//

import UIKit

class AppTypeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    func setupUI() {
        let buttonStackView = UIStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 40
        
        let buttonSize = CGSize(width: 250, height: 250)
        
        let bluetoothButton = UIButton(type: .custom)
        bluetoothButton.setImage(UIImage(systemName: "app.connected.to.app.below.fill"), for: .normal)
        bluetoothButton.addTarget(self, action: #selector(bluetoothButtonTapped), for: .touchUpInside)
        bluetoothButton.frame = CGRect(origin: .zero, size: buttonSize)
        
        let gaugeButton = UIButton(type: .custom)
        gaugeButton.setImage(UIImage(named: "gaugeIcon"), for: .normal)
        gaugeButton.setImage(UIImage(systemName: "gauge.open.with.lines.needle.33percent.and.arrowtriangle.from.0percent.to.50percent"), for: .normal)
        gaugeButton.addTarget(self, action: #selector(gaugeButtonTapped), for: .touchUpInside)
        gaugeButton.frame = CGRect(origin: .zero, size: buttonSize)
        
        let bluetoothLabel = UILabel()
        bluetoothLabel.text = "Connect"
        bluetoothLabel.textAlignment = .center
        bluetoothLabel.font = UIFont.systemFont(ofSize: 16)
        
        let gaugeLabel = UILabel()
        gaugeLabel.text = "Speedometer"
        gaugeLabel.textAlignment = .center
        gaugeLabel.font = UIFont.systemFont(ofSize: 16)
        
        let buttonLabelStackView = UIStackView()
        buttonLabelStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonLabelStackView.axis = .vertical
        buttonLabelStackView.spacing = 25
        
        buttonLabelStackView.addArrangedSubview(bluetoothButton)
        buttonLabelStackView.addArrangedSubview(bluetoothLabel)
        
        let buttonLabelStackView2 = UIStackView()
        buttonLabelStackView2.translatesAutoresizingMaskIntoConstraints = false
        buttonLabelStackView2.axis = .vertical
        buttonLabelStackView2.spacing = 25
        
        buttonLabelStackView2.addArrangedSubview(gaugeButton)
        buttonLabelStackView2.addArrangedSubview(gaugeLabel)
        
        buttonStackView.addArrangedSubview(buttonLabelStackView)
        buttonStackView.addArrangedSubview(buttonLabelStackView2)
        
        view.addSubview(buttonStackView)
        
        buttonStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    @objc func bluetoothButtonTapped() {
        print("Bluetooth button tapped!")
        let systemInfoVC = ScanNearbyDevicesViewController()
        self.navigationController?.pushViewController(systemInfoVC, animated: true)
    }

    @objc func gaugeButtonTapped() {
        print("Gauge button tapped!")
        let systemInfoVC = SpeedometerViewController()
        self.navigationController?.pushViewController(systemInfoVC, animated: true)
    }

}
