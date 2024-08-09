//
//  DeviceTableViewCell.swift
//  ZipRide
//
//  Created by Ivan Evačić on 09.08.2024..
//

import UIKit

class DeviceTableViewCell: UITableViewCell {
    let nameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(nameLabel)

        nameLabel.snp.makeConstraints { make in
            make.height.equalTo(80)
            
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
