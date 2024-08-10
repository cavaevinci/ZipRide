//
//  BTScooterService.swift
//  ZipRide
//
//  Created by Ivan Evačić on 09.08.2024..
//

import Foundation
import CoreBluetooth

class BTScooterService: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    private var centralManager: CBCentralManager!
    var onPeripheralsDiscovered: (([CBPeripheral]) -> Void)?
    var discoveredPeripherals: [CBPeripheral] = []
    private var connectedPeripheral: CBPeripheral?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Bluetooth Scanning
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            LogService.shared.log("Bluetooth is not powered on.")
            return
        }

        initiateScanning()
    }

    private func initiateScanning() {
        LogService.shared.log("Bluetooth is powered on, start scanning...")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func stopScanning() {
        centralManager.stopScan()
        LogService.shared.log("Bluetooth - stop scanning")
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        // Stop scanning before connecting
        stopScanning()

        // Set the peripheral's delegate to self
        peripheral.delegate = self

        // Connect to the peripheral
        centralManager.connect(peripheral, options: nil)

        // Store the connected peripheral
        connectedPeripheral = peripheral

        LogService.shared.log("Connecting to peripheral: ", peripheral)
    }

    // MARK: - CBCentralManagerDelegate Methods
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            LogService.shared.log("Bluetooth is powered on.")
            initiateScanning()
        case .poweredOff:
            LogService.shared.log("Bluetooth is powered off.")
        case .unauthorized:
            LogService.shared.log("Bluetooth is unauthorized. Please enable it in Settings.")
        default:
            break
        }
    }
    
    // Handle successful connection
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        LogService.shared.log("Connected to peripheral: ", peripheral)

        // You can now start discovering services on the connected peripheral if needed
        // peripheral.discoverServices(nil)
    }

    // Handle connection failure
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        LogService.shared.log("Failed to connect to peripheral: ", peripheral, "Error: ", error?.localizedDescription ?? "Unknown error")
        // Handle the connection failure appropriately (e.g., show an error message to the user)
    }

    // Handle disconnection
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        LogService.shared.log("Disconnected from peripheral: ", peripheral, "Error: ", error?.localizedDescription ?? "No error")
        // Handle the disconnection (e.g., reset the connectedPeripheral property, allow reconnection)
        connectedPeripheral = nil
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) && peripheral.name != nil {
            LogService.shared.log("Discovered peripheral:", peripheral)
            discoveredPeripherals.append(peripheral)
            onPeripheralsDiscovered?(discoveredPeripherals)
        }
    }

}
