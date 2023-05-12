//
//  LocationInputView.swift
//  UberClone
//
//  Created by 박현준 on 2023/05/11.
//

import UIKit
import SnapKit

protocol LocationInputViewDelegate: AnyObject {
    func dismissLocationInputView()
}

class LocationInputView: UIView {
    
    var user: User? {
        didSet { self.titleLabel.text = user?.fullname }
    }
    
    weak var delegate: LocationInputViewDelegate?
    
//MARK: - UI Components
    private let backButton: UIButton = {
        $0.setImage(UIImage(named: "baseline_arrow_back")?.withRenderingMode(.alwaysOriginal), for: .normal)
        $0.addTarget(self, action: #selector(handleBackTapped), for:.touchUpInside)
        return $0
    }(UIButton())
    
    private let titleLabel: UILabel = {
        $0.text = "박현준"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .darkGray
        return $0
    }(UILabel())
    
    private let startLocationIndicatorView: UIView = {
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 3
        return $0
    }(UIView())
    
    private let linkingView: UIView = {
        $0.backgroundColor = .darkGray
        return $0
    }(UIView())
    
    private let desinationIndicatorView: UIView = {
        $0.backgroundColor = .black
        return $0
    }(UIView())
    
    private lazy var startingLocationTextField: UITextField = {
        $0.placeholder = "Current Location"
        $0.backgroundColor = .groupTableViewBackground
        $0.isEnabled = false
        $0.font = UIFont.systemFont(ofSize: 14)
        
        let paddingView = UIView()
        paddingView.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(8)
        }
        $0.leftView = paddingView
        $0.leftViewMode = .always
        return $0
    }(UITextField())
    
    private lazy var destinationLocationTextField: UITextField = {
        $0.placeholder = "Enter a destination"
        $0.backgroundColor = .lightGray
        $0.returnKeyType = .search
        $0.font = UIFont.systemFont(ofSize: 14)
        
        let paddingView = UIView()
        paddingView.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(8)
        }
        $0.leftView = paddingView
        $0.leftViewMode = .always
        return $0
    }(UITextField())
    
//MARK: - Life cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setUIandConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - set UI
    func setUIandConstraints() {
        addShadow()
        
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(startLocationIndicatorView)
        addSubview(linkingView)
        addSubview(desinationIndicatorView)
        addSubview(startingLocationTextField)
        addSubview(destinationLocationTextField)
        
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(46)
            make.leading.equalToSuperview().inset(12)
            make.width.equalTo(24)
            make.height.equalTo(25)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY)
            make.centerX.equalToSuperview()
        }
        startingLocationTextField.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).inset(-4)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(30)
        }
        destinationLocationTextField.snp.makeConstraints { make in
            make.top.equalTo(startingLocationTextField.snp.bottom).inset(-12)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(30)
        }
        startLocationIndicatorView.snp.makeConstraints { make in
            make.centerY.equalTo(startingLocationTextField.snp.centerY)
            make.leading.equalToSuperview().inset(20)
            make.height.width.equalTo(6)
        }
        desinationIndicatorView.snp.makeConstraints { make in
            make.centerY.equalTo(destinationLocationTextField.snp.centerY)
            make.leading.equalToSuperview().inset(20)
            make.height.width.equalTo(6)
        }
        linkingView.snp.makeConstraints { make in
            make.centerX.equalTo(startLocationIndicatorView.snp.centerX)
            make.top.equalTo(startLocationIndicatorView.snp.bottom).inset(-4)
            make.bottom.equalTo(desinationIndicatorView.snp.top).inset(-4)
            make.width.equalTo(0.4)
        }
        
    }
    
    
//MARK: - handler
    @objc func handleBackTapped() {
        delegate?.dismissLocationInputView()
    }
}
