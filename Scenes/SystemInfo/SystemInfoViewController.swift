//
//  SystemInfoViewController.swift
//  ZipRide
//
//  Created by Ivan Evačić on 09.08.2024..
//


import UIKit
import SnapKit
import CoreBluetooth

class SystemInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate {
    
    let scooterConnectionManager = BTScooterService()

    let tableView = UITableView()
    var header: Navbar!

    var connectedPeripheral: CBPeripheral?
    var services: [CBService] = []
    var serviceCharacteristics: [CBService: [CBCharacteristic]] = [:]

    init(services: [CBService], connectedPeripheral: CBPeripheral) {
        self.services = services
        self.connectedPeripheral = connectedPeripheral // Store the connected peripheral
        super.init(nibName: nil, bundle: nil)
        for service in services {
            serviceCharacteristics[service] = [] // Initially, no characteristics are discovered
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ServiceTableViewCell.self, forCellReuseIdentifier: "ServiceCell")
        view.addSubview(tableView)
        navigationController?.delegate = self
        setupHeader()
        setupConstraints()
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
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Hide the custom navbar when navigating away from this view controller
        if viewController != self {
            header.isHidden = true
        }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // Show the custom navbar when returning to this view controller
        if viewController == self {
            header.isHidden = false
        }
    }
    
    func setupHeader() {
        navigationController?.navigationBar.isHidden = true
        header = Navbar()
        header.setBarStyle(.godMode)
        header.setTitle("Services")
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
        return services.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceTableViewCell
        cell.configure(with: services[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Get the selected service
        let selectedService = services[indexPath.row]

        // Create the detail view controller and pass only the selected service
        let serviceDetailVC = ServiceDetailsViewController(service: selectedService, connectedPeripheral: connectedPeripheral!)
        navigationController?.pushViewController(serviceDetailVC, animated: true)
    }
}

extension SystemInfoViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return
 BottomHalfPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
