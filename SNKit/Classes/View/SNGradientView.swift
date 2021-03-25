//
//  SNGradientView.swift
//  SNKit
//
//  Created by SN on 2021/3/25.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

/// A convenience class to use CAGradientLayer, and supports auto layout.
public final class SNGradientView : UIView {
    
    /// Internal gradient layer.
    private var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    /// Returns the CAGradientLayer class used to create the layer for instances of SNGradientView.
    public override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    /// An array of CGColorRef objects defining the color of each gradient stop. Animatable.
    public var colors: [Any]? {
        set { gradientLayer.colors = newValue }
        get { return gradientLayer.colors }
    }
    
    /// An optional array of NSNumber objects defining the location of each gradient stop. Animatable.
    public var locations: [NSNumber]? {
        set { gradientLayer.locations = newValue }
        get { return gradientLayer.locations }
    }
    
    /// The start point of the gradient when drawn in the layer’s coordinate space. Animatable.
    public var startPoint: CGPoint {
        set { gradientLayer.startPoint = newValue }
        get { return gradientLayer.startPoint }
    }
    
    /// The end point of the gradient when drawn in the layer’s coordinate space. Animatable.
    public var endPoint: CGPoint {
        set { gradientLayer.endPoint = newValue }
        get { return gradientLayer.endPoint }
    }
    
    /// Style of gradient drawn by the layer.
    public var type: CAGradientLayerType {
        set { gradientLayer.type = newValue }
        get { return gradientLayer.type }
    }
}
