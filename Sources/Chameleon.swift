//
//  Chameleon.swift
//  Chameleon
//
//  Created by travel on 16/3/19.
//  Copyright © 2016年 travel. All rights reserved.
//

import Foundation
import UIKit

private class ThemeSwitchData {
    var lastTimestamp:Int64 = 0
    var lastSignature:String? = nil
    var extData:AnyObject? = nil
    
    init(data:AnyObject?) {
        lastTimestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
        lastSignature = "\(lastTimestamp)"
        extData = data
    }
    
    init(data:AnyObject?, signature:String?) {
        lastTimestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
        lastSignature = signature
        extData = data
    }
    
    func shouldUpdate(pre:ThemeSwitchData) -> Bool {
        return self === pre
    }
    
    class func shouldUpdate(pre:ThemeSwitchData?, lat:ThemeSwitchData?) -> Bool {
        if pre === lat {
            return false
        } else if let a = pre?.lastSignature, b = lat?.lastSignature where a == b {
            return false
        }
        return true
    }
}

private var kThemeLastSwitchKey: Void?
private var kThemeSwitchBlockKey: Void?
public typealias SwitchThemeBlock = ((now:AnyObject?, pre:AnyObject?) -> Void)
private class ObjectWrapper<T> {
    var value :T?
    init(value:T?) {
        self.value = value
    }
}

