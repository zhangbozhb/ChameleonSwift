//
//  ChameleonSwift.swift
//  ChameleonSwift
//
//  Created by travel on 16/3/19.
//  Copyright © 2016年 travel. All rights reserved.
//

import Foundation
import UIKit

public class ThemeDataWraper<T> {
    var value :T?
    init(value:T?) {
        self.value = value
    }
}

class WeakRef<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}

public enum ThemeStyle: Int {
    case Day, Night
}

private class ThemeSwitchData {
    var lastTimestamp:Int64 = 0
    var lastSignature:String!
    var extData:AnyObject!
    
    init<T>(data:T?) {
        lastTimestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
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

internal class ThemeSwitchDataCenter {
    private var switchData:ThemeSwitchData!
    private var hasInited = false
    
    private init<T>(data:T?) {
        switchData = ThemeSwitchData.init(data: data)
    }
    
    private static let instance = ThemeSwitchDataCenter.init(data: ThemeStyle.Day)
    
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


private var kThemeLastSwitchKey: Void?
private var kThemeSwitchBlockKey: Void?
private var kThemeSwitchInternalConfigKey: Void?
/**
 Switch theme block
 
 - parameter now: type of ThemeDataWraper
 - parameter pre: type of ThemeDataWraper
 
 - returns: true switch theme will happen, or false ignore switch theme
 */
public typealias SwitchThemeBlock = ((now:AnyObject?, pre:AnyObject?) -> Void)
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
    public func ch_shouldSwitchTheme(now:AnyObject?, pre:AnyObject?) -> Bool {
        return true
    }
    
    /**
     method switch theme/skin. default will call it's subview to switch theme
     
     - parameter now: the data you switch theme
     - parameter pre: the old data you switch theme
     */
    public func ch_switchTheme(now:AnyObject?, pre:AnyObject?) {
        // switch sub views
        if ch_themeSwitchInternalConf.recursion {
            for sub in subviews {
                if ch_themeSwitchInternalConf.passConf {
                    sub.ch_themeSwitchInternalConf = ch_themeSwitchInternalConf
                }
                sub.ch_switchThemeWrapper(ch_themeSwitchData)
            }
        }
    }
    
    /**
     switch self and subviews theme
     
     - parameter data: data used to switch theme, will pass to ch_switchTheme(_:pre:) as first argument
     */
    final public func ch_switchTheme<T>(data:T?) {
        ch_themeSwitchInternalConf.passConf = true
        ch_themeSwitchInternalConf.recursion = true
        ch_themeSwitchInternalConf.dataSelf = true
        ch_switchThemeWrapper(ThemeSwitchData.init(data: data))
    }
    
    /**
     switch self and subviews theme, the data use depend on it config
     */
    final public func ch_switchTheme(refresh refresh:Bool = false) {
        ch_themeSwitchInternalConf.passConf = true
        ch_themeSwitchInternalConf.recursion = true
        if let data = ch_themeSwitchData where !refresh {
            ch_switchThemeWrapper(data)
        } else {
            ch_switchThemeWrapper(ThemeSwitchDataCenter.instance.switchData)
        }
    }
    
    /**
     this method should use internal for auto init
     */
    final internal func ch_switchThemeSelfInit() {
        ch_themeSwitchInternalConf.passConf = true
        ch_themeSwitchInternalConf.recursion = true
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
        
        // update status bar
        setNeedsStatusBarAppearanceUpdate()
    }
    
    /**
     Specifies whether the view controller should change theme.
     true if the status bar should be hidden or false if it should be shown
     
     - parameter now: the data you switch theme
     - parameter pre: the old data you switch theme
     
     - returns: true switch theme will happen, or false ignore switch theme
     */
    public func ch_shouldSwitchTheme(now:AnyObject?, pre:AnyObject?) -> Bool {
        return true
    }
    
    /**
     method switch theme/skin. default will call it's childViewControllers to switch theme
     
     - parameter now: the data you switch theme
     - parameter pre: the old data you switch theme
     */
    public func ch_switchTheme(now:AnyObject?, pre:AnyObject?) {
        // switch sub view controller
        if ch_themeSwitchInternalConf.recursion {
            for viewController in childViewControllers {
                if ch_themeSwitchInternalConf.passConf {
                    viewController.ch_themeSwitchInternalConf = ch_themeSwitchInternalConf
                }
                viewController.ch_switchThemeWrapper(ch_themeSwitchData)
            }
        }
    }
    
    /**
     switch self and childViewControllers's theme
     
     - parameter data: data used to switch theme, will pass to ch_switchTheme(_:pre:) as first argument
     */
    final public func ch_switchTheme<T>(data:T?) {
        ch_themeSwitchInternalConf.passConf = true
        ch_themeSwitchInternalConf.recursion = true
        ch_switchThemeWrapper(ThemeSwitchData.init(data: data))
    }
    
    /**
     switch self and subviews theme, the data use depend on it config
     */
    final public func ch_switchTheme(refresh refresh:Bool = false) {
        ch_themeSwitchInternalConf.passConf = true
        ch_themeSwitchInternalConf.recursion = true
        if let data = ch_themeSwitchData where !refresh {
            ch_switchThemeWrapper(data)
        } else {
            ch_switchThemeWrapper(ThemeSwitchDataCenter.instance.switchData)
        }
    }
    
    /**
     this method should use internal for auto init
     */
    final internal func ch_switchThemeSelfInit() {
        ch_themeSwitchInternalConf.passConf = true
        ch_themeSwitchInternalConf.recursion = true
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
            ch_switchThemeWrapper(ThemeSwitchDataCenter.instance.switchData)
        }
    }
}


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
    func ch_registerViewController() {
        ThemeService.instance.registerViewController(self)
    }
}

public extension UIApplication {
    /**
     switch app theme
     
     - parameter data: data pass to view/viewcontroller's ch_switchTheme(_:pre:)
     */
    func ch_switchTheme<T>(data: T? = nil) {
        ThemeService.instance.switchTheme(data)
    }
    /**
     switch app theme
     
     - parameter data: data pass to view/viewcontroller's ch_switchTheme(_:pre:)
     */
    class func ch_switchTheme<T>(data: T? = nil) {
        ThemeService.instance.switchTheme(data)
    }
}