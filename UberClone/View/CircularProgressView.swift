//
//  CircularProgressView.swift
//  UberClone
//
//  Created by 박현준 on 2023/07/29.
//

import UIKit

class CircularProgressView: UIView {
    
//MARK: - Properties

    var progressLayer: CAShapeLayer!
    var trackLayer: CAShapeLayer!
    var pulsatingLayer: CAShapeLayer!
    
//MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCircleLayers() 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Helper Functions
    // 원형 애니메이션 코드
    private func configureCircleLayers() {
        pulsatingLayer = circleShapeLayer(strokeColor: .clear, fillColor: .blue)
        layer.addSublayer(pulsatingLayer)
        
        trackLayer = circleShapeLayer(strokeColor: .clear, fillColor: .clear)
        layer.addSublayer(trackLayer)
        // end지점에서 멈춤
        trackLayer.strokeEnd = 1
        
        progressLayer = circleShapeLayer(strokeColor: .systemPink, fillColor: .clear)
        layer.addSublayer(progressLayer)
        progressLayer.strokeEnd = 1
    }
    
    // 원 레이어 잡기
    private func circleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        let center = CGPoint(x: 0, y: 32)
        // 12시부터 원형으로 돌기
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: self.frame.width / 2.5,
                                        startAngle: -(.pi / 2),
                                        endAngle: 1.5 * .pi,
                                        clockwise: true)
        
        layer.path = circularPath.cgPath
        layer.lineWidth = 12
        layer.strokeColor = strokeColor.cgColor
        layer.fillColor = fillColor.cgColor
        layer.lineCap = .round
        layer.position = self.center
        
        return layer
    }
    
    // 심장 박동 애니메이션
    func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue = 1.25
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    // 시간 초로 원형 사라지는 애니메이션과 애니메이션 끝나면 completion 설정
    func setProgressWithAnimation(duration: TimeInterval, value: Float,
                                  completion: @escaping () -> Void) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 1
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateProgress")
        
        CATransaction.commit()
    }
}
