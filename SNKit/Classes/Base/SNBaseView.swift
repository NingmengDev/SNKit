//
//  SNBaseView.swift
//  SNKit
//
//  Created by SN on 2021/2/3.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

public protocol SNBaseViewInitialization {
    /// Do any additional setup after initializing the view.
    /// You usually override this method to perform additional initialization for subclass.
    /// Calling super is optional when you want full customization in subclass.
    func initialization()
}

// MARK: - SNBaseTableViewCell

open class SNBaseTableViewCell : UITableViewCell, SNBaseViewInitialization {
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialization()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialization()
    }
    
    open func initialization() {
        self.contentView.backgroundColor = UIColor.white
    }
}

// MARK: - SNBaseSeparatorTableViewCell

open class SNBaseSeparatorTableViewCell : SNBaseTableViewCell {
    
    private var separatorLeftConstraint: NSLayoutConstraint?
    private var separatorRightConstraint: NSLayoutConstraint?
    private var separatorHeightConstraint: NSLayoutConstraint?
    
    private let separator: UIView = {
        let view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .separatorDefault
        } else {
            view.backgroundColor = .init(red: 198/255.0, green: 198/255.0, blue: 200/255.0, alpha: 1.0)
        }
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// Customization of the separator height, default is '1.0 / UIScreen.main.scale'.
    open var separatorHeight: CGFloat = 1.0 / UIScreen.main.scale {
        didSet {
            if oldValue == separatorHeight { return }
            separatorHeightConstraint?.constant = separatorHeight
        }
    }
    
    /// Customization of the separator color, default is '#C6C6C8'.
    open var separatorColor: UIColor {
        set { separator.backgroundColor = newValue }
        get { return separator.backgroundColor ?? .clear }
    }
    
    /// Customization of the separator inset values.
    /// Positive inset values move the separator inward and away from edges of the cell.
    /// Negative values are treated as if the inset is set to 0.
    /// The table view uses only the left and right inset values; it ignores the top and bottom inset values.
    open override var separatorInset: UIEdgeInsets {
        set {
            if newValue == separatorInset { return }
            separatorLeftConstraint?.constant  = +max(newValue.left, 0.0)
            separatorRightConstraint?.constant = -max(newValue.right, 0.0)
        }
        get {
            let left = separatorLeftConstraint?.constant ?? super.separatorInset.left
            let right = separatorRightConstraint?.constant ?? super.separatorInset.right
            return UIEdgeInsets(top: 0.0, left: left, bottom: 0.0, right: right)
        }
    }
    
    /// Initializes separator, if you override this method in subclass, you must call super.
    open override func initialization() {
        super.initialization()
        self.addSubview(separator)
        self.separatorLeftConstraint = separator.leftAnchor.constraint(equalTo: leftAnchor, constant: separatorInset.left)
        self.separatorHeightConstraint = separator.heightAnchor.constraint(equalToConstant: separatorHeight)
        self.separatorRightConstraint = separator.rightAnchor.constraint(equalTo: rightAnchor)
        self.separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        self.separatorLeftConstraint?.isActive = true
        self.separatorRightConstraint?.isActive = true
        self.separatorHeightConstraint?.isActive = true
    }
}

// MARK: - SNBaseTableViewHeaderFooterView

open class SNBaseTableViewHeaderFooterView : UITableViewHeaderFooterView, SNBaseViewInitialization {
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.initialization()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialization()
    }
    
    open func initialization() {
        self.contentView.backgroundColor = UIColor.white
    }
}

// MARK: - SNBaseCollectionViewCell

open class SNBaseCollectionViewCell : UICollectionViewCell, SNBaseViewInitialization {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialization()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialization()
    }
    
    open func initialization() {
        self.contentView.backgroundColor = UIColor.white
    }
}

// MARK: - SNBaseCollectionViewHeaderFooterView

open class SNBaseCollectionViewHeaderFooterView : UICollectionReusableView, SNBaseViewInitialization {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialization()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialization()
    }
    
    open override var layer: CALayer {
        let layer = super.layer
        if #available(iOS 11.0, *) {
            layer.zPosition = 0.0
        }
        return layer
    }
    
    open func initialization() {
        self.backgroundColor = UIColor.white
    }
}
