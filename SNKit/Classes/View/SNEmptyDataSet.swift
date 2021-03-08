//
//  SNEmptyDataSet.swift
//  SNKit
//
//  Created by SN on 2020/3/2.
//  Copyright © 2020 Apple. All rights reserved.
//

import DZNEmptyDataSet

/// Represents an object type that is compatible with DZNEmptyDataSet.
@objc public protocol SNEmptyDataSetCompatible : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    /// Tells the delegate that the empty dataset view or button was tapped.
    /// Use this method either to resignFirstResponder of a textfield or searchBar.
    /// - Note: To fix the issue of same function name, we will merge -emptyDataSet:didTapView: and -emptyDataSet:didTapButton: into -emptyDataSet(_:didTapAt:), and pass the tapped view or button to 'kindOfView'.
    /// - Parameters:
    ///   - scrollView: A scrollView subclass informing the delegate.
    ///   - kindOfView: The empty dataset view or button tapped by the user.
    @objc optional func emptyDataSet(_ scrollView: UIScrollView, didTapAt kindOfView: UIView)
}

// MARK: - UIScrollView+SNEmptyDataSet

private var SNEmptyDataSetAssociatedTypeKey   = "SNEmptyDataSetAssociatedTypeKey"
private var SNEmptyDataSetAssociatedTargetKey = "SNEmptyDataSetAssociatedTargetKey"

public extension UIScrollView {
    
    /// Types that causes empty data, generally mapped from a error.
    enum EmptyDataSetType {
        /// Means that there is not any data in server.
        case dataEmpty
        /// Means that we can not get valid data from server or server is not responding.
        case dataError
        /// Means that current network is unreachable. See also 'NSURLErrorNotConnectedToInternet'.
        case networkError
        /// Means that the error is undefined, you can map the error to a type manually.
        case otherUnknown(Error)
    }
    
    /// The default target to support data source and delegate for the dataset.
    internal static var defaultEmptyDataSetTarget: SNEmptyDataSetCompatible?
    
    /// The customized target to support data source and delegate for the dataset.
    internal weak var emptyDataSetTarget: SNEmptyDataSetCompatible? {
        set { objc_setAssociatedObject(self, &SNEmptyDataSetAssociatedTargetKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
        get { return objc_getAssociatedObject(self, &SNEmptyDataSetAssociatedTargetKey) as? SNEmptyDataSetCompatible }
    }
    
    /// Current type that causes empty data.
    /// You can do some configurations for the dataset base on the current type.
    var emptyDataSetType: EmptyDataSetType? {
        set { objc_setAssociatedObject(self, &SNEmptyDataSetAssociatedTypeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { return objc_getAssociatedObject(self, &SNEmptyDataSetAssociatedTypeKey) as? EmptyDataSetType }
    }
    
    /// Sets a default target to support data source and delegate for the dataset.
    /// If the customized target doesn't responds some functions of data source and delegate, the default target will be used to respond.
    /// If you no longer use the default target, pass 'nil' to invalid it.
    /// - Parameter target: A object that conforms to 'SNEmptyDataSetCompatible'.
    static func setEmptyDataSetDefaultTarget(_ target: SNEmptyDataSetCompatible?) {
        UIScrollView.defaultEmptyDataSetTarget = target
    }

    /// Sets a customized target to support data source and delegate for the dataset.
    /// - Parameter target: An object conforms to 'SNEmptyDataSetCompatible'.
    func registerEmptyDataSet(in target: SNEmptyDataSetCompatible) {
        self.emptyDataSetTarget = target
        self.emptyDataSetSource = SNEmptyDataSetSupport.shared
        self.emptyDataSetDelegate = SNEmptyDataSetSupport.shared
    }

    /// Removes data source and delegate for the dataset.
    func unregisterEmptyDataSet() {
        self.emptyDataSetType = nil
        self.emptyDataSetTarget = nil
        self.emptyDataSetSource = nil
        self.emptyDataSetDelegate = nil
    }

    /// Maps the given error to one case of SNEmptyDataSetType.
    /// - Parameter error: An error causes empty.
    func handleEmptyDataSet(for error: Error?) {
        guard let validError = error else {
            self.emptyDataSetType = .dataEmpty
            return
        }
        switch (validError as NSError).code {
        case NSURLErrorNetworkConnectionLost,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorDataNotAllowed:
            self.emptyDataSetType = .networkError
        case NSURLErrorCannotFindHost,
             NSURLErrorCannotConnectToHost,
             NSURLErrorBadServerResponse,
             NSURLErrorCannotParseResponse:
            self.emptyDataSetType = .dataError
        default:
            self.emptyDataSetType = .otherUnknown(validError)
        }
    }

    /// Resets the dataset to default, all elements of empty dataset will be removed.
    func resetEmptyDataSet(_ completionHandler: (() -> Void)?) {
        self.emptyDataSetType = nil
        self.reloadEmptyDataSet()
        DispatchQueue.main.async { completionHandler?() }
    }
}

// MARK: - SNEmptyDataSetSupport

final class SNEmptyDataSetSupport : NSObject, SNEmptyDataSetCompatible {

    /// Singletons
    static let shared = SNEmptyDataSetSupport()
    private override init() {}

    // MARK: - DZNEmptyDataSetSource

    /// Asks the data source for the title of the dataset.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the data source.
    /// - Returns: An attributed string for the dataset title, combining font, text color, text pararaph style, etc.
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(title(forEmptyDataSet:))) {
            return target.title?(forEmptyDataSet: scrollView)
        }
        return UIScrollView.defaultEmptyDataSetTarget?.title?(forEmptyDataSet: scrollView)
    }

    /// Asks the data source for the description of the dataset.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the data source.
    /// - Returns: An attributed string for the dataset description text, combining font, text color, text pararaph style, etc.
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(description(forEmptyDataSet:))) {
            return target.description?(forEmptyDataSet: scrollView)
        }
        return UIScrollView.defaultEmptyDataSetTarget?.description?(forEmptyDataSet: scrollView)
    }

