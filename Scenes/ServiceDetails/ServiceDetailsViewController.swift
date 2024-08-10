//
//  ServiceDetailsViewController.swift
//  ZipRide
//
//  Created by Ivan Evačić on 10.08.2024..
//

import UIKit
import CoreBluetooth

class ServiceDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CBPeripheralDelegate {
    
    let scooterConnectionManager = BTScooterService()

    let tableView = UITableView()
    var header: Navbar!

    var service: CBService!
    var connectedPeripheral: CBPeripheral?
    var characteristics: [CBCharacteristic] = []

    init(service: CBService, connectedPeripheral: CBPeripheral) {
        self.service = service
        self.connectedPeripheral = connectedPeripheral
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        connectedPeripheral?.delegate = self // Set the delegate
        print("ServiceDetailViewController--_service ", service as Any)
        
        // Set up table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ServiceDetailTableViewCell.self, forCellReuseIdentifier: "ServiceDetailCell")
        view.addSubview(tableView)

        setupHeader()
        setupConstraints()
        
        connectedPeripheral?.discoverCharacteristics(nil, for: service)
    }
    
    func setupConstraints() {
        header?.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.top.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(header.snp.bottom)
        }
    }
    
    func setupHeader() {
        navigationController?.navigationBar.isHidden = true
        header = Navbar()
        header.setBarStyle(.godMode)
        header.setTitle(service.uuid.uuidString)
        view.addSubview(header)
        observeHeader()
    }
    
    func observeHeader() {
        header?.didTapGodMode = { [weak self] in
            guard let self else { return }
            let logVC = LogViewController(logMessages: LogService.shared.logMessages)
            logVC.modalPresentationStyle = .custom
            logVC.transitioningDelegate = self

            present(logVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characteristics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceDetailCell", for: indexPath) as! ServiceDetailTableViewCell
        cell.configure(with: characteristics[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            LogService.shared.log("Error discovering characteristics: ", error.localizedDescription)
            return
        }

        // Update the characteristics array and reload the table view
        characteristics = service.characteristics ?? []
        tableView.reloadData()

        // Read values for characteristics with the "read" property
        for characteristic in characteristics where characteristic.properties.contains(.read) {
            connectedPeripheral?.readValue(for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            LogService.shared.log("Error reading characteristic value: ", error.localizedDescription)
            return
        }

        if let index = characteristics.firstIndex(of: characteristic) {
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
}

extension ServiceDetailsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return
 BottomHalfPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
