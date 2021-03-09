//
//  UIScrollView+SN.swift
//  SNKit
//
//  Created by SN on 2021/2/3.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

public extension UIScrollView {
    
    /// Reload without animation for UITableView or UICollectionView.
    func reloadDataWithoutAnimation() {
        let selector = NSSelectorFromString("reloadData")
        guard self.responds(to: selector) else { return }
        UIView.performWithoutAnimation { self.perform(selector) }
    }
}

public extension UITableView {
    
    /// Create an UITableView with the given frame, style and set some default parameters.
    /// - Parameters:
    ///   - frame: The initialized frame of the table view.
    ///   - style: The initialized style of the table view.
    /// - Returns: An UITableView instance.
    static func standardize(frame: CGRect, style: UITableView.Style = .plain) -> UITableView {
        let tableView = UITableView(frame: frame, style: style)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = UIColor.white
        tableView.estimatedRowHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }

    /// Allows multiple insert/delete/reload/move calls to be animated simultaneously. Nestable.
    /// - Parameters:
    ///   - updates: The block that performs the relevant insert, delete, reload, or move operations.
    ///   - completion: A completion handler block to execute when all of the operations are finished.
    func performBatchUpdatesWithBlock(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        if #available(iOS 11.0, *) {
            self.performBatchUpdates(updates, completion: completion)
        } else {
            CATransaction.begin()
            CATransaction.setCompletionBlock { completion?(true) }
            self.beginUpdates()
            updates?()
            self.endUpdates()
            CATransaction.commit()
        }
    }
}
