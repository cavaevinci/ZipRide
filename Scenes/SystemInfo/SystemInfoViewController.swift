//
//  SystemInfoViewController.swift
//  ZipRide
//
//  Created by Ivan Evačić on 09.08.2024..
//


import UIKit
import SnapKit
import CoreBluetooth

class SystemInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let scooterConnectionManager = BTScooterService()

    let tableView = UITableView()
    var header: Navbar!

    var services: [CBService] = []

    init(services: [CBService]) {
        self.services = services
        super.init(nibName: nil, bundle: nil)
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
    
    func setupHeader() {
        navigationController?.navigationBar.isHidden = true
        header = Navbar()
        header.setBarStyle(.godMode)
        header.setTitle(scooterConnectionManager.connectedPeripheralName ?? "Unknown Device")
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
}

extension SystemInfoViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return
 BottomHalfPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
