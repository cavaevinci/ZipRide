//
//  LogViewController.swift
//  ZipRide
//
//  Created by Ivan Evačić on 09.08.2024..
//

import UIKit

class LogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var logMessages: [String]
    let tableView = UITableView()

    init(logMessages: [String]) {
        self.logMessages = logMessages
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LogTableViewCell.self, forCellReuseIdentifier: "LogCell")
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // Make the table view fill the entire view
        }
    }
    
    func updateTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - UITableViewDataSource & UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logMessages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as! LogTableViewCell
        cell.logLabel.text = logMessages[indexPath.row]
        return cell
    }

}
