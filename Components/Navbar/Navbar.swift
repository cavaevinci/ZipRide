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
    var didTapGodMode: (() -> Void)? { get set }
}

class Navbar: UIView {
    
    var didTapGodMode: (() -> Void)?
    
    lazy var currentSceneName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "ZipRide"
        return label
    }()
    
    lazy var godModeButton: UIButton = {
        let button = UIButton(type: .contactAdd)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapGodModeButton), for: .touchUpInside)
        button.setImage(UIImage(systemName: "list.bullet.clipboard"), for: .normal)
        button.tintColor = .white
        return button
    }()

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
    
    @objc func didTapGodModeButton() {
        didTapGodMode?()
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
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
    }
}

extension Navbar: NavigationBarProtocol {
    
    func setBarStyle(_ style: NavigationBarStyle) {
        switch style {
        case .godMode:
            currentSceneName.text = "ZipRide-GODMODE"
            godModeButton.isHidden = false
            LogService.shared.log("SET GODMODE")
        case .normal:
            currentSceneName.text = "ZipRide"
            godModeButton.isHidden = true
            LogService.shared.log("SET NORMALMODE")
        }
    }
}

