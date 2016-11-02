//
//  ChameleonSwift.swift
//  ChameleonSwift
//
//  Created by travel on 16/3/19.
//
//  The MIT License (MIT)
//  Copyright © 2016年 travel.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of
//	this software and associated documentation files (the "Software"), to deal in
//	the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//	the Software, and to permit persons to whom the Software is furnished to do so,
//	subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import UIKit


// MARK: Data defined


/// theme data wrapper :unify process and avoid theme data type difference
final public class ThemeDataWraper<T> {
    public var value :T?
    init(value:T?) {
        self.value = value
    }
}

/// pre defined theme data
///
/// - day: day
/// - night: night
public enum ThemeStyle: Int {
    case day, night
}


/// wrapper object and maintain weak reference
fileprivate class WeakRef<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}


/// real data used in theme switch process
class ThemeSwitchData {
    var lastSignature:String!
    var extData:Any!    // ThemeDataWraper<T>
    
    fileprivate init(){
        lastSignature = UUID.init().uuidString
    }
    
    init<T>(data:T?) {
        lastSignature = UUID.init().uuidString
        extData = ThemeDataWraper.init(value: data)
    }
}


/// theme config used in theme switch process
class ThemeSwitchInternalConf {
    var dataSelf = false    // indicate where use data ThemeSwitchDataCenter, false will use ThemeSwitchDataCenter, true will use current
    var recursion = true
    var passConf = true    // switch config pass to subview/child view controller
    
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


/// used to store theme switch data
fileprivate class ThemeSwitchDataCenter {
    fileprivate var switchData:ThemeSwitchData!
    
    fileprivate init<T>(data:T?) {
        switchData = ThemeSwitchData.init(data: data)
    }
    
    fileprivate static let shared = ThemeSwitchDataCenter.init(data: ThemeStyle.day)
    
    
    class func initThemeData<T>(_ obj: T?) {
        shared.switchData = ThemeSwitchData.init(data: obj)
    }

    /**
     get current theme
     
     - returns: current theme
     */
    class func themeData<T>() -> T? {
        return shared.switchData.data()
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
public typealias SwitchThemeBlock = ((_ now: Any, _ pre: Any?) -> Void)
open class CHObjectWrapper<T> {
    var value :T?
    init(value:T?) {
        self.value = value
    }
}


// MARK: - extension ThemeSwitchData for convieniece usee
extension ThemeSwitchData {
    func data<T>() -> T? {
        if let d = extData as? ThemeDataWraper<T> {
            return d.value
        }
        return nil
    }
    
    class func shouldUpdate(_ pre:ThemeSwitchData?, lat:ThemeSwitchData?) -> Bool {
        if let pre = pre, let lat = lat , pre === lat {
            return false
        } else if let a = pre?.lastSignature, let b = lat?.lastSignature , a == b {
            return false
        }
        return true
    }
    
    func copyWithExtData() -> ThemeSwitchData {
        let copy = ThemeSwitchData()
        copy.extData = extData
        return copy
    }
}


/// theme switch protocol
protocol ThemeSwitchProtocol: class {
    /// data used to theme switch
    var _ch_themeSwitchData: ThemeSwitchData? {get set}
    
    /// data used to theme config
    var _ch_themeSwitchInternalConf: ThemeSwitchInternalConf {get set}
    
    /// theme switch block
    var _ch_switchThemeBlock:SwitchThemeBlock? {get set}
    
    /// theme switch process
    ///
    /// - Parameters:
    ///   - now: cur theme data for switch
    ///   - pre: pre theme data
    func ch_switchThemeWorker(now: ThemeSwitchData, pre: ThemeSwitchData?)
    
    
    /// process before theme switch happen
    func ch_switchThemeBefore()
    /// process after theme switch happen
    func ch_switchThemeAfter()
}


extension ThemeSwitchProtocol {
    
    /// theme switch runner
    ///
    /// - Parameter data: theme switch data
    func ch_switchThemeWrapper(_ data:ThemeSwitchData) {
        let preData = _ch_themeSwitchData
        guard ThemeSwitchData.shouldUpdate(preData, lat: data) else {
            return
        }
        // before process
        ch_switchThemeBefore()
        
        // save switch data
        _ch_themeSwitchData = data
        
        // call switch theme method
        ch_switchThemeWorker(now: data, pre: preData)
        
        // call switch theme block
        _ch_switchThemeBlock?(data.extData, preData?.extData)
        
        // after process
        ch_switchThemeAfter()
    }
    
    /**
     switch self and subviews theme
     
     - parameter data: data used to switch theme, will pass to ch_switchTheme(_:pre:) as first argument
     */
    func ch_switchTheme<T>(data:T) {
        _ch_themeSwitchInternalConf.passConf = true
        _ch_themeSwitchInternalConf.recursion = true
        _ch_themeSwitchInternalConf.dataSelf = true
        ch_switchThemeWrapper(ThemeSwitchData.init(data: data))
    }
    
    /**
     switch self and subviews theme
     */
    func ch_switchTheme(refresh:Bool) {
        _ch_themeSwitchInternalConf.passConf = true
        _ch_themeSwitchInternalConf.recursion = true
        if let data = _ch_themeSwitchData {
            if refresh {
                ch_switchThemeWrapper(data.copyWithExtData())
            } else {
                ch_switchThemeWrapper(data)
            }
        } else {
            ch_switchThemeWrapper(ThemeSwitchDataCenter.shared.switchData)
        }
    }
    
    /**
     this method should use internal for auto init
     */
    func ch_switchThemeSelfInit() {
        _ch_themeSwitchInternalConf.passConf = true
        _ch_themeSwitchInternalConf.recursion = true
        ch_switchThemeWrapper(ThemeSwitchDataCenter.shared.switchData)
    }
    
    /**
     this method should use internal for auto switch config (for circleCall method)
     */
    func ch_switchThemeSelfOnly() {
        _ch_themeSwitchInternalConf.passConf = false
        _ch_themeSwitchInternalConf.recursion = false
        if let data = _ch_themeSwitchData , _ch_themeSwitchInternalConf.dataSelf {
            ch_switchThemeWrapper(data)
        } else {
            ch_switchThemeWrapper(ThemeSwitchDataCenter.shared.switchData)
        }
    }
}


extension UIView :ThemeSwitchProtocol {
    var _ch_themeSwitchData: ThemeSwitchData? {
        get {
            return objc_getAssociatedObject(self, &kThemeLastSwitchKey) as? ThemeSwitchData
        }
        set {
            objc_setAssociatedObject(self, &kThemeLastSwitchKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var _ch_themeSwitchInternalConf: ThemeSwitchInternalConf {
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
    var _ch_switchThemeBlock:SwitchThemeBlock? {
        get {
            if let data =  objc_getAssociatedObject(self, &kThemeSwitchBlockKey) as? CHObjectWrapper<SwitchThemeBlock> {
                return data.value
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &kThemeSwitchBlockKey, CHObjectWrapper(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    func ch_switchThemeWorker(now: ThemeSwitchData, pre: ThemeSwitchData?) {
        ch_switchTheme(now.extData, pre: pre?.extData)
    }
    func ch_switchThemeBefore() {
    }
    func ch_switchThemeAfter() {
    }
}

extension UIViewController: ThemeSwitchProtocol {
    var _ch_themeSwitchData: ThemeSwitchData? {
        get {
            return objc_getAssociatedObject(self, &kThemeLastSwitchKey) as? ThemeSwitchData
        }
        set {
            objc_setAssociatedObject(self, &kThemeLastSwitchKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var _ch_themeSwitchInternalConf: ThemeSwitchInternalConf {
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
    var _ch_switchThemeBlock:SwitchThemeBlock? {
        get {
            if let data =  objc_getAssociatedObject(self, &kThemeSwitchBlockKey) as? CHObjectWrapper<SwitchThemeBlock> {
                return data.value
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &kThemeSwitchBlockKey, CHObjectWrapper(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    func ch_switchThemeWorker(now: ThemeSwitchData, pre: ThemeSwitchData?) {
        ch_switchTheme(now.extData, pre: pre?.extData)
    }
    func ch_switchThemeBefore() {
    }
    func ch_switchThemeAfter() {
        // update status bar
        setNeedsStatusBarAppearanceUpdate()
    }
}


public extension UIView {
    /// theme switch block
    public var ch_switchThemeBlock:SwitchThemeBlock? {
        set {
            _ch_switchThemeBlock = newValue
        }
        get {
            return _ch_switchThemeBlock
        }
    }
    
    /// theme switch worker
    ///
    /// - Parameters:
    ///   - now: current wrapped theme data, however you can not use it directly, you should user ThemeSwitchHelper<YourThemeType>.parseTheme() to get real theme data
    ///   - pre: current wrapped theme data. same to now
    public func ch_switchTheme(_ now: Any, pre: Any?) {
        // switch sub views
        if let data = _ch_themeSwitchData , _ch_themeSwitchInternalConf.recursion {
            for sub in subviews {
                if _ch_themeSwitchInternalConf.passConf {
                    sub._ch_themeSwitchInternalConf = _ch_themeSwitchInternalConf
                }
                sub.ch_switchThemeWrapper(data)
            }
        }
    }
    
    /**
     switch self and subviews theme
     
     - parameter data: data used to switch theme, will pass to ch_switchTheme(_:pre:) as first argument
     */
    public func ch_switch<T>(_ data:T) {
        self.ch_switchTheme(data: data)
    }
    
    /**
     switch self and subviews theme
     */
    public func ch_refresh(refresh:Bool = true) {
        ch_switchTheme(refresh: refresh)
    }
}

public extension UIViewController {
    /// theme switch block
    public var ch_switchThemeBlock:SwitchThemeBlock? {
        set {
            _ch_switchThemeBlock = newValue
        }
        get {
            return _ch_switchThemeBlock
        }
    }
    
    /// theme switch worker
    ///
    /// - Parameters:
    ///   - now: current wrapped theme data, however you can not use it directly, you should user ThemeSwitchHelper<YourThemeType>.parseTheme() to get real theme data
    ///   - pre: current wrapped theme data. same to now
    public func ch_switchTheme(_ now: Any, pre: Any?) {
        // switch sub view controller
        if let data = _ch_themeSwitchData , _ch_themeSwitchInternalConf.recursion {
            for viewController in childViewControllers {
                if _ch_themeSwitchInternalConf.passConf {
                    viewController._ch_themeSwitchInternalConf = _ch_themeSwitchInternalConf
                }
                viewController.ch_switchThemeWrapper(data)
            }
        }
    }
    
    /**
     switch self and subviews theme
     
     - parameter data: data used to switch theme, will pass to ch_switchTheme(_:pre:) as first argument
     */
    public func ch_switch<T>(_ data:T) {
        self.ch_switchTheme(data: data)
    }
    
    /**
     switch self and subviews theme
     */
    public func ch_refresh(refresh:Bool = true) {
        ch_switchTheme(refresh: refresh)
    }
}

// MARK: ThemeService
public var kChThemeSwitchNotification = "kChThemeSwitchNotification"
private class ThemeService {
    fileprivate var viewControllers = [WeakRef<UIViewController>]()
    
    static let instance = ThemeService()
    
    func switchTheme<T>(_ data: T?) {
        let switchData = ThemeSwitchData.init(data: data)
        ThemeSwitchDataCenter.shared.switchData = switchData
        let internalConf = ThemeSwitchInternalConf.init(passConf: true)
        for window in UIApplication.shared.windows {
            // view
            window._ch_themeSwitchInternalConf = internalConf
            window.ch_switchThemeWrapper(switchData)
            
            // view controller
            window.rootViewController?.view._ch_themeSwitchInternalConf = internalConf
            window.rootViewController?.view.ch_switchThemeWrapper(switchData)
            window.rootViewController?._ch_themeSwitchInternalConf = internalConf
            window.rootViewController?.ch_switchThemeWrapper(switchData)
        }
        // enforce update view controller
        for weakRef in viewControllers {
            if let viewController = weakRef.value , nil == viewController.parent {
                viewController.view._ch_themeSwitchInternalConf = internalConf
                viewController.view.ch_switchThemeWrapper(switchData)
                viewController._ch_themeSwitchInternalConf = internalConf
                viewController.ch_switchThemeWrapper(switchData)
            }
        }
        var userInfo:[String: ThemeDataWraper<T>] = [:]
        if let data = data {
            userInfo[kChThemeSwitchNotification] = ThemeDataWraper.init(value: data)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: kChThemeSwitchNotification),
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    fileprivate func registerViewController(_ controller: UIViewController) {
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
    public final func ch_switchTheme<T>(_ data: T) {
        ThemeService.instance.switchTheme(data)
    }
    /**
     switch app theme
     
     - parameter data: data pass to view/viewcontroller's ch_switchTheme(_:pre:)
     */
    public final class func ch_switchTheme<T>(_ data: T) {
        ThemeService.instance.switchTheme(data)
    }
}

// MARK: swizzle extension
public extension NSObject {
    public class func ch_swizzledMethod(_ originalSelector:Selector, swizzledSelector:Selector) {
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
    case uiViewAwakeFromNib
    case uiViewDidMoveToWindow
    case uiViewControllerAwakeFromNib
    case uiViewControllerViewWillAppear
}

open class ThemeServiceConfig {
    fileprivate init() {
    }
    
    // view config
    open var viewAutoSwitchThemeAfterAwakeFromNib = false {
        didSet {
            swizzledWithConfig()
        }
    }
    open var viewAutoSwitchThemeAfterMovedToWindow = false {
        didSet {
            swizzledWithConfig()
        }
    }
    // view controller config
    open var viewControllerAutoSwitchThemeAfterAwakeFromNib = false {
        didSet {
            swizzledWithConfig()
        }
    }
    open var viewControllerAutoSwitchThemeWhenViewWillAppear = false {
        didSet {
            swizzledWithConfig()
        }
    }
    
    open static let instance = ThemeServiceConfig()
    
    /**
     init theme data
     be awared: this method should call once
     
     - parameter data: theme
     
     - returns: void
     */
    open func initThemeData<T>(data:T) {
        ThemeSwitchDataCenter.initThemeData(data)
    }
    
    fileprivate var swizzledRecords:[ThemeSwizzledType: Bool] = [:]
    fileprivate func swizzledWithConfig() {
        if let _ = swizzledRecords[.uiViewAwakeFromNib] {
        } else if viewAutoSwitchThemeAfterAwakeFromNib {
            UIView.ch_swizzledMethod(#selector(UIView.awakeFromNib), swizzledSelector: #selector(UIView.ch_awakeFromNib))
            swizzledRecords[.uiViewAwakeFromNib] = true
        }
        if let _ = swizzledRecords[.uiViewDidMoveToWindow] {
        } else if viewAutoSwitchThemeAfterMovedToWindow {
            UIView.ch_swizzledMethod(#selector(UIView.didMoveToWindow), swizzledSelector: #selector(UIView.ch_didMoveToWindow))
            swizzledRecords[.uiViewDidMoveToWindow] = true
        }
        
        if let _ = swizzledRecords[.uiViewControllerAwakeFromNib] {
        } else if viewControllerAutoSwitchThemeAfterAwakeFromNib {
            UIViewController.ch_swizzledMethod(#selector(UIViewController.awakeFromNib), swizzledSelector: #selector(UIViewController.ch_awakeFromNib))
            swizzledRecords[.uiViewControllerAwakeFromNib] = true
        }
        if let _ = swizzledRecords[.uiViewControllerViewWillAppear] {
        } else if viewControllerAutoSwitchThemeWhenViewWillAppear {
            UIViewController.ch_swizzledMethod(#selector(UIViewController.viewWillAppear(_:)), swizzledSelector: #selector(UIViewController.ch_viewWillAppear(_:)))
            swizzledRecords[.uiViewControllerViewWillAppear] = true
        }
    }
}

public extension UIView {
    fileprivate var ch_themeServiceConfig:ThemeServiceConfig {
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
        if let _ = window , ch_themeServiceConfig.viewAutoSwitchThemeAfterMovedToWindow {
            ch_switchThemeSelfOnly()
        }
    }
}

public extension UIViewController {
    fileprivate var ch_themeServiceConfig:ThemeServiceConfig {
        return ThemeServiceConfig.instance
    }
    
    func ch_awakeFromNib() {
        ch_awakeFromNib()
        if ch_themeServiceConfig.viewControllerAutoSwitchThemeAfterAwakeFromNib {
            ch_switchThemeSelfInit()
        }
    }
    
    func ch_viewWillAppear(_ animated: Bool) {
        ch_viewWillAppear(animated)
        if ch_themeServiceConfig.viewControllerAutoSwitchThemeWhenViewWillAppear {
            ch_switchThemeSelfOnly()
        }
    }
}


// MARK: Helper functions
/// theme helper
open class ThemeSwitchHelper<T> where T: Hashable {
    
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
    public final class func currentThemeData<D>(_ data:[T: D], d:D? = nil) -> D? {
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
    public final class func parseTheme(_ data: Any?) -> T? {
        if let d = data as? ThemeDataWraper<T> {
            return d.value
        }
        return nil
    }
    
    /**
     get current theme image
     
     - parameter images: theme image config
     
     - returns: image
     */
    public final class func image(_ images:[T: UIImage]) -> UIImage? {
        return self.currentThemeData(images)
    }
    
    /**
     get current theme color
     
     - parameter colors: theme color config
     
     - returns: color
     */
    public final class func color(_ colors:[T: UIColor]) -> UIColor? {
        return self.currentThemeData(colors)
    }
}
