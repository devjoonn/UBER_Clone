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
    weak var delegate: LocationInputViewDelegate?
    
//MARK: - UI Components
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "baseline_arrow_back")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for:.touchUpInside)
        return button
    }()
    
    
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
        
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(44)
            make.leading.equalToSuperview().inset(12)
            make.width.equalTo(24)
            make.height.equalTo(25)
        }
    }
    
    
//MARK: - handler
    @objc func handleBackTapped() {
        delegate?.dismissLocationInputView()
    }
}
