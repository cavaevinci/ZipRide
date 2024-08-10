//
//  LogService.swift
//  ZipRide
//
//  Created by Ivan Evačić on 09.08.2024..
//

class LogService {
    static let shared = LogService()

    public var logMessages: [String] = []
    private var logViewController: LogViewController?

    private init() { }

    func log(_ message: String) {
        logMessages.append(message)
        print(message)
        logViewController?.updateTableView()
    }

    func showLogs() {
        if logViewController == nil {
            logViewController = LogViewController(logMessages: logMessages)
        }
    }
}

