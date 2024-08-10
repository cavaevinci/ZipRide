import UIKit
import CoreBluetooth

class ScanNearbyDevicesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let scooterConnectionManager = BTScooterService()

    let tableView = UITableView()
    var header: Navbar!

    var discoveredPeripherals: [CBPeripheral] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupHeader()
        setupConstraints()

        scooterConnectionManager.onPeripheralsDiscovered = { [weak self] newPeripherals in
            DispatchQueue.main.async {
                LogService.shared.log("Discovered new peripheral", newPeripherals.description)
                self?.discoveredPeripherals = newPeripherals
                self?.tableView.reloadData()
            }
        }
        scooterConnectionManager.startScanning()
    }

    func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: "DeviceCell")
        view.addSubview(tableView)
    }
    
    func setupHeader() {
        navigationController?.navigationBar.isHidden = true
        header = Navbar()
        header.setBarStyle(.godMode)
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

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeripherals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceTableViewCell
        let peripheral = discoveredPeripherals[indexPath.row]
        cell.nameLabel.text = peripheral.name ?? "Unknown Device"
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPeripheral = discoveredPeripherals[indexPath.row]
        LogService.shared.log("Selected peripheral:", selectedPeripheral)
        
        // Connect to the peripheral and handle the discovered services
       scooterConnectionManager.connectToPeripheral(selectedPeripheral) { [weak self] services in
           guard let self = self else { return }

           DispatchQueue.main.async {
               if let services = services {
                   let systemInfoVC = SystemInfoViewController(services: services)
                   self.navigationController?.pushViewController(systemInfoVC, animated: true)
               } else {
                   // Handle the case where service discovery failed (e.g., show an error message)
               }
           }
       }
    }

}

extension ScanNearbyDevicesViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return
 BottomHalfPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

