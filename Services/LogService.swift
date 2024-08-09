//
//  LogService.swift
//  ZipRide
//
//  Created by Ivan Evačić on 09.08.2024..
//

class LogService {
    static let shared = LogService() // Singleton instance

    public var logMessages: [String] = []
    private var logViewController: LogViewController? // The popup view controller

    private init() { }

    func log(_ message: String) {
        logMessages.append(message)
        logViewController?.updateTableView() // Notify the view controller to refresh
    }

    func showLogs() {
        // Create and present the log view controller if it doesn't exist
        if logViewController == nil {
            logViewController = LogViewController(logMessages: logMessages)
            // Present the logViewController modally or however you prefer
        } else {
            // If it already exists, just bring it to the front
            // (You might need to adjust this based on your presentation style)
        }
    }
}

