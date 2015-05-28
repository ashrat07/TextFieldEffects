//
//  AdvancedCircleTextField.swift
//  TextFieldEffects
//
//  Created by Ashish on 5/15/15.
//  Copyright (c) 2015 Raul Riera. All rights reserved.
//

import UIKit

@IBDesignable public class AdvancedCircleTextField: TextFieldEffects {

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
    private var backgroundLayerColor: UIColor?
    private var viewCenter: CGPoint = CGPointZero
    private var radius: CGFloat = 0
    
    var leftPath: CGPath!
    var leftBorderLayer: CAShapeLayer!
    
    var rightPath: CGPath!
    var rightBorderLayer: CAShapeLayer!
    
    // MARK: - TextFieldsEffectsProtocol
    
    override func drawViewsForRect(rect: CGRect) {
        let width = rect.size.width
        let height = rect.size.height
        viewCenter = CGPoint(x: width / 2, y: height / 2)
        radius = (width < height ? width / 2 : height / 2) - borderThickness
        
        let frame = CGRect(origin: CGPointZero, size: CGSize(width: width, height: height))
        placeholderLabel.frame = CGRectInset(frame, 0, 0)
        placeholderLabel.font = placeholderFontFromFont(font)
        
        let leftShape = UIBezierPath()
        leftShape.moveToPoint(CGPoint(x: viewCenter.x, y: viewCenter.y - radius))
        leftShape.addArcWithCenter(viewCenter, radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(-M_PI_2 * 3), clockwise: false)
        leftShape.addLineToPoint(CGPoint(x: self.frame.size.width, y: viewCenter.y + radius))
        leftPath = leftShape.CGPath
        
        let rightShape = UIBezierPath()
        rightShape.moveToPoint(CGPoint(x: viewCenter.x, y: viewCenter.y - radius))
        rightShape.addArcWithCenter(viewCenter, radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(M_PI_2), clockwise: true)
        rightShape.addLineToPoint(CGPoint(x: 0, y: viewCenter.y + radius))
        rightPath = rightShape.CGPath
        
        updateBorder()
        updatePlaceholder()
        
        layer.addSublayer(leftBorderLayer)
        layer.addSublayer(rightBorderLayer)
        
        addSubview(placeholderLabel)
    }
    
    private func updateBorder() {
        let strokeEnd = (CGFloat(M_PI) * radius) / (CGFloat(M_PI) * radius + viewCenter.x)
        
        leftBorderLayer = CAShapeLayer()
        leftBorderLayer.path = leftPath
        leftBorderLayer.lineCap = kCALineCapSquare
        leftBorderLayer.lineWidth = 2
        leftBorderLayer.fillColor = nil
        leftBorderLayer.strokeColor = borderColor?.CGColor
        leftBorderLayer.strokeEnd = strokeEnd
        
        rightBorderLayer = CAShapeLayer()
        rightBorderLayer.path = rightPath
        rightBorderLayer.lineCap = kCALineCapSquare
        rightBorderLayer.lineWidth = 2
        rightBorderLayer.fillColor = nil
        rightBorderLayer.strokeColor = borderColor?.CGColor
        rightBorderLayer.strokeEnd = strokeEnd
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
        
        placeholderLabel.frame = CGRect(x: viewCenter.x - placeholderLabel.bounds.width / 2, y: viewCenter.y - placeholderLabel.bounds.height / 2, width: placeholderLabel.bounds.width, height: placeholderLabel.bounds.height)
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
                    self.placeholderLabel.frame.origin = CGPoint(x: 0, y: self.viewCenter.y - self.placeholderLabel.bounds.height / 2)
                }),
                completion: nil
            )
        }
        let strokeStart = (CGFloat(M_PI) * radius) / (CGFloat(M_PI) * radius + viewCenter.x)
        
        leftBorderLayer.strokeStart = strokeStart
        leftBorderLayer.strokeEnd = 1
        
        rightBorderLayer.strokeStart = strokeStart
        rightBorderLayer.strokeEnd = 1
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
                    self.placeholderLabel.frame.origin = CGPoint(x: self.viewCenter.x - self.placeholderLabel.bounds.width / 2, y: self.viewCenter.y - self.placeholderLabel.bounds.height / 2)
                }),
                completion: nil
            )
        }
        let strokeEnd = (CGFloat(M_PI) * radius) / (CGFloat(M_PI) * radius + viewCenter.x)
        
        leftBorderLayer.strokeStart = 0
        leftBorderLayer.strokeEnd = strokeEnd
        
        rightBorderLayer.strokeStart = 0
        rightBorderLayer.strokeEnd = strokeEnd
    }
    
    override func animateViewsForTextChange() {
        if text.isEmpty {
            self.placeholderLabel.hidden = false
        } else {
            self.placeholderLabel.hidden = true
        }
    }

}
