//
//  BTScooterService.swift
//  ZipRide
//
//  Created by Ivan Evačić on 09.08.2024..
//

import Foundation
import CoreBluetooth

class BTScooterService: NSObject, CBCentralManagerDelegate {

    private var centralManager: CBCentralManager!
    var onPeripheralsDiscovered: (([CBPeripheral]) -> Void)?
    var discoveredPeripherals: [CBPeripheral] = []

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Bluetooth Scanning
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth is not powered on.")
            return
        }

        initiateScanning()
    }

    private func initiateScanning() {
        print("Bluetooth is powered on, start scanning...")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func stopScanning() {
        centralManager.stopScan()
    }

    // MARK: - CBCentralManagerDelegate Methods
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on.")
            initiateScanning()
        case .poweredOff:
            print("Bluetooth is powered off.")
        case .unauthorized:
            print("Bluetooth is unauthorized. Please enable it in Settings.")
        default:
            break
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) && peripheral.name != nil {
            print("Discovered peripheral: \(peripheral.name ?? "Unknown")")
            discoveredPeripherals.append(peripheral)
            onPeripheralsDiscovered?(discoveredPeripherals)
        }
    }

}
