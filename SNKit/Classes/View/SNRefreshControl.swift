//
//  SNRefreshControl.swift
//  SNKit
//
//  Created by SN on 2020/3/2.
//  Copyright © 2020 Apple. All rights reserved.
//

import MJRefresh

/// MJRefresh Compatible
/// Provides a configuration class to configurate pull-to-refresh header or footer defined in 'MJRefresh'.
public final class SNRefreshControlConfiguration {
    
    static let shared = SNRefreshControlConfiguration()
    var headerConfigurator: ((MJRefreshNormalHeader) -> Void)?
    var footerConfigurator: ((MJRefreshAutoNormalFooter) -> Void)?
        
    /// Provides a handler with a shared instance of SNRefreshControlConfiguration.
    /// - Parameter handler: Takes a shared instance of SNRefreshControlConfiguration as its only parameter.
    public static func configurate(_ handler: (SNRefreshControlConfiguration) -> Void) {
        handler(shared)
    }
    
    /// Makes some shared configurations for pull-to-refresh header.
    /// - Parameter handler: A handler to configurate pull-to-refresh header.
    public func configurateHeader(_ handler: @escaping (MJRefreshNormalHeader) -> Void) {
        headerConfigurator = handler
    }
    
    /// Makes some shared configurations for pull-to-refresh footer.
    /// - Parameter handler: A handler to configurate pull-to-refresh footer.
    public func configurateFooter(_ handler: @escaping (MJRefreshAutoNormalFooter) -> Void) {
        footerConfigurator = handler
    }
}

/// MJRefresh Compatible.
/// Provides some convenient methods to use pull-to-refresh.
/// Especially，we make mutually-exclusive for the header and footer.
/// When header is refreshing, footer will nor enter refreshing state, and vice versa.
public extension UIScrollView {
    
    // MARK: - ========= Pulling To Refresh =========
    
    /// A Boolean value indicating whether a refresh operation has been triggered and is in progress.
    var isRefreshing: Bool {
        return mj_header?.isRefreshing ?? false
    }
    
    /// To store the time when the last drop-down refresh was successful.
    var lastUpdatedTimeKey: String {
        set { mj_header?.lastUpdatedTimeKey = newValue }
        get { return mj_header?.lastUpdatedTimeKey ?? "" }
    }
    
    /// Creates a pull-to-refresh header initialized with the given handler.
    /// - Parameter actionHandler: A block will be invoked when the pull-to-refresh header enters refreshing state.
    func addPullingToRefresh(actionHandler: @escaping MJRefreshComponentAction) {
        let header = MJRefreshNormalHeader { [weak self] in
            self?.mj_footer?.isUserInteractionEnabled = false
            actionHandler()
        }
        header.isAutomaticallyChangeAlpha = true
        header.lastUpdatedTimeLabel?.isHidden = true
        SNRefreshControlConfiguration.shared.headerConfigurator?(header)
        self.mj_header = header
    }
    
    /// Trigger the pull-to-refresh header to enter refreshing state.
    func startRefreshing() {
        self.mj_header?.beginRefreshing()
    }
    
    /// Trigger the pull-to-refresh header to end refreshing.
    func endRefreshing() {
        self.mj_header?.endRefreshing()
        self.mj_footer?.isUserInteractionEnabled = true
    }
    
    // MARK: - ========= Pulling To Load More =========
    
    /// A Boolean value indicating whether a loading operation has been triggered and is in progress.
    var isLoadingMore: Bool {
        return mj_footer?.isRefreshing ?? false
    }
    
    /// Creates a pull-to-refresh footer initialized with the given handler.
    /// - Parameter handler: A block will be invoked when the pull-to-refresh footer enters loading state.
    func addPullingToLoadMore(actionHandler: @escaping MJRefreshComponentAction) {
        let footer = MJRefreshAutoNormalFooter { [weak self] in
            self?.mj_header?.isUserInteractionEnabled = false
            actionHandler()
        }
        footer.isHidden = true
        footer.isAutomaticallyRefresh = true
        footer.triggerAutomaticallyRefreshPercent = 0.5
        footer.stateLabel?.isUserInteractionEnabled = false
        SNRefreshControlConfiguration.shared.footerConfigurator?(footer)
        self.mj_footer = footer
    }
    
    /// Triggers the pull-to-refresh footer to enter loading state.
    func startLoadingMore() {
        self.mj_footer?.beginRefreshing()
    }
    
    /// Triggers the pull-to-refresh footer to end loading and hides if needed.
    /// - Parameters:
    ///   - noMoreData: If true, the pull-to-refresh footer will be set to no-more-data state, and will not enter loading state when user pulling.
    ///   - hiddenWhenDone: If true, the pull-to-refresh footer will be hidden after ending loading.
    func endLoadingMore(noMoreData: Bool = false, hiddenWhenDone: Bool = false) {
        if noMoreData {
            self.mj_footer?.endRefreshingWithNoMoreData()
        } else {
            self.mj_footer?.endRefreshing()
        }
        self.mj_footer?.isHidden = hiddenWhenDone
        self.mj_header?.isUserInteractionEnabled = true
    }
}
