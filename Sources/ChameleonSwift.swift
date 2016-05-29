//
//  ChameleonSwift.swift
//  ChameleonSwift
//
//  Created by travel on 16/3/19.
//  Copyright © 2016年 travel. All rights reserved.
//

import Foundation
import UIKit


// MARK: Data defined
public class ThemeDataWraper<T> {
    var value :T?
    init(value:T?) {
        self.value = value
    }
}

public class WeakRef<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}

public enum ThemeStyle: Int {
    case Day, Night
}

private class ThemeSwitchData {
    var lastSignature:String!
    var extData:AnyObject!
    
    init<T>(data:T?) {
        lastSignature = NSUUID.init().UUIDString
        extData = ThemeDataWraper.init(value: data)
    }
    
    func data<T>() -> T? {
        if let d = extData as? ThemeDataWraper<T> {
            return d.value
        }
        return nil
    }
    
    class func shouldUpdate(pre:ThemeSwitchData?, lat:ThemeSwitchData?) -> Bool {
        if let pre = pre, lat = lat where pre === lat {
            return false
        } else if let a = pre?.lastSignature, b = lat?.lastSignature where a == b {
            return false
        }
        return true
    }
}

private func kThemeInitChecking() {
    if !ThemeSwitchDataCenter.instance.hasInited {
        print("Warning: ThemeServiceConfig has not initThemeData")
    }
}
private class ThemeSwitchDataCenter {
    private var switchData:ThemeSwitchData!
    private var hasInited = false
    
    private init<T>(data:T?) {
        switchData = ThemeSwitchData.init(data: data)
    }

    private static let instance = ThemeSwitchDataCenter.init(data: ThemeSwitchData.init(data:  ThemeStyle.Day)) // here defined a wrapper type as default data(is invalid data)
    
    class func initThemeData<T>(obj: T?) {
        if !self.instance.hasInited {
            self.instance.switchData = ThemeSwitchData.init(data: obj)
            self.instance.hasInited = true
        } else {
            assertionFailure("should call only once at app start")
        }
    }
    /**
     get current theme
     
     - returns: current theme
     */
    class func themeData<T>() -> T? {
        assert(ThemeSwitchDataCenter.instance.hasInited, " ThemeServiceConfig has not initThemeData")
        return self.instance.switchData.data()
    }
}

private class ThemeSwitchInternalConf {
    var dataSelf = false    // indicate where use data ThemeSwitchDataCenter, false will use ThemeSwitchDataCenter, true will use current
    var recursion = true
    private(set) var passConf = true    // switch config pass to subview/child view controller
    
    init() {
    }
    
    convenience init(passConf:Bool) {
        self.init()
        self.passConf = passConf
    }
    
    func copy() -> ThemeSwitchInternalConf {
        let other = ThemeSwitchInternalConf.init()
        other.recursion = recursion
        other.passConf = passConf
        return other
    }
}

// MARK: View /View controller Switch extension
private var kThemeLastSwitchKey: Void?
private var kThemeSwitchBlockKey: Void?
private var kThemeSwitchInternalConfigKey: Void?
/**
 Switch theme block
 
 - parameter now: type of ThemeDataWraper
 - parameter pre: type of ThemeDataWraper
 
 - returns: true switch theme will happen, or false ignore switch theme
 */
public typealias SwitchThemeBlock = ((now: AnyObject, pre: AnyObject?) -> Void)
public class ObjectWrapper<T> {
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
    
