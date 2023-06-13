//
//  RideActionView.swift
//  UberClone
//
//  Created by 박현준 on 2023/06/13.
//

import UIKit
import SnapKit

class RideActionView: UIView {

//MARK: - Properties
    private let titleLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 18)
        $0.text = "Test Address Title"
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    private let addressLabel: UILabel = {
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.text = "123 M St, NW Washington DC"
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    lazy var stack: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 4
        $0.distribution = .fillEqually
        return $0
    }(UIStackView(arrangedSubviews: [titleLabel, addressLabel]))
    
    private lazy var infoView: UIView = {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 60/2
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        
        $0.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return $0
    }(UIView())
    
    private let uberXLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 18)
        $0.text = "UBER X"
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    private let seperatorView: UIView = {
        $0.backgroundColor = .lightGray
        return $0
    }(UIView())
    
    private let actionButton: UIButton = {
        $0.backgroundColor = .black
        $0.setTitle("CONFIRM UBERX", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.addTarget(self, action: #selector(actionButtonPress), for: .touchUpInside)
        return $0
    }(UIButton())
    
//MARK: - Life cycles
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUIandConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
//MARK: - set UI
    func setUIandConstraints() {
        backgroundColor = .white
        addShadow()
        
        addSubview(stack)
        addSubview(infoView)
        addSubview(uberXLabel)
        addSubview(seperatorView)
        addSubview(actionButton)
        
        stack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(12)
        }
        infoView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(stack.snp.bottom).inset(-16)
            make.width.height.equalTo(60)
        }
        uberXLabel.snp.makeConstraints { make in
            make.top.equalTo(infoView.snp.bottom).inset(-8)
            make.centerX.equalToSuperview()
        }
        seperatorView.snp.makeConstraints { make in
            make.top.equalTo(uberXLabel.snp.bottom).inset(-4)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.75)
        }
        actionButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(50)
        }
    }

//MARK: - Handler
    @objc func actionButtonPress() {
        print("DEBUG: 12")
    }
    
}
