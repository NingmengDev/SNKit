//
//  SNBaseViewController.swift
//  SNKit
//
//  Created by SN on 2021/2/3.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

/// Base view controller, set white background color for the view.
open class SNBaseViewController : UIViewController {

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
    }
        
    open override var prefersStatusBarHidden: Bool {
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: - SNBaseTableViewController

/// Convenience class, create a controller contains a tableView.
open class SNBaseTableViewController : SNBaseViewController {
    
    public let tableView: UITableView
    
    public init(style: UITableView.Style = .plain) {
        self.tableView = Self.initializeTableView(style: style)
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        self.tableView = Self.initializeTableView(style: .plain)
        super.init(coder: coder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.frame = view.bounds
        self.view.addSubview(self.tableView)
    }
    
    private class func initializeTableView(style: UITableView.Style) -> UITableView {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: style)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = UIColor.white
        tableView.estimatedRowHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }
}

// MARK: - SNBaseCollectionViewController

/// Convenience class, create a controller contains a collectionView.
open class SNBaseCollectionViewController : SNBaseViewController {
    
    public let collectionView: UICollectionView
    
    public init(collectionViewLayout layout: UICollectionViewLayout = UICollectionViewFlowLayout()) {
        self.collectionView = Self.initializeCollectionView(layout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        self.collectionView = Self.initializeCollectionView(layout: UICollectionViewFlowLayout())
        super.init(coder: coder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.frame = view.bounds
        self.view.addSubview(self.collectionView)
    }
    
    private class func initializeCollectionView(layout: UICollectionViewLayout) -> UICollectionView {
        let collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }
}
