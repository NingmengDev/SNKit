//
//  SNCornerRadiusView.swift
//  SNKit
//
//  Created by SN on 2021/2/3.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

public struct SNCornerRadii : Equatable {
    public var tl: CGFloat
    public var tr: CGFloat
    public var bl: CGFloat
    public var br: CGFloat
    public static let zero = SNCornerRadii(tl: 0.0, tr: 0.0, bl: 0.0, br: 0.0)
    
    public init(tl: CGFloat, tr: CGFloat, bl: CGFloat, br: CGFloat) {
        self.tl = tl
        self.tr = tr
        self.bl = bl
        self.br = br
    }
}

open class SNCornerRadiusView : UIView {
    
    open var cornerRadii: SNCornerRadii = .zero {
        didSet {
            if oldValue == cornerRadii { return }
            self.setNeedsDisplay() /// Need to redraw.
        }
    }
    
    open var borderWidth: CGFloat = 0.0 {
        didSet {
            if oldValue == borderWidth { return }
            self.setNeedsDisplay() /// Need to redraw.
        }
    }

    open var borderColor: CGColor? = nil {
        didSet {
            if oldValue == borderColor { return }
            self.setNeedsDisplay() /// Need to redraw.
        }
    }
    
    private var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.zPosition = 1.0
        return layer
    }()
    
    open var pathUpdatedHander: ((CGPath) -> Void)?
    
    public init(cornerRadii: SNCornerRadii) {
        super.init(frame: .zero)
        self.cornerRadii = cornerRadii
        self.layer.mask = CAShapeLayer()
        self.layer.addSublayer(borderLayer)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.cornerRadii = .zero
        self.layer.mask = CAShapeLayer()
        self.layer.addSublayer(borderLayer)
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if rect == .zero { return }
        
        let path = CGPath.path(roundedRect: rect,
                               cornerRadii: cornerRadii)
        (self.layer.mask as? CAShapeLayer)?.path = path
        
        self.borderLayer.lineWidth = borderWidth * 2
        self.borderLayer.strokeColor = borderColor
        self.borderLayer.path = path
        
        self.pathUpdatedHander?(path)
    }
}

private extension CGPath {
    
    static func path(roundedRect rect: CGRect, cornerRadii radii: SNCornerRadii) -> CGPath {
        let tl = CGSize(width: max(0.0, min(radii.tl, rect.width - radii.tr)), height: max(0.0, min(radii.tl, rect.height - radii.bl)))
        let tr = CGSize(width: max(0.0, min(radii.tr, rect.width - radii.tl)), height: max(0.0, min(radii.tr, rect.height - radii.br)))
        let bl = CGSize(width: max(0.0, min(radii.bl, rect.width - radii.br)), height: max(0.0, min(radii.bl, rect.height - radii.tl)))
        let br = CGSize(width: max(0.0, min(radii.br, rect.width - radii.bl)), height: max(0.0, min(radii.br, rect.height - radii.tr)))
        let bezierPath = CGMutablePath()
        bezierPath.addArc(center: CGPoint(x: rect.minX + tl.width, y: rect.minY + tl.height), radius: radii.tl, startAngle: .pi, endAngle: 3 * .pi / 2, clockwise: false)
        bezierPath.addArc(center: CGPoint(x: rect.maxX - tr.width, y: rect.minY + tr.height), radius: radii.tr, startAngle: 3 * .pi / 2, endAngle: 0.0, clockwise: false)
        bezierPath.addArc(center: CGPoint(x: rect.maxX - br.width, y: rect.maxY - br.height), radius: radii.br, startAngle: 0.0, endAngle: .pi / 2, clockwise: false)
        bezierPath.addArc(center: CGPoint(x: rect.minX + bl.width, y: rect.maxY - bl.height), radius: radii.bl, startAngle: .pi / 2, endAngle: .pi, clockwise: false)
        bezierPath.closeSubpath()
        return bezierPath
    }
}
