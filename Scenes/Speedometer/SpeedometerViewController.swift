//
//  SpeedometerViewController.swift
//  ZipRide
//
//  Created by Ivan Evačić on 25.08.2024..
//

import UIKit

class SpeedometerViewController: UIViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()

        let test = GaugeView(frame: CGRect(x: 40, y: 40, width: 256, height: 256))
        test.backgroundColor = .clear
        view.addSubview(test)
        
        test.translatesAutoresizingMaskIntoConstraints = false
        test.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(256)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 1) {
                test.value = 33
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 1) {
                test.value = 66
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 1) {
                test.value = 0
            }
        }
        
    }
}