    private var ch_themeSwitchInternalConf: ThemeSwitchInternalConf {
        get {
            if let conf = objc_getAssociatedObject(self, &kThemeSwitchInternalConfigKey) as? ThemeSwitchInternalConf {
                return conf
            } else {
                let conf = ThemeSwitchInternalConf.init(passConf: true)
                objc_setAssociatedObject(self, &kThemeSwitchInternalConfigKey, conf, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return conf
            }
        }
        set {
            objc_setAssociatedObject(self, &kThemeSwitchInternalConfigKey, newValue.copy(), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
        /// Switch theme block
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
    
    func ch_setSwitchThemeBlock(block:SwitchThemeBlock?)  {
        ch_switchThemeBlock = block
    }
    
    private func ch_switchThemeWrapper(data:ThemeSwitchData) {
        let preData = ch_themeSwitchData
        guard ThemeSwitchData.shouldUpdate(preData, lat: data) else {
            return
        }
        // save switch data
        ch_themeSwitchData = data
        
        // call switch theme method
        ch_switchTheme(data.extData, pre: preData?.extData)
        
        // call switch theme block
        ch_switchThemeBlock?(now:data.extData, pre:preData?.extData)
    }
    
    /**
     method switch theme/skin. default will call it's subview to switch theme
     
     - parameter now: the data you switch theme
     - parameter pre: the old data you switch theme
     */
    public func ch_switchTheme(now: AnyObject, pre: AnyObject?) {
        // switch sub views
        if let data = ch_themeSwitchData where ch_themeSwitchInternalConf.recursion {
            for sub in subviews {
                if ch_themeSwitchInternalConf.passConf {
                    sub.ch_themeSwitchInternalConf = ch_themeSwitchInternalConf
                }
                sub.ch_switchThemeWrapper(data)
            }
        }
    }
    
    /**
     switch self and subviews theme
     
     - parameter data: data used to switch theme, will pass to ch_switchTheme(_:pre:) as first argument
     */
    final public func ch_switchTheme<T>(data:T) {
        ch_themeSwitchInternalConf.passConf = true
        ch_themeSwitchInternalConf.recursion = true
        ch_themeSwitchInternalConf.dataSelf = true
        ch_switchThemeWrapper(ThemeSwitchData.init(data: data))
    }
    
    /**
     switch self and subviews theme, the data use depend on it config
     */
    final public func ch_switchTheme(refresh refresh:Bool = true) {
        ch_themeSwitchInternalConf.passConf = true
        ch_themeSwitchInternalConf.recursion = true
        if let data = ch_themeSwitchData {
            if refresh {
                ch_switchThemeWrapper(ThemeSwitchData.init(data: data.extData?.data))
            } else {
                ch_switchThemeWrapper(data)
            }
        } else {
            kThemeInitChecking()
            ch_switchThemeWrapper(ThemeSwitchDataCenter.instance.switchData)
        }
    }
    
    /**
     this method should use internal for auto init
     */
    final internal func ch_switchThemeSelfInit() {
        ch_themeSwitchInternalConf.passConf = true
        ch_themeSwitchInternalConf.recursion = true
        kThemeInitChecking()
        ch_switchThemeWrapper(ThemeSwitchDataCenter.instance.switchData)
    }
    
    /**
     this method should use internal for auto switch config (for circleCall method)
     */
    final internal func ch_switchThemeSelfOnly() {
        ch_themeSwitchInternalConf.passConf = false
        ch_themeSwitchInternalConf.recursion = false
        if let data = ch_themeSwitchData where ch_themeSwitchInternalConf.dataSelf {
            ch_switchThemeWrapper(data)
        } else {
            kThemeInitChecking()
            ch_switchThemeWrapper(ThemeSwitchDataCenter.instance.switchData)
        }
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
    
    private var ch_themeSwitchInternalConf: ThemeSwitchInternalConf {
        get {
            if let conf = objc_getAssociatedObject(self, &kThemeSwitchInternalConfigKey) as? ThemeSwitchInternalConf {
                return conf
            } else {
                let conf = ThemeSwitchInternalConf.init(passConf: true)
                objc_setAssociatedObject(self, &kThemeSwitchInternalConfigKey, conf, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return conf
            }
        }
        set {
            objc_setAssociatedObject(self, &kThemeSwitchInternalConfigKey, newValue.copy(), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func ch_setSwitchThemeBlock(block:SwitchThemeBlock?)  {
        ch_switchThemeBlock = block
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
    
    private func ch_switchThemeWrapper(data:ThemeSwitchData) {
        let preData = ch_themeSwitchData
        guard ThemeSwitchData.shouldUpdate(preData, lat: data) else {
            return
        }
        // save switch data
        ch_themeSwitchData = data
        
        // call switch theme method
        ch_switchTheme(data.extData, pre: preData?.extData)
        
        // call switch theme block
        ch_switchThemeBlock?(now:data.extData, pre:preData?.extData)
        
        // update status bar
        setNeedsStatusBarAppearanceUpdate()
    }
    
    /**
     method switch theme/skin. default will call it's childViewControllers to switch theme
     
     - parameter now: the data you switch theme
     - parameter pre: the old data you switch theme
     */
    public func ch_switchTheme(now: AnyObject, pre: AnyObject?) {
        // switch sub view controller
        if let data = ch_themeSwitchData where ch_themeSwitchInternalConf.recursion {
            for viewController in childViewControllers {
                if ch_themeSwitchInternalConf.passConf {
                    viewController.ch_themeSwitchInternalConf = ch_themeSwitchInternalConf
                }
                viewController.ch_switchThemeWrapper(data)
            }
        }
    }
    
    /**
     switch self and childViewControllers's theme
     
     - parameter data: data used to switch theme, will pass to ch_switchTheme(_:pre:) as first argument
     */
    final public func ch_switchTheme<T>(data:T) {
        ch_themeSwitchInternalConf.passConf = true
        ch_themeSwitchInternalConf.recursion = true
        ch_switchThemeWrapper(ThemeSwitchData.init(data: data))
    }
    
    /**
     switch self and subviews theme, the data use depend on it config
     */
    final public func ch_switchTheme(refresh refresh:Bool = true) {
        ch_themeSwitchInternalConf.passConf = true
        ch_themeSwitchInternalConf.recursion = true
        if let data = ch_themeSwitchData {
            if refresh {
                ch_switchThemeWrapper(ThemeSwitchData.init(data: data.extData?.data))
            } else {
                ch_switchThemeWrapper(data)
            }
        } else {
            kThemeInitChecking()
            ch_switchThemeWrapper(ThemeSwitchDataCenter.instance.switchData)
        }
    }
    
    /**
     this method should use internal for auto init
     */
    final internal func ch_switchThemeSelfInit() {
        ch_themeSwitchInternalConf.passConf = true
        ch_themeSwitchInternalConf.recursion = true
        kThemeInitChecking()
        ch_switchThemeWrapper(ThemeSwitchDataCenter.instance.switchData)
    }
    
    /**
     this method should use internal for auto switch config (for circleCall method)
     */
    final internal func ch_switchThemeSelfOnly() {
        ch_themeSwitchInternalConf.passConf = false
        ch_themeSwitchInternalConf.recursion = false
        if let data = ch_themeSwitchData where ch_themeSwitchInternalConf.dataSelf {
            ch_switchThemeWrapper(data)
        } else {
            kThemeInitChecking()
            ch_switchThemeWrapper(ThemeSwitchDataCenter.instance.switchData)
        }
    }
}

// MARK: ThemeService
public var kChThemeSwitchNotification = "kChThemeSwitchNotification"
private class ThemeService {
    private var viewControllers = [WeakRef<UIViewController>]()
    
    static let instance = ThemeService()
    
    func switchTheme<T>(data: T?) {
        let switchData = ThemeSwitchData.init(data: data)
        ThemeSwitchDataCenter.instance.switchData = switchData
        let internalConf = ThemeSwitchInternalConf.init(passConf: true)
        for window in UIApplication.sharedApplication().windows {
            // view
            window.ch_themeSwitchInternalConf = internalConf
            window.ch_switchThemeWrapper(switchData)
            
            // view controller
            window.rootViewController?.view.ch_themeSwitchInternalConf = internalConf
            window.rootViewController?.view.ch_switchThemeWrapper(switchData)
            window.rootViewController?.ch_themeSwitchInternalConf = internalConf
            window.rootViewController?.ch_switchThemeWrapper(switchData)
        }
        // enforce update view controller
        for weakRef in viewControllers {
            if let viewController = weakRef.value where nil == viewController.parentViewController {
                viewController.view.ch_themeSwitchInternalConf = internalConf
                viewController.view.ch_switchThemeWrapper(switchData)
                viewController.ch_themeSwitchInternalConf = internalConf
                viewController.ch_switchThemeWrapper(switchData)
            }
        }
        var userInfo:[String: ThemeDataWraper<T>] = [:]
        if let data = data {
            userInfo[kChThemeSwitchNotification] = ThemeDataWraper.init(value: data)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(kChThemeSwitchNotification,
                                                                  object: nil,
                                                                  userInfo: userInfo)
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
    public final func ch_registerViewController() {
        ThemeService.instance.registerViewController(self)
    }
}

public extension UIApplication {
    /**
     switch app theme
     
     - parameter data: data pass to view/viewcontroller's ch_switchTheme(_:pre:)
     */
    public final func ch_switchTheme<T>(data: T) {
        ThemeService.instance.switchTheme(data)
    }
    /**
     switch app theme
     
     - parameter data: data pass to view/viewcontroller's ch_switchTheme(_:pre:)
     */
    public final class func ch_switchTheme<T>(data: T) {
        ThemeService.instance.switchTheme(data)
    }
}



// MARK: swizzle extension
public extension NSObject {
    public class func ch_swizzledMethod(originalSelector:Selector, swizzledSelector:Selector) {
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

// MARK: config
private enum ThemeSwizzledType: Int {
    case UIViewAwakeFromNib
    case UIViewDidMoveToWindow
    case UIViewControllerAwakeFromNib
    case UIViewControllerViewWillAppear
}

public class ThemeServiceConfig {
    private init() {
    }
    
    // view config
    public var viewAutoSwitchThemeAfterAwakeFromNib = false {
        didSet {
            swizzledWithConfig()
        }
    }
    public var viewAutoSwitchThemeAfterMovedToWindow = false {
        didSet {
            swizzledWithConfig()
        }
    }
    // view controller config
    public var viewControllerAutoSwitchThemeAfterAwakeFromNib = false {
        didSet {
            swizzledWithConfig()
        }
    }
    public var viewControllerAutoSwitchThemeWhenViewWillAppear = false {
        didSet {
            swizzledWithConfig()
        }
    }
    
    public static let instance = ThemeServiceConfig()
    
    /**
     init theme data
     be awared: this method should call once
     
     - parameter data: theme
     
     - returns: void
     */
    public func initThemeData<T>(data data:T) {
        ThemeSwitchDataCenter.initThemeData(data)
    }
    
    private var swizzledRecords:[ThemeSwizzledType: Bool] = [:]
    private func swizzledWithConfig() {
        if let _ = swizzledRecords[.UIViewAwakeFromNib] {
        } else if viewAutoSwitchThemeAfterAwakeFromNib {
            UIView.ch_swizzledMethod(#selector(UIView.awakeFromNib), swizzledSelector: #selector(UIView.ch_awakeFromNib))
            swizzledRecords[.UIViewAwakeFromNib] = true
        }
        if let _ = swizzledRecords[.UIViewDidMoveToWindow] {
        } else if viewAutoSwitchThemeAfterMovedToWindow {
            UIView.ch_swizzledMethod(#selector(UIView.didMoveToWindow), swizzledSelector: #selector(UIView.ch_didMoveToWindow))
            swizzledRecords[.UIViewDidMoveToWindow] = true
        }
        
        if let _ = swizzledRecords[.UIViewControllerAwakeFromNib] {
        } else if viewControllerAutoSwitchThemeAfterAwakeFromNib {
            UIViewController.ch_swizzledMethod(#selector(UIViewController.awakeFromNib), swizzledSelector: #selector(UIViewController.ch_awakeFromNib))
            swizzledRecords[.UIViewControllerAwakeFromNib] = true
        }
        if let _ = swizzledRecords[.UIViewControllerViewWillAppear] {
        } else if viewControllerAutoSwitchThemeWhenViewWillAppear {
            UIViewController.ch_swizzledMethod(#selector(UIViewController.viewWillAppear(_:)), swizzledSelector: #selector(UIViewController.ch_viewWillAppear(_:)))
            swizzledRecords[.UIViewControllerViewWillAppear] = true
        }
    }
}

public extension UIView {
    private var ch_themeServiceConfig:ThemeServiceConfig {
        return ThemeServiceConfig.instance
    }
    
    func ch_awakeFromNib() {
        ch_awakeFromNib()
        if ch_themeServiceConfig.viewAutoSwitchThemeAfterAwakeFromNib {
            ch_switchThemeSelfInit()
        }
    }
    
    func ch_didMoveToWindow() {
        ch_didMoveToWindow()
        if let _ = window where ch_themeServiceConfig.viewAutoSwitchThemeAfterMovedToWindow {
            ch_switchThemeSelfOnly()
        }
    }
}

public extension UIViewController {
    private var ch_themeServiceConfig:ThemeServiceConfig {
        return ThemeServiceConfig.instance
    }
    
    func ch_awakeFromNib() {
        ch_awakeFromNib()
        if ch_themeServiceConfig.viewControllerAutoSwitchThemeAfterAwakeFromNib {
            ch_switchThemeSelfInit()
        }
    }
    
    func ch_viewWillAppear(animated: Bool) {
        ch_viewWillAppear(animated)
        if ch_themeServiceConfig.viewControllerAutoSwitchThemeWhenViewWillAppear {
            ch_switchThemeSelfOnly()
        }
    }
}


// MARK: Helper functions
/// theme helper
public class ThemeSwitchHelper<T where T: Hashable> {
    
    /**
     get current theme
     
     - returns: current theme
     */
    public final class func currentTheme() -> T? {
        return ThemeSwitchDataCenter.themeData()
    }
    
    /**
     get current theme data
     
     - parameter data: theme data config for themes
     - parameter d:    default value if theme value for current thme is not in input data
     
     - returns: current theme value
     */
    public final class func currentThemeData<D>(data:[T: D], d:D? = nil) -> D? {
        if let s = self.currentTheme() {
            return data[s]
        }
        return d
    }
    
    /**
     use parse theme from data
     this func used in ch_switchTheme(_:pre:), notificaiton (useinfo["data"])
     
     - parameter data: data to parse
     
     - returns: theme
     */
    public final class func parseTheme(data: AnyObject?) -> T? {
        if let d = data as? ThemeDataWraper<T> {
            return d.value
        }
        kThemeInitChecking()
        return nil
    }
    
    /**
     get current theme image
     
     - parameter images: theme image config
     
     - returns: image
     */
    public final class func image(images:[T: UIImage]) -> UIImage? {
        return self.currentThemeData(images)
    }
    
    /**
     get current theme color
     
     - parameter colors: theme color config
     
     - returns: color
     */
    public final class func color(colors:[T: UIColor]) -> UIColor? {
        return self.currentThemeData(colors)
    }
}