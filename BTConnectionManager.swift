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

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        // Check if Bluetooth is powered on before scanning
        if centralManager.state == .poweredOn {
            print("Bluetooth is powered on, start scanning...")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth is not powered on.")
            // You might want to handle this case by prompting the user to enable Bluetooth
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on, start scanning...")
            centralManager.scanForPeripherals(withServices: nil, options: nil) // Scan for all peripherals
        } else {
            print("Bluetooth is not powered on.")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(" SVI UREJDAJI ---", peripheral.name)
        if peripheral.name == "G4" {
            print("Found Kugoo Kukirin G4, attempting to connect...")
            scooterPeripheral = peripheral
            centralManager.connect(scooterPeripheral!, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to Kugoo Kukirin G4!")
        scooterPeripheral!.delegate = self
        scooterPeripheral!.discoverServices(nil) // Discover all services
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to Kugoo Kukirin G4: \(error?.localizedDescription ?? "Unknown error")")
    }

    // ... (Other delegate methods for handling service discovery, characteristic reads/writes)
    // ... (Inside your ScooterConnectionManager class)

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
                    //break
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
                peripheral.readValue(for: characteristic)
            //}
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

            /*if let data = characteristic.value {
                if characteristic.uuid == CBUUID(string: "2A19") {
                    // Battery Level (already handled)
                    let batteryLevel = data.first ?? 0
                    print("Battery Level: \(batteryLevel)%")
                } else if characteristic.uuid == CBUUID(string: "FFF1") {
                    // Example: Speed in km/h (assuming two bytes, little-endian)
                    let speedData = data.prefix(2) // Get the first two bytes
                    let speed = Int(speedData[0]) + Int(speedData[1]) << 8
                    print("Speed: \(speed) km/h")
                } else {
                    // Handle other characteristics or print raw data
                    let hexString = data.map { String(format: "%02x", $0) }.joined()
                    print("Characteristic UUID: \(characteristic.uuid), Value: 0x\(hexString)")
                }
            }*/
            if let data = characteristic.value {
                // Create an instance of ScooterInfo to store the data
                var scooterInfo = ScooterInfo(manufacturer: "", model: "", serialNumber: "",
                                              hardwareRevision: "", firmwareRevision: "",
                                              softwareRevision: "", batteryLevel: 0)

                switch characteristic.uuid {
                case CBUUID(string: "2A29"): // Manufacturer Name String
                    scooterInfo.manufacturer = String(data: data, encoding: .utf8) ?? "Unknown"
                case CBUUID(string: "2A24"): // Model Number String
                    scooterInfo.model = String(data: data, encoding: .utf8) ?? "Unknown"
                // ... (handle other characteristics similarly)
                case CBUUID(string: "2A19"): // Battery Level
                    scooterInfo.batteryLevel = Int(data.first ?? 0)
                case CBUUID(string: "2A25"): // Serial Number String
                    scooterInfo.serialNumber = String(data: data, encoding: .utf8) ?? "Unknown"
                case CBUUID(string: "2A27"): // Hardware Revision String
                    scooterInfo.hardwareRevision = String(data: data, encoding: .utf8) ?? "Unknown"
                case CBUUID(string: "2A26"): // Firmware Revision String
                    scooterInfo.firmwareRevision = String(data: data, encoding: .utf8) ?? "Unknown"
                case CBUUID(string: "2A28"): // Software Revision String
                    scooterInfo.softwareRevision = String(data: data, encoding: .utf8) ?? "Unknown"
                default:
                    // Handle other characteristics or print raw data for further analysis
                    let hexString = data.map { String(format: "%02x", $0) }.joined()
                    print("Characteristic UUID: \(characteristic.uuid), Value: 0x\(hexString)")
                }

                // Now you have a scooterInfo instance with the updated data
                // You can use this instance to update your UI or perform other actions
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
}
