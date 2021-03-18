//
//  SNEdgeInsetsView.swift
//  SNKit
//
//  Created by SN on 2020/3/3.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

/// A subclass of UILabel that can set inset distances for text.
open class SNEdgeInsetsLabel : UILabel {
    
    /// The inset distances for text.
    open var textInsets: UIEdgeInsets = .zero {
        didSet { self.invalidateIntrinsicContentSize() }
    }

    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insets = textInsets
        var rect = super.textRect(forBounds: bounds.inset(by: insets),
                                  limitedToNumberOfLines: numberOfLines)
        rect.origin.x -= insets.left
        rect.origin.y -= insets.top
        rect.size.width += (insets.left + insets.right)
        rect.size.height += (insets.top + insets.bottom)
        return rect
    }
}

/// A subclass of UITextField that can set inset distances for text.
open class SNEdgeInsetsTextField : UITextField {
    
    /// The inset distances for text.
    open var textInsets: UIEdgeInsets = .zero {
        didSet { self.invalidateIntrinsicContentSize() }
    }

    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
}
