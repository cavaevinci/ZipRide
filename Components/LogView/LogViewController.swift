//
//  LogViewController.swift
//  ZipRide
//
//  Created by Ivan Evačić on 09.08.2024..
//

import UIKit

class LogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    let searchBar = UISearchBar()
    var filteredLogMessages: [String] = []
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
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(LogTableViewCell.self, forCellReuseIdentifier: "LogCell")
        view.addSubview(tableView)
        view.addSubview(searchBar)

        searchBar.delegate = self
        searchBar.placeholder = "Search logs"
        navigationItem.titleView = searchBar
        
        filteredLogMessages = logMessages
        
        setupConstraints()
    }
    
    func setupConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()

        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func updateTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - UITableViewDataSource & UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLogMessages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as! LogTableViewCell
        cell.logLabel.text = filteredLogMessages[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredLogMessages = logMessages
        } else {
            filteredLogMessages = logMessages.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }

        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Dismiss the keyboard when the search button is clicked
        searchBar.resignFirstResponder()
    }

}
