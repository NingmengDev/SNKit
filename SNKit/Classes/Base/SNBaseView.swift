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
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.backgroundColor = UIColor.white
    }
}

// MARK: - SNZeroedSeparatorInsetTableViewCell

open class SNZeroedSeparatorInsetTableViewCell : SNBaseTableViewCell {
    
    /// Cell will set 'separatorInset' to zero internally.
    open override func initialization() {
        super.initialization()
        self.separatorInset = .zero
    }
}

// MARK: - SNBaseTableViewHeaderFooterView

class SNBaseTableViewHeaderFooterView : UITableViewHeaderFooterView, SNBaseViewInitialization {
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.initialization()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialization()
    }
    
    func initialization() {
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
