//
//  ProgressCircleView.swift
//  PullPageControl
//
//  Created by Dmitry Avvakumov on 16.07.2018.
//  Copyright © 2018 Dmitry Avvakumov. All rights reserved.
//

import UIKit

class ProgressCircleView: UIView {

    var strokeColor: UIColor {
        set {
            circleLayer.strokeColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: circleLayer.strokeColor ?? UIColor.lightGray.cgColor)
        }
    }
    var lineWidth: CGFloat = 1.5
    
    // Private
    private var circleLayer = CAShapeLayer()
    private var circlePath: UIBezierPath {
        let size = bounds.size
        let x = lineWidth / 2.0
        let w = size.width - lineWidth
        let h = size.height - lineWidth
        
        return UIBezierPath(ovalIn: CGRect(x: x, y: x, width: w, height: h))
    }
    
    // Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupView()
    }
    
    func setupView() {
//        let x = bounds.size.width
        
        let layer = circleLayer
        
        layer.path = circlePath.cgPath
        layer.strokeColor = UIColor.lightGray.cgColor
        layer.fillColor = nil;
        layer.lineWidth = lineWidth
        layer.lineCap = kCALineCapRound
        layer.lineJoin = kCALineJoinBevel
        
        self.layer.addSublayer(layer)
    }
    
    // MARK:- Progress
    func setProgress(_ progress: Double, animated: Bool) {
         setProgress(CGFloat(progress), animated: animated)
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool) {
        let duration: TimeInterval = 1.0
        var toValue = progress
        if (toValue > 1.0) { toValue = 1.0 }
        if (toValue < 0.0) { toValue = 0.0 }
        
        if (animated) {
            CATransaction.begin()
            CATransaction.setAnimationDuration(duration)
            
            let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
            strokeEnd.beginTime = 0.0
            strokeEnd.duration  = duration
            strokeEnd.fillMode  = kCAFillModeForwards
            strokeEnd.isRemovedOnCompletion = false
            strokeEnd.toValue   = NSNumber(value: Double(toValue))
            strokeEnd.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            CATransaction.setCompletionBlock {
                self.circleLayer.removeAllAnimations()
                self.circleLayer.strokeEnd = toValue
            }
            
            circleLayer.add(strokeEnd, forKey: "strokeEndAnimation")
            CATransaction.commit()
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            circleLayer.strokeEnd = toValue
            CATransaction.commit()
        }
        
        if progress > 0.99 {
            startPulse()
        } else {
            stopPulse()
        }
    }
    
    func startAnimating() {
        setProgress(0.8, animated: true)
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.beginTime = 0.0;
        rotation.duration = 0.8;
        rotation.fromValue = NSNumber(value: 0.0)
        rotation.toValue = NSNumber(value: Double.pi * 2.0)
        rotation.fillMode = kCAFillModeForwards
        rotation.repeatCount = Float.infinity
        rotation.isRemovedOnCompletion = false
        
        self.layer.add(rotation, forKey: "transform.rotation")
    }
    
    func stopAnimating() {
        self.layer.removeAnimation(forKey: "transform.rotation")
    }
    
    func startPulse() {
        if let keys = self.layer.animationKeys() {
            if keys.contains("transform.scale") {
                return
            }
        }
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.beginTime = 0.0;
        scale.duration = 0.3;
        scale.fromValue = NSNumber(value: 1.0)
        scale.toValue = NSNumber(value: 1.4)
        scale.fillMode = kCAFillModeForwards
        scale.autoreverses = true
        scale.repeatCount = Float.infinity
        scale.isRemovedOnCompletion = false
        scale.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.layer.add(scale, forKey: "transform.scale")
    }
    
    func stopPulse() {
        self.layer.removeAnimation(forKey: "transform.scale")
    }
    

}
