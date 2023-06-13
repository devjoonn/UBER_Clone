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
    let titleLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.text = "Test Address Title"
        return $0
    }(UILabel())
    
    let addressLabel: UILabel = {
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.text = "123 M St, NW Washington DC"
        return $0
    }(UILabel())
    
    lazy var stack: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 4
        $0.distribution = .fillEqually
        return $0
    }(UIStackView(arrangedSubviews: [titleLabel, addressLabel]))
    
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
        
        stack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(12)
        }
    }

}
