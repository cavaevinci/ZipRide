//
//  ServiceTableViewCell.swift
//  ZipRide
//
//  Created by Ivan Evačić on 10.08.2024..
//

import UIKit
import CoreBluetooth

class ServiceTableViewCell: UITableViewCell {

    let uuidLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    let isPrimaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
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
        contentView.addSubview(isPrimaryLabel)

        uuidLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualTo(isPrimaryLabel.snp.leading).offset(-8)
            make.bottom.equalToSuperview().offset(-8)
        }

        isPrimaryLabel.snp.makeConstraints { make in
            make.centerY.equalTo(uuidLabel)
            make.trailing.equalToSuperview().offset(-16)
        }
    }

    func configure(with service: CBService) {
        uuidLabel.text = "UUID: \(service.uuid)"
        isPrimaryLabel.text = service.isPrimary ? "Primary" : "Secondary"
    }
}
