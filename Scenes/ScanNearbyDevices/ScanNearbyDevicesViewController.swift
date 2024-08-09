import UIKit
import CoreBluetooth

class ScanNearbyDevicesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let scooterConnectionManager = BTScooterService()

    let tableView = UITableView()
    var header: NavigationBarProtocol!

    var discoveredPeripherals: [CBPeripheral] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupHeader()
        setupConstraints()

        scooterConnectionManager.onPeripheralsDiscovered = { [weak self] newPeripherals in
            DispatchQueue.main.async {
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
        header = Navbar()
        header.setBarStyle(.godMode)
        view.addSubview(header)
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
        print(" Selected peripheral - ", selectedPeripheral)
    }
}

