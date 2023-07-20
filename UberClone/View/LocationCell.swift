//
//  LocationInputCell.swift
//  UberClone
//
//  Created by 박현준 on 2023/05/12.
//

import UIKit
import SnapKit
import MapKit

class LocationCell: UITableViewCell {

//MARK: - Properties
    var placemark: MKPlacemark? {
        didSet {
            titleLabel.text = placemark?.name
            addressLabel.text = placemark?.address // extension MKPlacemark address 
        }
    }
    
    let titleLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 14)
        return $0
    }(UILabel())
    
    private let addressLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .lightGray
        return $0
    }(UILabel())
    
//MARK: - Life cycles
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(12)
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
