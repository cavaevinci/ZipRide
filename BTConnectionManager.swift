//
//  BTConnectionManager.swift
//  ZipRide
//
//  Created by Ivan Evačić on 08.08.2024..
//

import Foundation
import CoreBluetooth

class BTConnectionManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    var centralManager: CBCentralManager!
    var scooterPeripheral: CBPeripheral?
    var onScooterInfoUpdated: ((ScooterInfo) -> Void)?
    
    var scooterInfo = ScooterInfo(manufacturer: "", model: "", serialNumber: "",
                                      hardwareRevision: "", firmwareRevision: "",
                                  softwareRevision: "", batteryLevel: 0, speed: 0)
    
    var onPeripheralsDiscovered: (([CBPeripheral]) -> Void)?
    var discoveredPeripherals: [CBPeripheral] = []

    var scanTimer: Timer?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        // Check if Bluetooth is powered on before scanning
        if centralManager.state == .poweredOn {
            print("Bluetooth is powered on, start scanning...")
            scanTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
                        self?.centralManager.scanForPeripherals(withServices: nil, options: nil)
                    }
        } else {
            print("Bluetooth is not powered on.")
            // You might want to handle this case by prompting the user to enable Bluetooth
        }
        
    }
    
    func stopScanning() {
            // Stop the scan timer
            scanTimer?.invalidate()
            scanTimer = nil

            // Stop the actual Bluetooth scan
            centralManager.stopScan()
        }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on, start scanning...")
            centralManager.scanForPeripherals(withServices: nil, options: nil) // Scan for all peripherals
        } else {
            print("Bluetooth is not powered on.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error:
     Error?) {
        if let error = error {
                print("Disconnected fromperipheral: \(peripheral.name ?? "Unknown"), error: \(error.localizedDescription)")
            } else {
                print("Disconnected from peripheral: \(peripheral.name ?? "Unknown")")
            }

            // Remove the disconnected peripheral
            discoveredPeripherals.removeAll(where: { $0.identifier == peripheral.identifier })

            // Notify the ViewController to update the UI
            onPeripheralsDiscovered?(discoveredPeripherals)
        }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(" SVI UREJDAJI ---", peripheral.name)
        /*if peripheral.name == "G4" {
            print("Found Kugoo Kukirin G4, attempting to connect...")
            scooterPeripheral = peripheral
            centralManager.connect(scooterPeripheral!, options: nil)
        }*/
        onPeripheralsDiscovered?([peripheral])
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to Kugoo Kukirin G4!")
        scooterPeripheral!.delegate = self
        scooterPeripheral!.discoverServices(nil) // Discover all services
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to Kugoo Kukirin G4: \(error?.localizedDescription ?? "Unknown error")")
    }
    
    func connect(to peripheral: CBPeripheral) {
        // Stop scanning for new peripherals (optional, but good practice)
        centralManager.stopScan()

        // Store the peripheral and attempt to connect
        scooterPeripheral = peripheral
        centralManager.connect(scooterPeripheral!, options: nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }

        guard let services = peripheral.services else { return }

        for service in services {
            print("Found the relevant service!---", service)
            if service.uuid == CBUUID(string: "FFF0") ||
               service.uuid == CBUUID(string: "180F") ||
               service.uuid == CBUUID(string: "180A") ||
               service.uuid == CBUUID(string: "F000FFC0-0451-4000-B000-000000000000") {

                print("Found the relevant service!---", service)
                peripheral.discoverCharacteristics(nil, for: service)
                break
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            // Replace "CHARACTERISTIC_UUID_TO_READ" with the actual UUID of the characteristic you want to read
            //if characteristic.uuid == CBUUID(string: "CHARACTERISTIC_UUID_TO_READ") {
                print("Found the characteristic to read!")
                print("    - Characteristic UUID: \(characteristic.uuid), Properties: \(characteristic.properties)")
                //peripheral.readValue(for: characteristic)
                if characteristic.uuid == CBUUID(string: "FFF1") {
                    // Introduce a delay before reading FFF1 (optional)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                        self?.scooterPeripheral?.readValue(for: characteristic)
                    }
                } else {
                    peripheral.readValue(for: characteristic)
                }
            //}
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error:
     Error?) {
        if let error = error {
            print("Error changing notification state: \(error.localizedDescription)")
            return
        }

        if characteristic.isNotifying {
            print("Subscribed to notifications for characteristic: \(characteristic.uuid)")
            peripheral.readValue(for: characteristic)
        } else {
            print("Unsubscribed from notifications for characteristic: \(characteristic.uuid)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
            if let error = error {
                // Handle read errors more gracefully
                if let cbError = error as? CBError, cbError.code == .operationNotSupported {
                    print("Characteristic \(characteristic.uuid) is not readable.")
                } else {
                    print("Error reading characteristic value: \(error.localizedDescription)")
                }
                return
            }

        if let data = characteristic.value {
            print(" DATA CHARACTERISINC VALUE ----")
                switch characteristic.uuid {
                case CBUUID(string: "FFF1"):
                    let hexString = data.map { String(format: "%02x", $0) }.joined()
                    print("Characteristic FFF1 Value: 0x\(hexString)")

                    // Attempt to decode and interpret the FFF1 value
                    // You'll need to experiment with different data types and encodings based on your scooter's protocol
                    // Example: Assuming it's a 16-bit unsigned integer representing speed in km/h (little-endian)
                    if data.count >= 2 {
                        let speed = Int(data[0]) + (Int(data[1]) << 8)
                        scooterInfo.speed = speed // Assuming you add a 'speed' property to ScooterInfo
                        print("Speed: \(speed) km/h")
                    } else {
                        print("FFF1 data is not in the expected format.")
                    }
                case CBUUID(string: "2A29"): // Manufacturer Name String
                    scooterInfo.manufacturer = String(data: data, encoding: .utf8) ?? "Unknown"
                    print("Manufacturer: \(scooterInfo.manufacturer)")
                case CBUUID(string: "2A24"): // Model Number String
                    scooterInfo.model = String(data: data, encoding: .utf8) ?? "Unknown"
                    print("Model: \(scooterInfo.model)")
                case CBUUID(string: "2A25"): // Serial Number String
                    scooterInfo.serialNumber = String(data: data, encoding: .utf8) ?? "Unknown"
                    print("Serial Number: \(scooterInfo.serialNumber)")
                case CBUUID(string: "2A27"): // Hardware Revision String
                    scooterInfo.hardwareRevision = String(data: data, encoding: .utf8) ?? "Unknown"
                    print("Hardware Revision: \(scooterInfo.hardwareRevision)")
                case CBUUID(string: "2A26"): // Firmware Revision String
                    scooterInfo.firmwareRevision = String(data: data, encoding: .utf8) ?? "Unknown"
                    print("Firmware Revision: \(scooterInfo.firmwareRevision)")
                case CBUUID(string: "2A28"): // Software Revision String
                    scooterInfo.softwareRevision = String(data: data, encoding: .utf8) ?? "Unknown"
                    print("Software Revision: \(scooterInfo.softwareRevision)")
                case CBUUID(string: "2A19"): // Battery Level
                    if characteristic.isNotifying {
                        // If we're getting notifications, update the battery level
                        scooterInfo.batteryLevel = Int(data.first ?? 0)
                        print("Battery Level (Notification): \(scooterInfo.batteryLevel)%")
                    } else if characteristic.properties.contains(.read) {
                        // If not notifying, attempt a read (might not be necessary if notifications are working)
                        print("Battery Level characteristic is readable. Attempting to read...")
                        peripheral.readValue(for: characteristic)
                    } else {
                        print("Battery Level characteristic is not readable.")
                    }
                    
                // Add more cases for other characteristics as you identify them
                default:
                    // Print raw data for unidentified characteristics
                    let hexString = data.map { String(format: "%02x", $0) }.joined()
                    print("Characteristic UUID: \(characteristic.uuid), Value: 0x\(hexString)")
                }

                // Notify the ViewController about the updated scooterInfo
                onScooterInfoUpdated?(scooterInfo)
            } else {
                // Handle nil values
                print("Characteristic UUID: \(characteristic.uuid), Value: nil (or not yet available)")
            }
    }
}

struct ScooterInfo {
    var manufacturer: String
    var model: String
    var serialNumber: String
    var hardwareRevision: String
    var firmwareRevision: String
    var softwareRevision: String
    var batteryLevel: Int
    var speed: Int
}
