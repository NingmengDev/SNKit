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
    
    private static var baseStatusBarHidden: Bool = false
    private static var baseStatusBarStyle: UIStatusBarStyle = .default

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
    }
        
    open override var prefersStatusBarHidden: Bool {
        return SNBaseViewController.baseStatusBarHidden
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return SNBaseViewController.baseStatusBarStyle
    }
    
    /// Prefers hidden state and style of status bar.
    /// - Parameters:
    ///   - style: The preferred status bar style.
    ///   - hidden: The preferred status bar hidden state.
    public static func prefersStatusBar(style: UIStatusBarStyle, hidden: Bool) {
        SNBaseViewController.baseStatusBarHidden = hidden
        SNBaseViewController.baseStatusBarStyle = style
    }
}

// MARK: - SNBaseTableViewController

/// Convenience class, creates a controller that contains a table view.
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

/// Convenience class, creates a controller that contains a collection view.
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

// MARK: - SNBaseNavigationController

/// Base navigation controller, set white background color for the view.
open class SNBaseNavigationController : UINavigationController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return self.visibleViewController
    }
    
    /// Pushes a view controller onto the receiver’s stack and updates the display.
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.isEmpty == false {
            /// Customizes back bar button item if needed.
            if viewController.navigationItem.hidesBackButton == false {
                self.customizeBackBarButtonItemOfNavigationItemIn(viewController)
            }
            /// View controller is pushed into a controller hierarchy with a bottom bar (like a tab bar),
            /// the bottom bar will slide out.
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    /// Pops until there's only a single view controller left on the stack. Returns the popped controllers.
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if #available(iOS 14.0, *) {
            /// Fix tab bar dose not display when navigation controller pop to root in iOS 14 and later.
            self.viewControllers.forEach({ $0.hidesBottomBarWhenPushed = false })
        }
        return super.popToRootViewController(animated: animated)
    }
    
    /// Override this method to customize a back bar button item when the view controller will be pushed onto stack.
    open func customizeBackBarButtonItemOfNavigationItemIn(_ viewController: UIViewController) {
        /** For example:
        let backBarButtonItem = UIBarButtonItem(title: "Back",
                                                style: .plain,
                                                target: self,
                                                action: #selector(backBarButtonItemEvent(_:)))
        viewController.navigationItem.leftBarButtonItem = backBarButtonItem
        */
    }
}
