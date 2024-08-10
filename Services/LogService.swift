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

    func log(_ items: Any...) {
        let message = items.map { item in
            if let describableItem = item as? CustomStringConvertible {
                return describableItem.description
            } else {
                return String(describing: item)
            }
        }.joined(separator: " ")

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

