//
//  Navbar.swift
//  ZipRide
//
//  Created by Ivan Evačić on 09.08.2024..
//

import UIKit

enum NavigationBarStyle {
    case normal
    case godMode
}

protocol NavigationBarProtocol: UIView {
    func setBarStyle(_ style: NavigationBarStyle)
    var didTapGodModeButton: (() -> Void)? { get set }
}

class Navbar: UIView {
    
    var didTapGodModeButton: (() -> Void)?
    
    let currentSceneName = UILabel()
    let godModeButton = UIButton(type: .contactAdd)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupUI() {
        addSubview(currentSceneName)
        addSubview(godModeButton)
        setupConstraints()
    }
    
    func setupConstraints() {
        snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        currentSceneName.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(15)
        }
        
        godModeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-25)
            make.centerY.equalTo(currentSceneName.snp.centerY)
        }
    }
}

extension Navbar: NavigationBarProtocol {
    func setBarStyle(_ style: NavigationBarStyle) {
        switch style {
        case .godMode:
            currentSceneName.text = "ZipRide - GOD MODE"
            godModeButton.isHidden = false
        case .normal:
            currentSceneName.text = "ZipRide"
            godModeButton.isHidden = true
        }
    }
}
