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
    func cancelTrip()
    func pickupPassenger()
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case pickupPassenger
    case driverArrived
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
    var buttonAction = ButtonAction()
    var user: User?
    
    var config = RideActionViewConfiguration() {
        didSet {
            configureUI(withConfig: config)
        }
    }

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
        
        $0.addSubview(infoViewLabel)
        infoViewLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return $0
    }(UIView())
    
    private let infoViewLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 30)
        $0.textColor = .white
        $0.text = "X"
        return $0
    }(UILabel())
    
    private let uberInfoLabel: UILabel = {
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
        addSubview(uberInfoLabel)
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
        uberInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(infoView.snp.bottom).inset(-8)
            make.centerX.equalToSuperview()
        }
        seperatorView.snp.makeConstraints { make in
            make.top.equalTo(uberInfoLabel.snp.bottom).inset(-4)
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
        
        switch buttonAction {
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            delegate?.cancelTrip()
        case .getDirections:
            print("DEBUG: getDirections")
        case .pickup:
            delegate?.pickupPassenger()
        case .dropOff:
            print("DEBUG: dropOff")
        }
    }
    
    
//MARK: - Helper
    private func configureUI(withConfig config: RideActionViewConfiguration) {
        switch config {
        case .requestRide:
            buttonAction = .requestRide
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripAccepted:
            guard let user = user else { return }
            
            if user.accountType == .passenger {
                titleLabel.text = "En Route To passenger"
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            } else {
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
                titleLabel.text = "Driver En Route"
            }
            infoViewLabel.text = String(user.fullname.first ?? "X")
            uberInfoLabel.text = user.fullname
            
        case .pickupPassenger:
            titleLabel.text = "Arrived At Passenger Location"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.description, for: .normal)
            
        case .driverArrived:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                titleLabel.text = "Driver Has Arrived"
                addressLabel.text = "Please meet driver at pickup location"
            }
            
        case .tripInProgress:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                actionButton.setTitle("TRIP IN PROGRESS", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            titleLabel.text = "En Route To Destination"
            
        case .endTrip:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                actionButton.setTitle("ARRIVED AT DESTINATION", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            titleLabel.text = "Arrived at Destination"
        }
    }
}
