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

public protocol ChameleonCallBackProtocol:class {
    /// switch theme
    ///
    /// - Parameters:
    ///   - now:  current wrapped theme data, however you can not use it directly, you should user ChameleonHelper<YourThemeType>.parse() to get real theme data
    ///   - pre: pre wrapped theme data. same to now
    func switchTheme(now: Any, pre: Any?)
}

protocol ChameleonProtocol:class {
    /// internal data used theme switch
    var data:ThemeSwitchData? {get set}
    
    /// interal config for theme switch
    var conf:ThemeSwitchInternalConf {get set}
    
    /// switch block
    var refreshBlock:SwitchThemeBlock? {get set}
    
    /// refresh call back protocal
    var callback:ChameleonCallBackProtocol? {get}
    
    /// childrens of ChameleonProtocol
    var childrens: [ChameleonProtocol] {get}
    
    
    /// call before switch theme
    func before()
    
    /// call after switch theme
    func after()
}

extension ChameleonProtocol {
    /// theme switch runner
    ///
    /// - Parameter data: theme switch data
    func workerWrapper(data:ThemeSwitchData) {
        let preData = self.data
        guard ThemeSwitchData.shouldUpdate(preData, lat: data) else {
            return
        }
        
        // save switch data
        self.data = data
        
        // before process
        before()
        
        // call switch theme callback
        callback?.switchTheme(now: data.extData, pre: preData?.extData)
        
        // call switch theme method
        worker(now: data, pre: preData)
        
        // call switch theme block
        refreshBlock?(data.extData, preData?.extData)
        
        // after process
        after()
    }
    
    /// theme switch process
    ///
    /// - Parameters:
    ///   - now: cur theme data for switch
    ///   - pre: pre theme data
    func worker(now: ThemeSwitchData, pre: ThemeSwitchData?) {
        guard conf.recursion else {
            return
        }
        
        if conf.passConf {
            for child in childrens {
                child.conf = conf
                child.workerWrapper(data: now)
            }
        } else {
            for child in childrens {
                child.workerWrapper(data: now)
            }
        }
    }
}

open class ThemeSwitch<DT:AnyObject>: ChameleonProtocol {
    /// owner
    weak var owner:DT?
    
    
    /// internal data used theme switch
    var data:ThemeSwitchData?
    
    /// interal config for theme switch
    var conf:ThemeSwitchInternalConf = ThemeSwitchInternalConf.init(passConf: true)
    
    
    /// switch block
    public var refreshBlock:SwitchThemeBlock?
    
    var childrens: [ChameleonProtocol] {
        if let v = owner as? UIView {
            return v.subviews.flatMap({ $0.ch })
        } else if let v = owner as? UIViewController {
            return v.childViewControllers.flatMap({ $0.ch })
        }
        return []
    }
    
    fileprivate init(owner:DT) {
        self.owner = owner
    }
    