    /// Asks the data source for the image of the dataset.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the data source.
    /// - Returns: An image for the dataset.
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(image(forEmptyDataSet:))) {
            return target.image?(forEmptyDataSet: scrollView)
        }
        return UIScrollView.defaultEmptyDataSetTarget?.image?(forEmptyDataSet: scrollView)
    }

    /// Asks the data source for a tint color of the image dataset. Default is nil.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: A color to tint the image of the dataset.
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(imageTintColor(forEmptyDataSet:))) {
            return target.imageTintColor?(forEmptyDataSet: scrollView)
        }
        return UIScrollView.defaultEmptyDataSetTarget?.imageTintColor?(forEmptyDataSet: scrollView)
    }

    /// Asks the data source for the image animation of the dataset.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: image animation
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView) -> CAAnimation? {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(imageAnimation(forEmptyDataSet:))) {
            return target.imageAnimation?(forEmptyDataSet: scrollView)
        }
        return UIScrollView.defaultEmptyDataSetTarget?.imageAnimation?(forEmptyDataSet: scrollView)
    }

    /// Asks the data source for the title to be used for the specified button state.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass object informing the data source.
    ///   - state: The state that uses the specified title. The possible values are described in UIControlState.
    /// - Returns: An attributed string for the dataset button title, combining font, text color, text pararaph style, etc.
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(buttonTitle(forEmptyDataSet:for:))) {
            return target.buttonTitle?(forEmptyDataSet: scrollView, for: state)
        }
        return UIScrollView.defaultEmptyDataSetTarget?.buttonTitle?(forEmptyDataSet: scrollView, for: state)
    }

    /// Asks the data source for the image to be used for the specified button state.
    /// This method will override buttonTitleForEmptyDataSet:forState: and present the image only without any text.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass object informing the data source.
    ///   - state: The state that uses the specified title. The possible values are described in UIControlState.
    /// - Returns: An image for the dataset button imageview.
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(buttonImage(forEmptyDataSet:for:))) {
            return target.buttonImage?(forEmptyDataSet: scrollView, for: state)
        }
        return UIScrollView.defaultEmptyDataSetTarget?.buttonImage?(forEmptyDataSet: scrollView, for: state)
    }

    /// Asks the data source for a background image to be used for the specified button state.
    /// There is no default style for this call.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass informing the data source.
    ///   - state: The state that uses the specified image. The values are described in UIControlState.
    /// - Returns: An attributed string for the dataset button title, combining font, text color, text pararaph style, etc.
    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(buttonBackgroundImage(forEmptyDataSet:for:))) {
            return target.buttonBackgroundImage?(forEmptyDataSet: scrollView, for: state)
        }
        return UIScrollView.defaultEmptyDataSetTarget?.buttonBackgroundImage?(forEmptyDataSet: scrollView, for: state)
    }

    /// Asks the data source for the background color of the dataset. Default is clear color.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: A color to be applied to the dataset background view.
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(backgroundColor(forEmptyDataSet:))) {
            return target.backgroundColor?(forEmptyDataSet: scrollView) ?? .clear
        }
        return UIScrollView.defaultEmptyDataSetTarget?.backgroundColor?(forEmptyDataSet: scrollView) ?? .clear
    }

    /// Asks the data source for a custom view to be displayed instead of the default views such as labels, imageview and button. Default is nil.
    /// Use this method to show an activity view indicator for loading feedback, or for complete custom empty data set.
    /// Returning a custom view will ignore -offsetForEmptyDataSet and -spaceHeightForEmptyDataSet configurations.
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: The custom view.
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(customView(forEmptyDataSet:))) {
            return target.customView?(forEmptyDataSet: scrollView)
        }
        return UIScrollView.defaultEmptyDataSetTarget?.customView?(forEmptyDataSet: scrollView)
    }

    /// Asks the data source for a offset for vertical alignment of the content. Default is 0.
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: The offset for vertical alignment.
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(verticalOffset(forEmptyDataSet:))) {
            return target.verticalOffset?(forEmptyDataSet: scrollView) ?? 0.0
        }
        return UIScrollView.defaultEmptyDataSetTarget?.verticalOffset?(forEmptyDataSet: scrollView) ?? 0.0
    }

    /// Asks the data source for a vertical space between elements. Default is 11 pts.
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: The space height between elements.
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(spaceHeight(forEmptyDataSet:))) {
            return target.spaceHeight?(forEmptyDataSet: scrollView) ?? 11.0
        }
        return UIScrollView.defaultEmptyDataSetTarget?.spaceHeight?(forEmptyDataSet: scrollView) ?? 11.0
    }

    // MARK: - DZNEmptyDataSetDelegate

    /// Asks the delegate to know if the empty dataset should fade in when displayed. Default is true.
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: true if the empty dataset should fade in.
    func emptyDataSetShouldFade(in scrollView: UIScrollView) -> Bool {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(emptyDataSetShouldFade(in:))) {
            return target.emptyDataSetShouldFade?(in: scrollView) ?? true
        }
        return UIScrollView.defaultEmptyDataSetTarget?.emptyDataSetShouldFade?(in: scrollView) ?? true
    }

    /// Asks the delegate to know if the empty dataset should still be displayed when the amount of items is more than 0. Default is false.
    /// - Parameter scrollView:  A scrollView subclass object informing the delegate.
    /// - Returns: true if empty dataset should be forced to display.
    func emptyDataSetShouldBeForced(toDisplay scrollView: UIScrollView) -> Bool {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(emptyDataSetShouldBeForced(toDisplay:))) {
            return target.emptyDataSetShouldBeForced?(toDisplay: scrollView) ?? false
        }
        return UIScrollView.defaultEmptyDataSetTarget?.emptyDataSetShouldBeForced?(toDisplay: scrollView) ?? false
    }

    /// Asks the delegate to know if the empty dataset should be rendered and displayed. Default is true.
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: true if the empty dataset should show.
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(emptyDataSetShouldDisplay(_:))) {
            return target.emptyDataSetShouldDisplay?(scrollView) ?? true
        }
        if let target = UIScrollView.defaultEmptyDataSetTarget, target.responds(to: #selector(emptyDataSetShouldDisplay(_:))) {
            return target.emptyDataSetShouldDisplay?(scrollView) ?? true
        }
        return (scrollView.emptyDataSetType == nil) ? false : true
    }

    /// Asks the delegate for touch permission. Default is true.
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: true if the empty dataset receives touch gestures.
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(emptyDataSetShouldAllowTouch(_:))) {
            return target.emptyDataSetShouldAllowTouch?(scrollView) ?? true
        }
        return UIScrollView.defaultEmptyDataSetTarget?.emptyDataSetShouldAllowTouch?(scrollView) ?? true
    }

    /// Asks the delegate for scroll permission. Default is false.
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: true if the empty dataset is allowed to be scrollable.
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(emptyDataSetShouldAllowScroll(_:))) {
            return target.emptyDataSetShouldAllowScroll?(scrollView) ?? false
        }
        return UIScrollView.defaultEmptyDataSetTarget?.emptyDataSetShouldAllowScroll?(scrollView) ?? false
    }

    /// Asks the delegate for image view animation permission. Default is false.
    /// Make sure to return a valid CAAnimation object from imageAnimationForEmptyDataSet:
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: true if the empty dataset is allowed to animate.
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView) -> Bool {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(emptyDataSetShouldAnimateImageView(_:))) {
            return target.emptyDataSetShouldAnimateImageView?(scrollView) ?? false
        }
        return UIScrollView.defaultEmptyDataSetTarget?.emptyDataSetShouldAnimateImageView?(scrollView) ?? false
    }

    /// Tells the delegate that the empty dataset view was tapped.
    /// - Parameters:
    ///   - scrollView: scrollView A scrollView subclass informing the delegate.
    ///   - view: the view tapped by the user.
    func emptyDataSet(_ scrollView: UIScrollView, didTap view: UIView) {
        var unwrappedView: UIView = view
        if let t = view as? NSObject, let v = (t as? UIGestureRecognizer)?.view {
            unwrappedView = v /// Fix issue for the 'view' passed UITapGestureRecognizer type.
        }
        self.emptyDataSet(scrollView, didTapAt: unwrappedView)
    }

    /// Tells the delegate that the action button was tapped.
    /// - Parameters:
    ///   - scrollView: A scrollView subclass informing the delegate.
    ///   - button: the button tapped by the user.
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        self.emptyDataSet(scrollView, didTapAt: (button as UIView))
    }
    
    /// Tells the delegate that the empty dataset view or button was tapped.
    /// Use this method either to resignFirstResponder of a textfield or searchBar.
    /// - Parameters:
    ///   - scrollView: A scrollView subclass informing the delegate.
    ///   - view: the kind of UIView tapped by the user.
    func emptyDataSet(_ scrollView: UIScrollView, didTapAt view: UIView) {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(emptyDataSet(_:didTapAt:))) {
            target.emptyDataSet?(scrollView, didTapAt: view)
        } else {
            UIScrollView.defaultEmptyDataSetTarget?.emptyDataSet?(scrollView, didTapAt: view)
        }
    }

    /// Tells the delegate that the empty data set will appear.
    /// - Parameter scrollView: A scrollView subclass informing the delegate.
    func emptyDataSetWillAppear(_ scrollView: UIScrollView) {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(emptyDataSetWillAppear(_:))) {
            target.emptyDataSetWillAppear?(scrollView)
        } else {
            UIScrollView.defaultEmptyDataSetTarget?.emptyDataSetWillAppear?(scrollView)
        }
    }

    /// Tells the delegate that the empty data set did appear.
    /// - Parameter scrollView: A scrollView subclass informing the delegate.
    func emptyDataSetDidAppear(_ scrollView: UIScrollView) {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(emptyDataSetDidAppear(_:))) {
            target.emptyDataSetDidAppear?(scrollView)
        } else {
            UIScrollView.defaultEmptyDataSetTarget?.emptyDataSetDidAppear?(scrollView)
        }
    }
    
    /// Tells the delegate that the empty data set will disappear.
    /// - Parameter scrollView: A scrollView subclass informing the delegate.
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView) {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(emptyDataSetWillDisappear(_:))) {
            target.emptyDataSetWillDisappear?(scrollView)
        } else {
            UIScrollView.defaultEmptyDataSetTarget?.emptyDataSetWillDisappear?(scrollView)
        }
    }

    /// Tells the delegate that the empty data set did disappear.
    /// - Parameter scrollView: A scrollView subclass informing the delegate.
    func emptyDataSetDidDisappear(_ scrollView: UIScrollView) {
        if let target = scrollView.emptyDataSetTarget, target.responds(to: #selector(emptyDataSetDidDisappear(_:))) {
            target.emptyDataSetDidDisappear?(scrollView)
        } else {
            UIScrollView.defaultEmptyDataSetTarget?.emptyDataSetDidDisappear?(scrollView)
        }
    }
}
