//
//  UserInfoHeaderView.swift
//  UberClone
//
//  Created by 박현준 on 2023/07/18.
//

import UIKit
import SnapKit

class UserInfoHeaderView: UIView {
//MARK: - properties
    private let user: User
    
    private lazy var profileFirstNameView: UIView = {
        $0.backgroundColor = .darkGray
        $0.layer.cornerRadius = 64 / 2
        $0.addSubview(initialLabel)
        initialLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        return $0
    }(UIView())
    
    private lazy var initialLabel: UILabel =  {
        $0.font = UIFont.systemFont(ofSize: 42)
        $0.textColor = .white
        $0.text = user.firstInitial
        return $0
    }(UILabel())
    
    private lazy var fullnameLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.text = user.fullname
        return $0
    }(UILabel())
    
    private lazy var emailLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .lightGray
        $0.text = user.email
        return $0
    }(UILabel())
    
//MARK: - Life cycles
    init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)
        setUIandConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - set UI
    private func setUIandConstraints() {
        backgroundColor = .white
        
        addSubview(profileFirstNameView)
        
        profileFirstNameView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
            make.height.width.equalTo(64)
        }
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        addSubview(stack)
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .vertical
        stack.snp.makeConstraints { make in
            make.centerY.equalTo(profileFirstNameView.snp.centerY)
            make.leading.equalTo(profileFirstNameView.snp.trailing).inset(-12)
        }
    }
    
}
