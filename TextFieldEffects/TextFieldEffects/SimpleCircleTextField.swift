//
//  SimpleCircleTextField.swift
//  TextFieldEffects
//
//  Created by Ashish on 5/14/15.
//  Copyright (c) 2015 Raul Riera. All rights reserved.
//

import UIKit

@IBDesignable public class SimpleCircleTextField: TextFieldEffects {

    @IBInspectable public var placeholderColor: UIColor? {
        didSet {
            updatePlaceholder()
        }
    }
    
    @IBInspectable public var borderColor: UIColor? {
        didSet {
            updateBorder()
        }
    }
    
    override public var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }
    
    override public var bounds: CGRect {
        didSet {
            updateBorder()
            updatePlaceholder()
        }
    }
    
    private let borderThickness: CGFloat = 1
    private let placeholderInsets = CGPoint(x: 6, y: 0)
    private let textFieldInsets = CGPoint(x: 6, y: 0)
    private var backgroundLayerColor: UIColor?
    private var radius: CGFloat = 0
    
    var leftCirclePath: CGPath!
    var leftLinePath: CGPath!
    var leftBorderLayer: CAShapeLayer!
    
    var rightCirclePath: CGPath!
    var rightLinePath: CGPath!
    var rightBorderLayer: CAShapeLayer!
    
    // MARK: - TextFieldsEffectsProtocol
    
    override func drawViewsForRect(rect: CGRect) {
        let width = rect.size.width
        let height = rect.size.height
        let frame = CGRect(origin: CGPointZero, size: CGSize(width: width, height: height))
        radius = (width < height ? width / 2 : height / 2) - borderThickness
        
        placeholderLabel.frame = CGRectInset(frame, placeholderInsets.x, placeholderInsets.y)
        placeholderLabel.font = placeholderFontFromFont(font)
        
        let leftCircleShape = UIBezierPath()
        leftCircleShape.moveToPoint(CGPoint(x: center.x, y: center.y + radius))
        leftCircleShape.addArcWithCenter(center, radius: radius, startAngle: CGFloat(M_PI_2), endAngle: CGFloat(M_PI_2 * 3), clockwise: true)
        leftCirclePath = leftCircleShape.CGPath
        
        let leftLineShape = UIBezierPath()
        leftLineShape.moveToPoint(CGPoint(x: center.x, y: center.y + radius))
        leftLineShape.addLineToPoint(CGPoint(x: 0, y: center.y + radius))
        leftLinePath = leftLineShape.CGPath
        
        let rightCircleShape = UIBezierPath()
        rightCircleShape.moveToPoint(CGPoint(x: center.x, y: center.y + radius))
        rightCircleShape.addArcWithCenter(center, radius: radius, startAngle: CGFloat(M_PI_2), endAngle: CGFloat(-M_PI_2), clockwise: false)
        rightCirclePath = rightCircleShape.CGPath
        
        let rightLineShape = UIBezierPath()
        rightLineShape.moveToPoint(CGPoint(x: center.x, y: center.y + radius))
        rightLineShape.addLineToPoint(CGPoint(x: self.frame.size.width, y: center.y + radius))
        rightLinePath = rightLineShape.CGPath
        
        updateBorder()
        updatePlaceholder()
        
        layer.addSublayer(leftBorderLayer)
        layer.addSublayer(rightBorderLayer)
        
        addSubview(placeholderLabel)
    }
    
    private func updateBorder() {
        leftBorderLayer = CAShapeLayer()
        leftBorderLayer.path = leftCirclePath
        leftBorderLayer.lineCap = kCALineCapSquare
        leftBorderLayer.lineWidth = 2
        leftBorderLayer.fillColor = nil
        leftBorderLayer.strokeColor = borderColor?.CGColor
        
        rightBorderLayer = CAShapeLayer()
        rightBorderLayer.path = rightCirclePath
        rightBorderLayer.lineCap = kCALineCapSquare
        rightBorderLayer.lineWidth = 2
        rightBorderLayer.fillColor = nil
        rightBorderLayer.strokeColor = borderColor?.CGColor
    }
    
    private func updatePlaceholder() {
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.sizeToFit()
        layoutPlaceholderInTextRect()
        
        if isFirstResponder() || !text.isEmpty {
            animateViewsForTextEntry()
        }
    }
    
    private func placeholderFontFromFont(font: UIFont) -> UIFont! {
        let smallerFont = UIFont(name: font.fontName, size: font.pointSize * 0.65)
        return smallerFont
    }
    
    private func layoutPlaceholderInTextRect() {
        
        if !text.isEmpty {
            placeholderLabel.frame = CGRectZero
            return
        }
        
        placeholderLabel.transform = CGAffineTransformIdentity
        
        let textRect = textRectForBounds(bounds)
        var originX = textRect.origin.x
        
        placeholderLabel.frame = CGRect(x: center.x - placeholderLabel.bounds.width / 2, y: center.y - placeholderLabel.bounds.height / 2, width: placeholderLabel.bounds.width, height: placeholderLabel.bounds.height)
    }
    
    override func animateViewsForTextEntry() {
        if text.isEmpty {
            UIView.animateWithDuration(
                0.35,
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 2.0,
                options: UIViewAnimationOptions.BeginFromCurrentState,
                animations: ({
                    self.placeholderLabel.frame.origin = CGPoint(x: self.placeholderInsets.x, y: self.center.y - self.placeholderLabel.bounds.height / 2)
                }),
                completion: nil
            )
        } else {
            self.textAlignment = .Left
        }
        
        let leftBorderAnimation = CABasicAnimation(keyPath: "path")
        leftBorderAnimation.toValue = leftLinePath
        leftBorderAnimation.duration = 0.3
        leftBorderAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        leftBorderAnimation.fillMode = kCAFillModeForwards
        leftBorderAnimation.removedOnCompletion = false
        leftBorderLayer.addAnimation(leftBorderAnimation, forKey: nil)
        
        let rightBorderAnimation = CABasicAnimation(keyPath: "path")
        rightBorderAnimation.toValue = rightLinePath
        rightBorderAnimation.duration = 0.3
        rightBorderAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        rightBorderAnimation.fillMode = kCAFillModeForwards
        rightBorderAnimation.removedOnCompletion = false
        rightBorderLayer.addAnimation(rightBorderAnimation, forKey: nil)
    }
    
    override func animateViewsForTextDisplay() {
        if text.isEmpty {
            UIView.animateWithDuration(
                0.3,
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 2.0,
                options: UIViewAnimationOptions.BeginFromCurrentState,
                animations: ({
                    self.placeholderLabel.frame.origin = CGPoint(x: self.center.x - self.placeholderLabel.bounds.width / 2, y: self.center.y - self.placeholderLabel.bounds.height / 2)
                }),
                completion: nil
            )
        } else {
            self.textAlignment = .Center
        }
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = leftCirclePath
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        leftBorderLayer.addAnimation(animation, forKey: nil)
        
        let animation1 = CABasicAnimation(keyPath: "path")
        animation1.toValue = rightCirclePath
        animation1.duration = 0.3
        animation1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation1.fillMode = kCAFillModeForwards
        animation1.removedOnCompletion = false
        rightBorderLayer.addAnimation(animation1, forKey: nil)
    }
    
    override func animateViewsForTextChange() {
        if text.isEmpty {
            self.placeholderLabel.hidden = false
        } else {
            self.placeholderLabel.hidden = true
        }
    }
    
    // MARK: - Overrides
    
    override public func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, textFieldInsets.x, 0)
    }
    
    override public func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, textFieldInsets.x, 0)
    }

}
