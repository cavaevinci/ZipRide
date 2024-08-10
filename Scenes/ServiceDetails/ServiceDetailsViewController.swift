//
//  ServiceDetailsViewController.swift
//  ZipRide
//
//  Created by Ivan Evačić on 10.08.2024..
//

import UIKit
import CoreBluetooth

class ServiceDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let scooterConnectionManager = BTScooterService()

    let tableView = UITableView()
    var header: Navbar!

    var service: CBService!
    var characteristics: [CBCharacteristic] = []

    init(service: CBService, characteristics: [CBCharacteristic]) {
        self.service = service
        self.characteristics = characteristics
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print("ServiceDetailViewController--_service ", service)
        //print("ServiceDetailViewController--characteristics ", characteristics)
        
        // Set up table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ServiceDetailTableViewCell.self, forCellReuseIdentifier: "ServiceDetailCell")
        view.addSubview(tableView)

        setupHeader()
        setupConstraints()
        
        //connectedPeripheral?.discoverCharacteristics(nil, for: service)
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

}

extension ServiceDetailsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return
 BottomHalfPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
