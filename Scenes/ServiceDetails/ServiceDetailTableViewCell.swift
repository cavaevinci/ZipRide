//
//  ServiceDetailTableViewCell.swift
//  ZipRide
//
//  Created by Ivan Evačić on 10.08.2024..
//

import UIKit
import CoreBluetooth

class ServiceDetailTableViewCell: UITableViewCell {

    let uuidLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    let valueLabel: UILabel = {
       let label = UILabel()
       label.font = UIFont.systemFont(ofSize: 14, weight: .light)
       label.numberOfLines = 0
       return label
   }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(uuidLabel)
        contentView.addSubview(valueLabel)

        uuidLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(uuidLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(uuidLabel)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    func configure(with characteristic: CBCharacteristic) {
        print(" config --", characteristic)
        uuidLabel.text = "UUID: \(characteristic.uuid)"

        // Display the characteristic value or a placeholder
        if let value = characteristic.value {
            // Convert the value to a human-readable string if possible
            if let stringValue = String(data: value, encoding: .utf8) {
                valueLabel.text = "Value: \(stringValue)"
            } else {
                // If not a string, display the raw bytes in hex format
                valueLabel.text = "Value: \(value.hexEncodedString())"
            }
        } else {
            valueLabel.text = "Value: (null)"
        }
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
