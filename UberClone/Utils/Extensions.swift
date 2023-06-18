//
//  Extensions.swift
//  UberClone
//
//  Created by 박현준 on 2023/05/04.
//

import UIKit
import SnapKit
import MapKit

extension UIView {
    
    func inputContainerView(image: UIImage, textField: UITextField? = nil, segmentControl: UISegmentedControl? = nil) -> UIView {
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.alpha = 0.87
        view.addSubview(imageView)

        
        if let textField = textField {
            imageView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview().inset(8)
                make.width.height.equalTo(24)
            }
            
            
            view.addSubview(textField)
            textField.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(imageView.snp.trailing).inset(-8)
                make.bottom.equalToSuperview().inset(-8)
                make.trailing.equalToSuperview()
            }
        }
        
        if let sc = segmentControl {
            imageView.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(-15)
                make.leading.equalToSuperview().inset(8)
                make.height.width.equalTo(24)
            }
            view.addSubview(sc)
            sc.snp.makeConstraints { make in
                make.top.equalTo(imageView.snp.bottom).inset(-4)
                make.leading.trailing.equalToSuperview().inset(8)
            }
        }
        
        let seperaorView = UIView()
        seperaorView.backgroundColor = .lightGray
        view.addSubview(seperaorView)
        seperaorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0.75)
        }
        return view
    }
    
    func addShadow() {
        layer.shadowColor = UIColor .black.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
    }
}


extension UITextField {
    
    func textField(withPlaceHolder placeholder: String, isSecureTextEntry: Bool) -> UITextField {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        tf.keyboardAppearance = .dark
        tf.isSecureTextEntry = isSecureTextEntry
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        return tf
    }
}

extension MKPlacemark {
    var address: String? {
        get {
            guard let subThoroughfare = subThoroughfare else { return nil }
            guard let thoroughfare = thoroughfare else { return nil }
            guard let locality = locality else {return nil }
            guard let adminArea = administrativeArea else { return nil }
            
            return "\(subThoroughfare) \(thoroughfare), \(locality), \(adminArea)"
        }
    }
        
}

extension MKMapView {
    // 사용자의 줌에 맞게 지정 - RideActionView에 가리지 않게
    func zoomToFit(annotations: [MKAnnotation]) {
        // 2차원 지도 투영법의 직사각형 영역
        var zoomRect = MKMapRect.null
        
        annotations.forEach { (annotation) in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        }
        
        let insets = UIEdgeInsets(top: 75, left: 75, bottom: 200, right: 200)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
}
