//
//  RideActionView.swift
//  UberClone
//
//  Created by 박현준 on 2023/06/13.
//

import UIKit
import SnapKit
import MapKit

protocol RideActionViewDelegate: class {
    func uploadTrip(_ view: RideActionView)
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case pickupPassenger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction {
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var description: String {
        switch self {
        case .requestRide:
            return "CONFIRM UBER X"
        case .cancel:
            return "CANCEL RIDE"
        case .getDirections:
            return "GET DIRECTIONS"
        case .pickup:
            return "PICKUP PASSENGER"
        case .dropOff:
            return "DROP OFF PASSENGER"
        }
    }
    
    init() {
        self = .requestRide
    }
}

class RideActionView: UIView {

    weak var delegate: RideActionViewDelegate?
    var config = RideActionViewConfiguration()
    var buttonAction = ButtonAction()

    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
//MARK: - Properties
    private let titleLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 18)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    private let addressLabel: UILabel = {
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 16)
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
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
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
        delegate?.uploadTrip(self) 
    }
    
    
//MARK: - Helper
    func configureUI(withConfig config: RideActionViewConfiguration) {
         switch config {
        case .requestRide:
             buttonAction = .requestRide
             actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripAccepted:
            titleLabel.text = "En Route To passenger"
            buttonAction = .getDirections
            actionButton.setTitle(buttonAction.description, for: .normal)
            break
        case .pickupPassenger:
            break
        case .tripInProgress:
            break
        case .endTrip:
            break
        }
    }
}
