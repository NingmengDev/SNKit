//
//  SNTimer.swift
//  SNKit
//
//  Created by SN on 2020/3/2.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

/// A convenience class to use GCD timer.
open class SNTimer {
    
    private enum State : Int {
        case suspended
        case executing
        case invalidated
    }
    
    private var timeInterval: TimeInterval
    private var queue: DispatchQueue?
    private var handler: (() -> Void)?
    
    private var timer: DispatchSourceTimer?
    private var state: State = .suspended
    
    /// A Boolean value that indicates whether the timer is currently valid.
    open var isValid: Bool {
        switch state {
        case .invalidated:
            return false
        default:
            return true
        }
    }
    
    /// Creates a new GCD timer with a time interval, a dispatch queue and a action handler.
    /// - Parameters:
    ///   - timeInterval: The number of seconds between firings of the timer.
    ///   - queue: The dispatch queue to which to execute the installed handlers.
    ///   - handler: A block to be executed when the timer fires.
    public init(timeInterval: TimeInterval, queue: DispatchQueue? = nil, handler: (() -> Void)? = nil) {
        self.queue = queue
        self.handler = handler
        self.timeInterval = timeInterval
        self.timer = DispatchSource.makeTimerSource(queue: queue)
    }
    
    /// Activates timer and executes block immediately.
    /// - Parameter newHandler: Optional block to replace the default.
    open func fire(_ newHandler: (() -> Void)? = nil) {
        guard self.state == .suspended else { return }
        if let newHandler = newHandler {
            self.handler = newHandler
        }
        self.timer?.schedule(deadline: .now(), repeating: timeInterval)
        self.timer?.setEventHandler(handler: handler)
        self.timer?.resume()
        self.state = .executing
    }
    
    /// Stops the timer from ever firing again.
    open func invalidate() {
        if self.state == .invalidated { return }
        self.timer?.setEventHandler(handler: nil)
        if self.state == .suspended {
            self.timer?.resume() /// Fix "EXC_BAD_INSTRUCTION" issue.
        }
        self.timer?.cancel()
        self.timer = nil
        self.state = .invalidated
    }
    
    /// Reset timer to default state. If 'newTimeInterval' is valid, it will replace the default time interval.
    /// After reset, you must call fire(_:) method to activate timer again.
    /// - Parameter newTimeInterval: Optional time interval to replace the default.
    open func reset(newTimeInterval: TimeInterval? = nil) {
        self.invalidate()
        if let newTimeInterval = newTimeInterval {
            self.timeInterval = newTimeInterval
        }
        self.timer = DispatchSource.makeTimerSource(queue: queue)
        self.state = .suspended
    }
    
    deinit {
        self.invalidate()
    }
}

private extension TimeInterval {

    /// The time interval since the last time device was rebooted.
    static var sinceDeviceLastReboot: TimeInterval {
        var now = timeval()
        var tz = timezone()
        gettimeofday(&now, &tz)
        
        var boottime = timeval()
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        var size = MemoryLayout.stride(ofValue: boottime)
        
        var interval: time_t = -1
        if sysctl(&mib, 2, &boottime, &size, nil, 0) != -1, boottime.tv_sec != 0 {
            interval = now.tv_sec - boottime.tv_sec
            interval += time_t(now.tv_usec - boottime.tv_usec) / time_t(1000000)
        }
        return TimeInterval(interval)
    }
}

// MARK: - SNCountDownTimer

public final class SNCountDownTimer : SNTimer {
    
    private var duration: TimeInterval
    private var timeAtTheEnd: TimeInterval = 0.0
    
    private var runningHandler: ((TimeInterval) -> Void)?
    private var completionHandler: (() -> Void)?
    
    /// Creates a new count down timer, it will execute block per second.
    /// - Parameters:
    ///   - duration: The duration for the count down timer.
    ///   - queue: The dispatch queue to which to execute the installed handlers.
    public init(duration: TimeInterval, queue: DispatchQueue? = nil) {
        self.duration = duration
        super.init(timeInterval: 1.0, queue: queue)
        UIDatePicker().datePickerMode = .countDownTimer
    }
    
    /// Activates timer and executes block immediately.
    /// - Parameters:
    ///   - running: A block to be executed when the timer fires.
    ///   - completion: A block to be executed when the timer executing times beyond the duration.
    public func fire(_ running: @escaping (TimeInterval) -> Void, completion: @escaping () -> Void) {
        self.timeAtTheEnd = TimeInterval.sinceDeviceLastReboot + duration
        self.runningHandler = running
        self.completionHandler = completion
        super.fire { [weak self] in
            self?.timeFired()
        }
    }
    
    /// Reset timer to default state. If 'newDuration' is valid, it will replace the default duration.
    /// After reset, you must call fire(_:completion:) method to activate timer again.
    /// - Parameter newDuration: Optional duration to replace the default.
    public func resetDuration(_ newDuration: TimeInterval? = nil) {
        super.reset()
        if let newDuration = newDuration {
            self.duration = newDuration
        }
    }
    
    private func timeFired() {
        let remain = timeAtTheEnd - TimeInterval.sinceDeviceLastReboot
        if remain > 0.0 {
            self.runningHandler?(remain)
        } else {
            self.invalidate()
            self.completionHandler?()
        }
    }
    
    @available(*, unavailable, message: "This method is unavailable in subclass.")
    public override func fire(_ newHandler: (() -> Void)? = nil) { }
    
    @available(*, unavailable, message: "This method is unavailable in subclass.")
    public override func reset(newTimeInterval: TimeInterval? = nil) { }
}

// MARK: - SNCountUpTimer

public final class SNCountUpTimer : SNTimer {

    private var timeAtTheBeginning: TimeInterval = 0.0
    private var runningHandler: ((TimeInterval) -> Void)?
    
    /// Creates a new count up timer, it will execute block per second.
    /// - Parameter queue: The dispatch queue to which to execute the installed handlers.
    public init(queue: DispatchQueue? = nil) {
        super.init(timeInterval: 1.0, queue: queue)
    }
    
    /// Activates timer and executes block immediately.
    /// - Parameter running: A block to be executed when the timer fires.
    public func fire(_ running: @escaping (TimeInterval) -> Void) {
        self.timeAtTheBeginning = TimeInterval.sinceDeviceLastReboot
        self.runningHandler = running
        super.fire { [weak self] in
            self?.timeFired()
        }
    }

    private func timeFired() {
        let duration = TimeInterval.sinceDeviceLastReboot - timeAtTheBeginning
        self.runningHandler?(duration) /// The total executing times.
    }
    
    @available(*, unavailable, message: "This method is unavailable in subclass.")
    public override func fire(_ newHandler: (() -> Void)? = nil) { }
    
    @available(*, unavailable, message: "This method is unavailable in subclass.")
    public override func reset(newTimeInterval: TimeInterval? = nil) { }
}
