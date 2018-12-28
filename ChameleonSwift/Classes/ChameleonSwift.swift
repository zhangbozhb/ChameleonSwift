//
//  ChameleonSwift.swift
//  ChameleonSwift
//
//  Created by travel on 16/3/19.
//
//  The MIT License (MIT)
//  Copyright © 2016年 travel.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of
//    this software and associated documentation files (the "Software"), to deal in
//    the Software without restriction, including without limitation the rights to
//    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//    the Software, and to permit persons to whom the Software is furnished to do so,
//    subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import UIKit


// MARK: Data defined


/// theme data wrapper :unify process and avoid theme data type difference
final public class ThemeDataWraper<T> {
    public var value :T
    init(value:T) {
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
    let extData:Any    // ThemeDataWraper<T>

    init<T>(data:T) {
        extData = ThemeDataWraper.init(value: data)
    }
}

/// Theme switch run option
public struct ThemeSwitchOptions: OptionSet {
    private(set) public var rawValue:UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static var None = ThemeSwitchOptions.init(rawValue: 0)
    public static var `self` = ThemeSwitchOptions.init(rawValue: 1 << 0)    // theme swith on self
    public static var children = ThemeSwitchOptions.init(rawValue: 1 << 1)  // theme swith on children
    public static var forceRefresh = ThemeSwitchOptions.init(rawValue: 1 << 2)  // theme swith ignore data
    
