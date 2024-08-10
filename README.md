# ZipRide Bluetooth Scooter App

This is a Swift-based iOS app that allows users to scan for nearby Bluetooth Low Energy (BLE) devices, connect to them, and discover their services and characteristics. The app is specifically designed to work with e-scooters, but it can be adapted to connect to other BLE devices as well. 

## Features

* Scans for nearby BLE devices and displays them in a table view
* Connects to a selected device
* Discovers and displays the device's services and characteristics
* Reads the battery level and other device information (if available)
* Provides a log view to display debug messages

## Technologies Used

* Swift
* UIKit
* CoreBluetooth
* SnapKit (for Auto Layout constraints)

## Setup

1. Clone the repository.
2. Open the project in Xcode.
3. Build and run the app on a physical iOS device (Bluetooth communication is not supported on the simulator).
4. Make sure Bluetooth is enabled on your device.
5. The app will start scanning for nearby BLE devices.
6. Tap on a device in the table view to connect and view its services and characteristics.

## Customization

* To connect to a specific type of device, you might need to modify the scanning parameters (e.g., service UUIDs) in the `BTScooterService` class.
* To interact with specific characteristics on the connected device, you'll need to refer to its Bluetooth specification or documentation and implement the appropriate read/write/notify operations in the `BTScooterService` and/or `SystemInfoViewController`.
* You can customize the UI and add more features based on your specific requirements.

## Contributing

Feel free to contribute to this project by submitting pull requests or reporting issues.