    /// call before switch theme
    func before() {
        
    }
    /// call after switch theme
    func after() {
        if let v = owner as? UIViewController {
            v.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var callback:ChameleonCallBackProtocol? {
        return owner as? ChameleonCallBackProtocol
    }
    
    /// refresh self and children theme
    ///
    /// - Parameter data: ata: data used to switch theme, will pass to refreshBlock(data:pre:) as first argument
    public func refresh<T>(with data:T) {
        conf.passConf = true
        conf.recursion = true
        conf.dataSelf = true
        workerWrapper(data: ThemeSwitchData.init(data: data))
    }

    /// refresh self and children theme
    ///
    /// - Parameter refresh: true force refresh, false will use current theme
    public func refresh(refresh:Bool = true) {
        conf.passConf = true
        conf.recursion = true
        if let data = self.data {
            if refresh {
                workerWrapper(data: data.copyWithExtData())
            } else {
                workerWrapper(data: data)
            }
        } else {
            workerWrapper(data: ThemeSwitchDataCenter.shared.switchData)
        }
    }
    
    /**
     this method should use internal for auto init
     */
    func refreshSelfInit() {
        conf.passConf = true
        conf.recursion = true
        workerWrapper(data: ThemeSwitchDataCenter.shared.switchData)
    }
    
    /**
     this method should use internal for auto switch config (for circleCall method)
     */
    func refreshSelfOnly() {
        conf.passConf = false
        conf.recursion = false
        if let data = self.data , conf.dataSelf {
            workerWrapper(data: data)
        } else {
            workerWrapper(data: ThemeSwitchDataCenter.shared.switchData)
        }
    }
}

protocol ChameleonAccess {
    associatedtype ChameleonAccessDataType
    var ch: ChameleonAccessDataType { get }
}

private var kChameleonKey: Void?
extension UIView {
    public var ch: ThemeSwitch<UIView> {
        get {
            if let pre = objc_getAssociatedObject(self, &kChameleonKey) as? ThemeSwitch<UIView> {
                return pre
            }
            let now = ThemeSwitch.init(owner: self)
            objc_setAssociatedObject(self, &kChameleonKey, now, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return now
        }
    }
}

extension UIViewController {
    public var ch: ThemeSwitch<UIViewController> {
        get {
            if let pre = objc_getAssociatedObject(self, &kChameleonKey) as? ThemeSwitch<UIViewController> {
                return pre
            }
            let now = ThemeSwitch.init(owner: self)
            objc_setAssociatedObject(self, &kChameleonKey, now, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return now
        }
    }
}

// MARK: ThemeService
public var kChThemeSwitchNotification = "kChThemeSwitchNotification"
private class ThemeService {
    fileprivate var viewControllers = [WeakRef<UIViewController>]()
    
    static let shared = ThemeService()
    
    func refresh<T>(with data: T?) {
        let switchData = ThemeSwitchData.init(data: data)
        ThemeSwitchDataCenter.shared.switchData = switchData
        let internalConf = ThemeSwitchInternalConf.init(passConf: true)
        for window in UIApplication.shared.windows {
            // view
            window.ch.conf = internalConf
            window.ch.workerWrapper(data: switchData)
            
            // view controller
            window.rootViewController?.view.ch.conf = internalConf
            window.rootViewController?.view.ch.workerWrapper(data: switchData)
            window.rootViewController?.ch.conf = internalConf
            window.rootViewController?.ch.workerWrapper(data: switchData)
        }
        // enforce update view controller
        for weakRef in viewControllers {
            if let viewController = weakRef.value , nil == viewController.parent {
                viewController.view.ch.conf = internalConf
                viewController.view.ch.workerWrapper(data: switchData)
                viewController.ch.conf = internalConf
                viewController.ch.workerWrapper(data: switchData)
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
    
    fileprivate func register(controller: UIViewController) {
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


extension ThemeSwitch where DT: UIViewController {
    /**
     force view controller enable switch theme/skin
     Note: you call method if parentViewController is nil, normally you ignore it
     */
    public final func register() {
        if let vc = owner as? UIViewController {
            ThemeService.shared.register(controller: vc)
        }
    }
}

public final class ChameleonApplication {
    /// refresh app theme with data
    ///
    /// - Parameter data: theme data
    public func refresh<T>(with data:T) {
        ThemeService.shared.refresh(with: data)
    }
    
    /// refresh self and children theme
    ///
    /// - Parameter refresh: true force refresh, false will use current theme
    public func refresh(refresh:Bool = true) {
        if refresh {
            ThemeService.shared.refresh(with: ThemeSwitchDataCenter.shared.switchData.copyWithExtData())
        } else {
            ThemeService.shared.refresh(with: ThemeSwitchDataCenter.shared.switchData)
        }
    }
}

extension UIApplication {
    public final var ch:ChameleonApplication {
        return ChameleonApplication()
    }
    public class final var ch:ChameleonApplication {
        return ChameleonApplication()
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
public struct ThemeAutoSwitchType: OptionSet {
    private(set) public var rawValue:UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static var None = ThemeAutoSwitchType.init(rawValue: 0)
    public static var viewAwakeFromNib = ThemeAutoSwitchType.init(rawValue: 1 << 0)
    public static var viewDidMoveToWindow = ThemeAutoSwitchType.init(rawValue: 1 << 1)
    public static var viewControllerAwakeFromNib = ThemeAutoSwitchType.init(rawValue: 1 << 2)
    public static var viewControllerViewWillAppear = ThemeAutoSwitchType.init(rawValue: 1 << 3)
}

open class ThemeServiceConfig {
    /// auto switch types
    public var autoSwitch = ThemeAutoSwitchType.None{
        didSet {
            swizzledWithConfig()
        }
    }
    
    fileprivate init() {
    }
    
    
    /// is type auto switch enabled
    ///
    /// - Parameter type: auto switch type
    /// - Returns: true is enabled false is disabled
    public func isAuto(type:ThemeAutoSwitchType) -> Bool {
        return autoSwitch.contains(type)
    }

    open static let shared = ThemeServiceConfig()
    
    /**
     init theme data
     be awared: this method should call once
     
     - parameter data: theme
     
     - returns: void
     */
    open func initTheme<T>(data:T) {
        ThemeSwitchDataCenter.initThemeData(data)
    }
    
    // uset to accelerate speed
    fileprivate var autoViewAwakeFromNib = false
    fileprivate var autoViewDidMoveToWindow = false
    fileprivate var autoViewControllerAwakeFromNib = false
    fileprivate var autoViewControllerViewWillAppear = false
    // swizzele records
    fileprivate var swizzledRecords:[UInt: Bool] = [:]
    fileprivate func swizzledWithConfig() {
        
        let allTypes:[ThemeAutoSwitchType] = [.viewAwakeFromNib, .viewDidMoveToWindow, .viewControllerAwakeFromNib, .viewControllerViewWillAppear]
        for t in allTypes {
            let typeEnabled = autoSwitch.contains(t)
            switch t {
            case ThemeAutoSwitchType.viewAwakeFromNib:
                autoViewAwakeFromNib = typeEnabled
    
                if let _ = swizzledRecords[t.rawValue] {
                } else {
                    swizzledRecords[t.rawValue] = true
                    UIView.ch_swizzledMethod(#selector(UIView.awakeFromNib), swizzledSelector: #selector(UIView.ch_awakeFromNib))
                }
            case ThemeAutoSwitchType.viewDidMoveToWindow:
                autoViewDidMoveToWindow = typeEnabled
                
                
                if let _ = swizzledRecords[t.rawValue] {
                } else {
                    swizzledRecords[t.rawValue] = true
                    UIView.ch_swizzledMethod(#selector(UIView.didMoveToWindow), swizzledSelector: #selector(UIView.ch_didMoveToWindow))
                }
            case ThemeAutoSwitchType.viewControllerAwakeFromNib:
                autoViewControllerAwakeFromNib = typeEnabled
                
                
                if let _ = swizzledRecords[t.rawValue] {
                } else {
                    swizzledRecords[t.rawValue] = true
                    UIViewController.ch_swizzledMethod(#selector(UIViewController.awakeFromNib), swizzledSelector: #selector(UIViewController.ch_awakeFromNib))
                }
            case ThemeAutoSwitchType.viewControllerViewWillAppear:
                autoViewControllerViewWillAppear = typeEnabled
                
                
                if let _ = swizzledRecords[t.rawValue] {
                } else {
                    swizzledRecords[t.rawValue] = true
                    UIViewController.ch_swizzledMethod(#selector(UIViewController.viewWillAppear(_:)), swizzledSelector: #selector(UIViewController.ch_viewWillAppear(_:)))
                }
            default:
                break
            }
        }
    }
}

public extension UIView {
    func ch_awakeFromNib() {
        ch_awakeFromNib()
        if ThemeServiceConfig.shared.autoViewAwakeFromNib {
            ch.refreshSelfInit()
        }
    }
    
    func ch_didMoveToWindow() {
        ch_didMoveToWindow()
        if let _ = window , ThemeServiceConfig.shared.autoViewDidMoveToWindow {
            ch.refreshSelfOnly()
        }
    }
}

public extension UIViewController {
    func ch_awakeFromNib() {
        ch_awakeFromNib()
        if ThemeServiceConfig.shared.autoViewControllerAwakeFromNib {
            ch.refreshSelfInit()
        }
    }
    
    func ch_viewWillAppear(_ animated: Bool) {
        ch_viewWillAppear(animated)
        if ThemeServiceConfig.shared.autoViewControllerViewWillAppear {
            ch.refreshSelfOnly()
        }
    }
}


// MARK: Helper functions
/// theme helper
open class ChameleonHelper<T> where T: Hashable {
    
    /**
     get current theme
     
     - returns: current theme
     */
    public final class var current: T? {
        return ThemeSwitchDataCenter.themeData()
    }
    
    /**
     get current theme data
     
     - parameter data: theme data config for themes
     - parameter d:    default value if theme value for current thme is not in input data
     
     - returns: current theme value
     */
    public final class func currentThemeData<D>(_ data:[T: D], d:D? = nil) -> D? {
        if let s = self.current {
            return data[s]
        }
        return d
    }
    
    /**
     use parse theme from data
     this func used in refreshBlock(data:pre:), notificaiton (useinfo["data"])
     
     - parameter data: data to parse
     
     - returns: theme
     */
    public final class func parse(_ data: Any?) -> T? {
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
