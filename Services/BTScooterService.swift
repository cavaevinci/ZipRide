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
    var discoveredPeripherals: [CBPeripheral] = []
    private var connectedPeripheral: CBPeripheral?
    // Add a dictionary to store the last discovery time for each peripheral
    private var lastDiscoveredTime: [UUID: Date] = [:]
    
    var onPeripheralsDiscovered: (([CBPeripheral]) -> Void)?
    var onServicesDiscovered: (([CBService]?) -> Void)?
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
    
    func connectToPeripheral(_ peripheral: CBPeripheral, completion: @escaping ([CBService]?) -> Void) {
        // Stop scanning before connecting
        stopScanning()

        // Set the peripheral's delegate to self
        peripheral.delegate = self

        // Connect to the peripheral
        centralManager.connect(peripheral, options: nil)

        // Store the connected peripheral
        connectedPeripheral = peripheral

        LogService.shared.log("Connecting to peripheral: ", peripheral)
        onServicesDiscovered = completion
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
        LogService.shared.log("Connected to peripheral:")
        LogService.shared.log("  Name:", peripheral.name ?? "Unknown")
        LogService.shared.log("  Identifier:", peripheral.identifier.uuidString)
        LogService.shared.log("  State:", peripheral.state.rawValue) // 0 = disconnected, 1 = connecting, 2 = connected
        LogService.shared.log("  Services:", peripheral.services ?? "No services discovered yet")
        stopScanning()
        // You can now start discovering services on the connected peripheral if needed
        peripheral.discoverServices(nil) // Discover all services
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
        // Update the last discovery time for this peripheral
        lastDiscoveredTime[peripheral.identifier] = Date()

        // Periodically check for missing peripherals (e.g., every 5 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.checkForMissingPeripherals()
        }
    }
    
    private func checkForMissingPeripherals() {
        // Define a timeout (e.g., 10 seconds)
        let timeoutInterval: TimeInterval = 5

        // Filter out peripherals that haven't been discovered recently
        discoveredPeripherals = discoveredPeripherals.filter { peripheral in
            if let lastSeen = lastDiscoveredTime[peripheral.identifier] {
                return Date().timeIntervalSince(lastSeen) <= timeoutInterval
            } else {
                return false
            }
        }

        // Notify the view controller to update the UI
        onPeripheralsDiscovered?(discoveredPeripherals)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            LogService.shared.log("Error discovering services: ", error.localizedDescription)
            // Handle the error appropriately (e.g., show an error message to the user)
            return
        }

        guard let services = peripheral.services else {
            LogService.shared.log("No services discovered for peripheral: ", peripheral)
            return
        }
        
        // Call the completion handler with the discovered services
        onServicesDiscovered?(services)

        // Reset the completion handler
        onServicesDiscovered = nil

        for service in services {
            LogService.shared.log("Discovered service: ", service)

            // Discover characteristics for each service
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor
     service: CBService, error: Error?) {
        if let error = error {
            LogService.shared.log("Error discovering characteristics: ", error.localizedDescription)
            return
        }

        guard let characteristics = service.characteristics else {
            LogService.shared.log("No characteristics discovered for service: ", service)
            return
        }
        
        guard let services = peripheral.services else {
            // ... (handle no services case)
            return
        }
        
        onServicesDiscovered?(services)

        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: "2A19") { // Battery Level characteristic UUID
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
     error: Error?) {
        if let error = error {
            LogService.shared.log("Error reading characteristic value: ", error.localizedDescription)
            return
        }

        if characteristic.uuid == CBUUID(string: "2A19") {
            if let batteryLevelData = characteristic.value,
               let batteryLevel = batteryLevelData.first {
                LogService.shared.log("Battery Level: ", batteryLevel, "%")
            } else {
                LogService.shared.log("Invalid battery level data")
            }
        }
    }

}
