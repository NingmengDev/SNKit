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
    
    /// Create an UITableView wiht the given style and set some default parameters.
    /// - Parameter style: TableView style.
    /// - Returns: An UITableView.
    static func standardize(style: UITableView.Style) -> UITableView {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: style)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = UIColor.white
        tableView.estimatedRowHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
        let frame = CGRect(origin: .zero, size: CGSize(width: 0.0, height: CGFloat.leastNonzeroMagnitude))
        tableView.tableHeaderView = UIView(frame: frame)
        tableView.tableFooterView = UIView(frame: frame)
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
