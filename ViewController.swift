import UIKit
import CoreBluetooth

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let scooterConnectionManager = BTConnectionManager()

    // UI elements
    let tableView = UITableView()

    // Data source for the table view (discovered peripherals)
    var discoveredPeripherals: [CBPeripheral] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up UI elements
        setupUI()

        // Check Bluetooth State
        checkBluetoothState()

        // Set up callback for scooter info updates
        /*scooterConnectionManager.onScooterInfoUpdated = { [weak self] scooterInfo in
            DispatchQueue.main.async {
                // Handle scooterInfo update (transition to another screen)
            }
        }*/

        // Set up callback for discovered peripherals
        scooterConnectionManager.onPeripheralsDiscovered = { [weak self] newPeripherals in
            DispatchQueue.main.async {
                // Filter out peripherals without names
                let namedPeripherals = newPeripherals.filter { $0.name != nil }

                // Merge new named peripherals with existing ones, avoiding duplicates
                for peripheral in namedPeripherals {
                    if !self!.discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
                        self?.discoveredPeripherals.append(peripheral)
                    }
                }

                self?.tableView.reloadData()
            }
        }

    }

    func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: "DeviceCell")
        view.addSubview(tableView)

        // Set up constraints using SnapKit or other layout methods
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // Fill the entire view
        }
    }

    func checkBluetoothState() {
        // ... (implementation from previous response)
    }

    func showBluetoothOffAlert() {
        // ... (implementation from previous response)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeripherals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceTableViewCell
        let peripheral = discoveredPeripherals[indexPath.row]
        cell.nameLabel.text = peripheral.name ?? "Unknown Device"
        // Configure other UI elements in the cell if you've added any
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row
        let selectedPeripheral = discoveredPeripherals[indexPath.row]
        scooterConnectionManager.connect(to: selectedPeripheral)
        let systemInfoVC = SystemInfoViewController()
        systemInfoVC.scooterInfo = scooterConnectionManager.scooterInfo // Pass the scooterInfo object
        navigationController?.pushViewController(systemInfoVC, animated: true)
    }
}

class DeviceTableViewCell: UITableViewCell {
    let nameLabel = UILabel()
    // Add more UI elements as needed (e.g., RSSI label, connection status indicator)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(nameLabel)

        // Set up constraints for nameLabel (use SnapKit or other layout methods)
        nameLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10) // Add some padding
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
