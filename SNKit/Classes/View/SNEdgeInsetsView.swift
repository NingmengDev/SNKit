//
//  SNEdgeInsetsView.swift
//  SNKit
//
//  Created by SN on 2020/3/3.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

open class SNEdgeInsetsLabel : UILabel {

    open var textInsets: UIEdgeInsets = .zero {
        didSet { self.invalidateIntrinsicContentSize() }
    }

    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = super.textRect(forBounds: bounds.inset(by: textInsets),
                                  limitedToNumberOfLines: numberOfLines)
        rect.origin.x    -= textInsets.left
        rect.origin.y    -= textInsets.top
        rect.size.width  += (textInsets.left + textInsets.right)
        rect.size.height += (textInsets.top + textInsets.bottom)
        return rect
    }
}

open class SNEdgeInsetsTextField : UITextField {

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