public extension UIView {
    private var ch_themeSwitchData: ThemeSwitchData? {
        get {
            return objc_getAssociatedObject(self, &kThemeLastSwitchKey) as? ThemeSwitchData
        }
        set {
            objc_setAssociatedObject(self, &kThemeLastSwitchKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var ch_switchThemeBlock:SwitchThemeBlock? {
        get {
            if let data =  objc_getAssociatedObject(self, &kThemeSwitchBlockKey) as? ObjectWrapper<SwitchThemeBlock> {
                return data.value
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &kThemeSwitchBlockKey, ObjectWrapper(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func ch_switchThemeWrapper(data:ThemeSwitchData?) {
        let preData = ch_themeSwitchData
        guard ThemeSwitchData.shouldUpdate(preData, lat: data) else {
            return
        }
        guard ch_shouldSwitchTheme(data?.extData, pre: preData?.extData) else {
            return
        }
        // save switch data
        ch_themeSwitchData = data
        
        // call switch theme method
        ch_switchTheme(data?.extData, pre: preData?.extData)
        
        // call switch theme block
        ch_switchThemeBlock?(now:data?.extData, pre:preData?.extData)
    }
    
    /**
     Specifies whether the view should change theme.
     true if the status bar should be hidden or false if it should be shown
     
     - parameter now: the data you switch theme
     - parameter pre: the old data you switch theme
     
     - returns: true switch theme will happen, or false ignore switch theme
     */
    public func ch_shouldSwitchTheme(now:AnyObject?, pre: AnyObject?) -> Bool {
        return true
    }
    
    public func ch_switchTheme(now:AnyObject?, pre: AnyObject?) {
        // switch sub views
        for sub in subviews {
            sub.ch_switchThemeWrapper(ch_themeSwitchData)
        }
    }
    
    /**
     switch self and subviews theme
     
     - parameter data: data used to switch theme, will pass to ch_switchTheme(_:pre:) as first argument
     */
    public func ch_switchTheme(data:AnyObject?) {
        ch_switchThemeWrapper(ThemeSwitchData.init(data: data))
    }
}

public extension UIViewController {
    private var ch_themeSwitchData: ThemeSwitchData? {
        get {
            return objc_getAssociatedObject(self, &kThemeLastSwitchKey) as? ThemeSwitchData
        }
        set {
            objc_setAssociatedObject(self, &kThemeLastSwitchKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// when theme switch happend, this block will run, default is nil
    /// Note: this block will run after ch_switchTheme(_:pre:) method
    var ch_switchThemeBlock:SwitchThemeBlock? {
        get {
            if let data =  objc_getAssociatedObject(self, &kThemeSwitchBlockKey) as? ObjectWrapper<SwitchThemeBlock> {
                return data.value
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &kThemeSwitchBlockKey, ObjectWrapper(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private func ch_switchThemeWrapper(data:ThemeSwitchData?) {
        let preData = ch_themeSwitchData
        guard ThemeSwitchData.shouldUpdate(preData, lat: data) else {
            return
        }
        guard ch_shouldSwitchTheme(data?.extData, pre: preData?.extData) else {
            return
        }
        // save switch data
        ch_themeSwitchData = data
        
        // call switch theme method
        ch_switchTheme(data?.extData, pre: preData?.extData)
        
        // call switch theme block
        ch_switchThemeBlock?(now:data?.extData, pre:preData?.extData)
    }
    
    /**
     Specifies whether the view controller should change theme.
     true if the status bar should be hidden or false if it should be shown
     
     - parameter now: the data you switch theme
     - parameter pre: the old data you switch theme
     
     - returns: true switch theme will happen, or false ignore switch theme
     */
    public func ch_shouldSwitchTheme(now:AnyObject?, pre: AnyObject?) -> Bool {
        return true
    }
    
    public func ch_switchTheme(now:AnyObject?, pre: AnyObject?) {
        // switch sub view controller
        for viewController in childViewControllers {
            viewController.ch_switchThemeWrapper(ch_themeSwitchData)
        }
    }
    
    /**
     switch self and childViewControllers's theme
     
     - parameter data: data used to switch theme, will pass to ch_switchTheme(_:pre:) as first argument
     */
    public func ch_switchTheme(data:AnyObject?) {
        ch_switchThemeWrapper(ThemeSwitchData.init(data: data))
    }
}


extension NSObject {
    class func ch_exchangeInstanceMethod(originalSelector:Selector, swizzledSelector:Selector) {
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

class WeakRef<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}

private class ThemeService {
    private var viewControllers = [WeakRef<UIViewController>]()
    
    static let instance = ThemeService()
    
    func switchTheme(data: AnyObject?) {
        let switchData = ThemeSwitchData.init(data: data)
        for window in UIApplication.sharedApplication().windows {
            // update view
            window.ch_switchThemeWrapper(switchData)
            // update view controller
            window.rootViewController?.ch_switchThemeWrapper(switchData)
        }
        // enforce update view controller
        for weakRef in viewControllers {
            if let viewController = weakRef.value where nil == viewController.parentViewController {
                viewController.ch_switchThemeWrapper(switchData)
            }
        }
    }
    
    private func registerViewController(controller: UIViewController) {
        var valideViewControllers = [WeakRef<UIViewController>]()
        for weakRef in viewControllers {
            if weakRef.value == controller {
                return
            }
            if let _ = weakRef.value {
                valideViewControllers.append(weakRef)
            }
        }
        valideViewControllers.append(WeakRef(value: controller))
        viewControllers = valideViewControllers
    }
}

public extension UIViewController {
    /**
     force view controller enable switch theme/skin
     Note: you call method if parentViewController is nil, normally you ignore it
     */
    func ch_registerViewController() {
        ThemeService.instance.registerViewController(self)
    }
}

public extension UIApplication {
    /**
     switch app theme
     
     - parameter data: data pass to view/viewcontroller's ch_switchTheme(_:pre:)
     */
    func ch_switchTheme(data: AnyObject?) {
        ThemeService.instance.switchTheme(data)
    }
    /**
     switch app theme
     
     - parameter data: data pass to view/viewcontroller's ch_switchTheme(_:pre:)
     */
    class func ch_switchTheme(data: AnyObject?) {
        ThemeService.instance.switchTheme(data)
    }
}

public class ThemeServiceConfig {
    // view config
    var viewAutoSwitchThemeAfterAwakeFromNib = false
    var viewAutoSwitchThemeAfterMovedToSuperView = false
    var viewAutoSwitchThemeWhenTableViewCellReused = false
    var viewAutoSwitchThemeWhenCollectionViewCellReused = false
    // view controller config
    var viewControllerAutoSwitchThemeAfterAwakeFromNib = false
    
    static let instance = ThemeServiceConfig()
}

public extension UIView {
    private var ch_themeServiceConfig:ThemeServiceConfig {
        return ThemeServiceConfig.instance
    }
    
    func ch_awakeFromNib() {
        ch_awakeFromNib()
        if ch_themeServiceConfig.viewAutoSwitchThemeAfterAwakeFromNib {
            ch_switchThemeWrapper(superview?.ch_themeSwitchData)
        }
    }
    
    func ch_didMoveToSuperview() {
        ch_didMoveToSuperview()
        if ch_themeServiceConfig.viewAutoSwitchThemeAfterMovedToSuperView {
            ch_switchThemeWrapper(superview?.ch_themeSwitchData)
        }
    }
    
    override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            ch_exchangeInstanceMethod(#selector(NSObject.awakeFromNib), swizzledSelector: #selector(UIView.ch_awakeFromNib))
            ch_exchangeInstanceMethod(#selector(UIView.didMoveToSuperview), swizzledSelector: #selector(UIView.ch_didMoveToSuperview))
        }
    }
}

public extension UITableViewCell {
    func ch_prepareForReuse() {
        ch_prepareForReuse()
        if ch_themeServiceConfig.viewAutoSwitchThemeWhenTableViewCellReused {
            ch_switchThemeWrapper(superview?.ch_themeSwitchData)
        }
    }
    
    override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            ch_exchangeInstanceMethod(#selector(UITableViewCell.prepareForReuse), swizzledSelector: #selector(UITableViewCell.ch_prepareForReuse))
        }
    }
}

public extension UICollectionReusableView {
    func ch_prepareForReuse() {
        ch_prepareForReuse()
        if ch_themeServiceConfig.viewAutoSwitchThemeWhenCollectionViewCellReused {
            ch_switchThemeWrapper(superview?.ch_themeSwitchData)
        }
    }
    
    override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            ch_exchangeInstanceMethod(#selector(UITableViewCell.prepareForReuse), swizzledSelector: #selector(UITableViewCell.ch_prepareForReuse))
        }
    }
}

public extension UIViewController {
    private var ch_themeServiceConfig:ThemeServiceConfig {
        return ThemeServiceConfig.instance
    }
    
    func ch_awakeFromNib() {
        ch_awakeFromNib()
        if ch_themeServiceConfig.viewAutoSwitchThemeAfterAwakeFromNib {
            ch_switchThemeWrapper(parentViewController?.ch_themeSwitchData)
        }
    }
    
    override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            ch_exchangeInstanceMethod(#selector(NSObject.awakeFromNib), swizzledSelector: #selector(UIView.ch_awakeFromNib))
            ch_exchangeInstanceMethod(#selector(UIView.didMoveToSuperview), swizzledSelector: #selector(UIView.ch_didMoveToSuperview))
        }
    }
}

