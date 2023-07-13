//
//  MenuHeaderView.swift
//  UberClone
//
//  Created by 박현준 on 2023/07/13.
//

import UIKit
import SnapKit

class MenuHeaderView: UIView {

//MARK: - properties
    
    var user: User? {
        didSet {
            fullnameLabel.text = user?.fullname
            emailLabel.text = user?.email
        }
    }
    
    private let profileImageView: UIImageView = {
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 64 / 2
        return $0
    }(UIImageView())
    
    private let fullnameLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .white
        $0.text = "박현준"
        return $0
    }(UILabel())
    
    private let emailLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .lightGray
        $0.text = "test@test.com"
        return $0
    }(UILabel())
    
//MARK: - Life cycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setUIandConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - set UI
    private func setUIandConstraints() {
        addSubview(profileImageView)
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.leading.equalToSuperview().inset(12)
            make.height.width.equalTo(64)
        }
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        addSubview(stack)
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .vertical
        stack.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView.snp.centerY)
            make.leading.equalTo(profileImageView.snp.trailing).inset(-12)
        }
    }
}
