//
//  SNCornerRadiusView.swift
//  SNKit
//
//  Created by SN on 2021/3/25.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

/// A corner radius struct for SNCornerRadiusView.
public struct SNCornerRadii : Equatable {
    public var tl: CGFloat
    public var tr: CGFloat
    public var bl: CGFloat
    public var br: CGFloat
    
    /// All radii are set to 0.
    public static let zero = SNCornerRadii(radii: 0.0)
    
    /// Creates a new corner radius struct.
    /// - Parameters:
    ///   - tl: Radius of top-left.
    ///   - tr: Radius of top-right.
    ///   - bl: Radius of bottom-left.
    ///   - br: Radius of bottom-right.
    public init(tl: CGFloat, tr: CGFloat, bl: CGFloat, br: CGFloat) {
        self.tl = tl; self.tr = tr
        self.bl = bl; self.br = br
    }
    
    /// All radii are set to the same value.
    /// - Parameter radii: The same value for all radii.
    public init(radii: CGFloat) {
        self.tl = radii; self.tr = radii
        self.bl = radii; self.br = radii
    }
}

/// A convenience view class to set diffrent corner radius.
open class SNCornerRadiusView : UIView {
    
    /// The radius for every corner.
    /// Negative values are treated as if the radius is set to 0.
    /// The sum of horizontal radii ('tl+tr' or 'bl+br') must less than or equal to width of the view.
    /// The sum of vertical radii ('tl+bl' or 'tr+br') must less than or equal to hight of the view.
    open var cornerRadii: SNCornerRadii = .zero {
        didSet {
            if oldValue == cornerRadii { return }
            self.setNeedsDisplay() /// Need to redraw.
        }
    }
    
    /// The width of the layer’s border, same as CALayer.borderWidth.
    /// Negative values are treated as if the border width is set to 0.
    open var borderWidth: CGFloat = 0.0 {
        didSet {
            if oldValue == borderWidth { return }
            self.setNeedsDisplay() /// Need to redraw.
        }
    }
    
    /// The color of the layer’s border, same as CALayer.borderColor.
    open var borderColor: UIColor? = nil {
        didSet {
            if oldValue == borderColor { return }
            self.setNeedsDisplay() /// Need to redraw.
        }
    }
    
    /// The sub layer to draw border.
    private var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.zPosition = 1.0
        return layer
    }()
    
    /// When the path defining the shape has been rendered, this block wil be executed and pass the path as parameter.
    /// You can observe the path updating to handle something, such as adjusting the shadow path of a layer.
    open var pathUpdatedHander: ((CGPath) -> Void)?
    
    /// Creates a new round corners view with the given corner radii.
    /// - Parameter cornerRadii: The corner radii for the view.
    public init(cornerRadii: SNCornerRadii) {
        super.init(frame: .zero)
        self.initWithCornerRadii(cornerRadii)
    }
    
    /// Required initializer.
    /// - Parameter coder: An unarchiver object.
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initWithCornerRadii(.zero)
    }
    
    private func initWithCornerRadii(_ radii: SNCornerRadii) {
        self.cornerRadii = radii
        self.backgroundColor = .white
        self.layer.mask = CAShapeLayer()
        self.layer.addSublayer(borderLayer)
    }
    
    /// Renders round corners path, if you override this method in subclass, you must call super.
    /// - Parameter rect: The portion of the view’s bounds that needs to be updated.
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if rect == .zero { return }
        
        let radii = radiiThatFits(rect)
        let path = pathThatFits(rect, radii: radii)
        (self.layer.mask as? CAShapeLayer)?.path = path
                
        self.borderLayer.path = path
        self.borderLayer.lineWidth = borderThatFits(rect)
        self.borderLayer.strokeColor = borderColor?.cgColor
        
        self.pathUpdatedHander?(path)
    }
    
    private func radiiThatFits(_ rect: CGRect) -> SNCornerRadii {
        let radii = SNCornerRadii(tl: max(0.0, cornerRadii.tl), tr: max(0.0, cornerRadii.tr),
                                  bl: max(0.0, cornerRadii.bl), br: max(0.0, cornerRadii.br))
        if radii.tl + radii.tr > rect.width { return .zero }
        if radii.tr + radii.br > rect.height { return .zero }
        if radii.br + radii.bl > rect.width { return .zero }
        if radii.bl + radii.tl > rect.height { return .zero }
        return radii
    }
    
    func borderThatFits(_ rect: CGRect) -> CGFloat {
        let width = max(0.0, borderWidth)
        if width * 2 > rect.width { return 0.0 }
        if width * 2 > rect.height { return 0.0 }
        return width * 2
    }
    
    private func pathThatFits(_ rect: CGRect, radii: SNCornerRadii) -> CGPath {
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: rect.minX + radii.tl, y: rect.minY + radii.tl), radius: radii.tl, startAngle: .pi, endAngle: 1.5 * .pi, clockwise: false)
        path.addArc(center: CGPoint(x: rect.maxX - radii.tr, y: rect.minY + radii.tr), radius: radii.tr, startAngle: 1.5 * .pi, endAngle: 0.0, clockwise: false)
        path.addArc(center: CGPoint(x: rect.maxX - radii.br, y: rect.maxY - radii.br), radius: radii.br, startAngle: 0.0, endAngle: .pi / 2, clockwise: false)
        path.addArc(center: CGPoint(x: rect.minX + radii.bl, y: rect.maxY - radii.bl), radius: radii.bl, startAngle: .pi / 2, endAngle: .pi, clockwise: false)
        path.closeSubpath()
        return path
    }
}
