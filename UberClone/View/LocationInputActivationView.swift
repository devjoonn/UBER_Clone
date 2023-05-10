//
//  LocationInputActivationView.swift
//  UberClone
//
//  Created by 박현준 on 2023/05/10.
//

import UIKit
import SnapKit

protocol LocationInputActivationViewDelegate: AnyObject {
    func presentLocationInputView()
}

class LocationInputActivationView: UIView {
    
    weak var delegate: LocationInputActivationViewDelegate?
    
//MARK: - UI Components
    private let indicatorView: UIView = {
        $0.backgroundColor = .black
        return $0
    }(UIView())
    
    private let placeholerLabel: UILabel = {
        $0.text = "where to?"
        $0.font = UIFont.systemFont(ofSize: 18)
        $0.textColor = .darkGray
        return $0
    }(UILabel())
    
    
    
    
//MARK: - Life cycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setUIandConstraints()
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentLocationInputView))
        addGestureRecognizer(tap)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - set UI
    func setUIandConstraints() {
        layer.shadowColor = UIColor .black.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
        
        addSubview(indicatorView)
        addSubview(placeholerLabel)
        
        indicatorView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
            make.height.width.equalTo(6)
        }
        placeholerLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(indicatorView.snp.trailing).inset(-20)
        }
    }
    
//MARK: - helper
    @objc func presentLocationInputView() {
        delegate?.presentLocationInputView()
    }
}