    public static var `default`:ThemeSwitchOptions = [.self, .children]
}

/// used to store theme switch data
fileprivate class ThemeSwitchDataCenter {
    fileprivate var switchData:ThemeSwitchData
    
    fileprivate init<T>(data:T) {
        switchData = ThemeSwitchData.init(data: data)
    }
    
    fileprivate static let shared = ThemeSwitchDataCenter.init(data: Optional<Int>.none)
    
    
    class func initThemeData<T>(_ obj: T) {
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


// MARK: - extension ThemeSwitchData for convieniece usage
extension ThemeSwitchData {
    func data<T>() -> T? {
        if let d = extData as? ThemeDataWraper<T> {
            return d.value
        }
        return nil
    }
    
    class func shouldUpdate(_ pre:ThemeSwitchData?, lat:ThemeSwitchData?) -> Bool {
        if let pre = pre, let lat = lat, pre === lat {
            return false
        }
        return true
    }
}

@available(*, deprecated, message: "ChameleonCallBackProtocol is deprecated.", renamed: "ChameleonUIProtocol")
public typealias ChameleonCallBackProtocol = ChameleonUIProtocol

public protocol ChameleonUIProtocol:class {
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
    
    /// switch block
    var refreshBlock:SwitchThemeBlock? {get set}
    
    /// refresh call back protocal
    var callback:ChameleonUIProtocol {get}
    
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
    /// - Parameters:
    ///   - data: theme switch data
    ///   - option: theme switch option
    func workerWrapper(data:ThemeSwitchData, option:ThemeSwitchOptions) {
        let preData = self.data
        guard option.contains(.forceRefresh) || ThemeSwitchData.shouldUpdate(preData, lat: data) else {
            return
        }
        
        // save switch data
        self.data = data
        
        // call switch theme method on children
        if option.contains(.children) {
            for child in childrens {
                child.workerWrapper(data: data, option: option)
            }
        }
        
        guard option.contains(.self) else {
            return
        }
        
        // before process
        before()
        // call switch theme callback
        callback.switchTheme(now: data.extData, pre: preData?.extData)
        // call switch theme block
        refreshBlock?(data.extData, preData?.extData)
        // after process
        after()
    }
}

open class ThemeSwitch<DT: ChameleonUIProtocol>: ChameleonProtocol {
    /// owner
    unowned var owner:DT
    
    
    /// internal data used theme switch
    var data:ThemeSwitchData?
    
    /// switch block
    public var refreshBlock:SwitchThemeBlock?
    /// childrens of ChameleonProtocol
    var childrens: [ChameleonProtocol] {
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
    }
    
    var callback:ChameleonUIProtocol {
        return owner
    }
    
    /// refresh self and children theme
    ///
    /// - Parameter data: ata: data used to switch theme, will pass to refreshBlock(data:pre:) as first argument
    ///   - option: theme switch option
    public func refresh<T>(with data:T, option:ThemeSwitchOptions = [.self, .children, .forceRefresh]) {
        workerWrapper(data: ThemeSwitchData.init(data: data), option: option)
    }
    
    /// refresh self and children theme
    ///
    /// - Parameter refresh: true force refresh, false will use current theme
    public func refresh(refresh:Bool = true) {
        if let data = self.data {
            if refresh {
                workerWrapper(data: data, option: [.self, .children, .forceRefresh])
            } else {
                workerWrapper(data: data, option: .default)
            }
        } else {
            workerWrapper(data: ThemeSwitchDataCenter.shared.switchData, option: [.self, .children, .forceRefresh])
        }
    }
}

class ThemeSwitchView: ThemeSwitch<UIView> {
    override var childrens: [ChameleonProtocol] {
        return owner.subviews.compactMap({ $0.ch })
    }
}

class ThemeSwitchViewController: ThemeSwitch<UIViewController> {
    override var childrens: [ChameleonProtocol] {
        return owner.children.compactMap({ $0.ch })
    }
    
    override func after() {
        owner.setNeedsStatusBarAppearanceUpdate()
    }
}

protocol ChameleonAccess {
    associatedtype ChameleonAccessDataType
    var ch: ChameleonAccessDataType { get }
}

private var kChameleonKey: Void?
public extension UIView {
    public var ch: ThemeSwitch<UIView> {
        get {
            if let pre = objc_getAssociatedObject(self, &kChameleonKey) as? ThemeSwitch<UIView> {
                return pre
            }
            let now = ThemeSwitchView.init(owner: self)
            objc_setAssociatedObject(self, &kChameleonKey, now, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return now
        }
    }
}

public extension UIViewController {
    public var ch: ThemeSwitch<UIViewController> {
        get {
            if let pre = objc_getAssociatedObject(self, &kChameleonKey) as? ThemeSwitch<UIViewController> {
                return pre
            }
            let now = ThemeSwitchViewController.init(owner: self)
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
    
    func refresh<T>(with data: T) {
        let switchData = ThemeSwitchData.init(data: data)
        ThemeSwitchDataCenter.shared.switchData = switchData
        let option:ThemeSwitchOptions = [.self, .children, .forceRefresh]
        for window in UIApplication.shared.windows {
            // view
            window.ch.workerWrapper(data: switchData, option: option)
            
            // view controller
            window.rootViewController?.view.ch.workerWrapper(data: switchData, option: option)
            window.rootViewController?.ch.workerWrapper(data: switchData, option: option)
        }
        // enforce update view controller
        for weakRef in viewControllers {
            if let viewController = weakRef.value , nil == viewController.parent {
                viewController.view.ch.workerWrapper(data: switchData, option: option)
                viewController.ch.workerWrapper(data: switchData, option: option)
            }
        }
        let userInfo:[String: ThemeDataWraper<T>] = [ kChThemeSwitchNotification :  ThemeDataWraper.init(value: data)]
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


public extension ThemeSwitch where DT: UIViewController {
    /**
     force view controller enable switch theme/skin
     Note: you call method if parentViewController is nil, normally you ignore it
     */
    public final func register() {
        ThemeService.shared.register(controller: owner)
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
        ThemeService.shared.refresh(with: ThemeSwitchDataCenter.shared.switchData)
    }
}

public extension UIApplication {
    public final var ch:ChameleonApplication {
        return ChameleonApplication()
    }
    public class final var ch:ChameleonApplication {
        return ChameleonApplication()
    }
}

// MARK: swizzle extension
extension NSObject {
    public class func ch_swizzledInstanceMethod(_ originalSelector:Selector, swizzledSelector:Selector) {
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
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
    
    public static let shared = ThemeServiceConfig()
    
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
                    UIView.ch_swizzledInstanceMethod(#selector(UIView.awakeFromNib), swizzledSelector: #selector(UIView.ch_awakeFromNib))
                }
            case ThemeAutoSwitchType.viewDidMoveToWindow:
                autoViewDidMoveToWindow = typeEnabled
                
                
                if let _ = swizzledRecords[t.rawValue] {
                } else {
                    swizzledRecords[t.rawValue] = true
                    UIView.ch_swizzledInstanceMethod(#selector(UIView.didMoveToWindow), swizzledSelector: #selector(UIView.ch_didMoveToWindow))
                }
            case ThemeAutoSwitchType.viewControllerAwakeFromNib:
                autoViewControllerAwakeFromNib = typeEnabled
                
                
                if let _ = swizzledRecords[t.rawValue] {
                } else {
                    swizzledRecords[t.rawValue] = true
                    UIViewController.ch_swizzledInstanceMethod(#selector(UIViewController.awakeFromNib), swizzledSelector: #selector(UIViewController.ch_awakeFromNib))
                }
            case ThemeAutoSwitchType.viewControllerViewWillAppear:
                autoViewControllerViewWillAppear = typeEnabled
                
                
                if let _ = swizzledRecords[t.rawValue] {
                } else {
                    swizzledRecords[t.rawValue] = true
                    UIViewController.ch_swizzledInstanceMethod(#selector(UIViewController.viewWillAppear(_:)), swizzledSelector: #selector(UIViewController.ch_viewWillAppear(_:)))
                }
            default:
                break
            }
        }
    }
}

@objc public extension UIView {
    func ch_awakeFromNib() {
        ch_awakeFromNib()
        if ThemeServiceConfig.shared.autoViewAwakeFromNib {
            ch.workerWrapper(data: ThemeSwitchDataCenter.shared.switchData, option: .self)
        }
    }
    
    func ch_didMoveToWindow() {
        ch_didMoveToWindow()
        if let _ = window , ThemeServiceConfig.shared.autoViewDidMoveToWindow {
            ch.workerWrapper(data: ThemeSwitchDataCenter.shared.switchData, option: .self)
        }
    }
}

@objc public extension UIViewController {
    func ch_awakeFromNib() {
        ch_awakeFromNib()
        if ThemeServiceConfig.shared.autoViewControllerAwakeFromNib {
            ch.workerWrapper(data: ThemeSwitchDataCenter.shared.switchData, option: .self)
        }
    }
    
    func ch_viewWillAppear(_ animated: Bool) {
        ch_viewWillAppear(animated)
        if ThemeServiceConfig.shared.autoViewControllerViewWillAppear {
            ch.workerWrapper(data: ThemeSwitchDataCenter.shared.switchData, option: .self)
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
    public final class func currentData<D>(_ data:[T: D], d:D? = nil) -> D? {
        if let s = self.current {
            return data[s]
        }
        return d
    }
    /**
     get current theme data
     
     - parameter data: theme data config for themes
     - parameter d:    default value if theme value for current thme is not in input data
     
     - returns: current theme value
     */
    @available(*, deprecated, message: "currentThemeData is deprecated.", renamed: "currentData")
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
        return self.currentData(images)
    }
    
    /**
     get current theme color
     
     - parameter colors: theme color config
     
     - returns: color
     */
    public final class func color(_ colors:[T: UIColor]) -> UIColor? {
        return self.currentData(colors)
    }
}



// MARK: - extention view default, you can override it
@objc extension UIView : ChameleonUIProtocol {
    open func switchTheme(now: Any, pre: Any?){
    }
}

// MARK: - extention view default, you can override it
@objc extension UIViewController : ChameleonUIProtocol {
    open func switchTheme(now: Any, pre: Any?){
    }
}

