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

private class ThemeSwitchDataMananger {
    private(set) var switchData:ThemeSwitchData?
    
    static let instance = ThemeSwitchDataMananger()
    
    func updateSwitchData(data:AnyObject?, signature:String? = nil) -> ThemeSwitchData {
        switchData = ThemeSwitchData.init(data: data, signature:signature)
        return switchData!
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
    
    private var ch_dataMananger:ThemeSwitchDataMananger {
        return ThemeSwitchDataMananger.instance
    }
    
    private func ch_switchTheme() {
        let now = ch_dataMananger.switchData
        let pre = ch_themeSwitchData
        guard ch_shouldSwitchTheme(now?.extData, pre: pre?.extData) else {
            return
        }
        guard ThemeSwitchData.shouldUpdate(pre, lat: now) else {
            return
        }
        
        ch_switchTheme(now?.extData, pre: pre?.extData)
        ch_themeSwitchData = now
    }
    
    public func ch_shouldSwitchTheme(now:AnyObject?, pre: AnyObject?) -> Bool {
        return true
    }
    
    public func ch_switchTheme(now:AnyObject?, pre: AnyObject?) {
        guard ch_shouldSwitchTheme(now, pre: pre) else {
            return
        }
        // switch sub views
        for view in subviews {
            view.ch_switchTheme()
        }
        // call switch theme block
        ch_switchThemeBlock?(now:now, pre:pre)
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
    
    private var ch_dataMananger:ThemeSwitchDataMananger {
        return ThemeSwitchDataMananger.instance
    }
    
    private func ch_switchTheme() {
        let now = ch_dataMananger.switchData
        let pre = ch_themeSwitchData
        guard ch_shouldSwitchTheme(now?.extData, pre: pre?.extData) else {
            return
        }
        guard ThemeSwitchData.shouldUpdate(pre, lat: now) else {
            return
        }
        
        ch_switchTheme(now?.extData, pre: pre?.extData)
        ch_themeSwitchData = now
    }
    
    public func ch_shouldSwitchTheme(now:AnyObject?, pre: AnyObject?) -> Bool {
        return true
    }
    
    public func ch_switchTheme(now:AnyObject?, pre: AnyObject?) {
        
        // switch sub viewcontroerl
        for viewController in childViewControllers {
            viewController.ch_switchTheme()
        }
        // call switch theme block
        ch_switchThemeBlock?(now:now, pre:pre)
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

public class ThemeService {
    private var viewControllers = [WeakRef<UIViewController>]()
    
    static let instance = ThemeService()
    
    public func switchTheme(data: AnyObject) {
        // update data in manager
        ThemeSwitchDataMananger.instance.updateSwitchData(data)
        
        for window in UIApplication.sharedApplication().windows {
            // update view
            window.ch_switchTheme()
            // update view controller的主题
            window.rootViewController?.ch_switchTheme()
        }
        // enforce update view controller
        for weakRef in viewControllers {
            if let viewController = weakRef.value {
                viewController.ch_switchTheme()
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


public class ThemeServiceConfig {
    var autoSwitchThemeAfterAwakeFromNib = true
    var autoSwitchThemeAfterMovedToSuperView = true
    var autoSwitchThemeWhenTableViewCellReused = true
    var autoSwitchThemeWhenCollectionViewCellReused = true
    
    static let instance = ThemeServiceConfig()
}

public extension UIView {
    private var ch_themeServiceConfig:ThemeServiceConfig {
        return ThemeServiceConfig.instance
    }
    func ch_awakeFromNib() {
        ch_awakeFromNib()
        if ch_themeServiceConfig.autoSwitchThemeAfterAwakeFromNib {
            ch_switchTheme()
        }
    }
    
    func ch_didMoveToSuperview() {
        ch_didMoveToSuperview()
        if ch_themeServiceConfig.autoSwitchThemeAfterMovedToSuperView {
            ch_switchTheme()
        }
    }
    
    override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            ch_exchangeInstanceMethod(Selector("awakeFromNib"), swizzledSelector: Selector("ch_awakeFromNib"))
            ch_exchangeInstanceMethod(Selector("didMoveToSuperview"), swizzledSelector: Selector("ch_didMoveToSuperview"))
        }
    }
}

public extension UITableViewCell {
    func ch_prepareForReuse() {
        ch_prepareForReuse()
        if ch_themeServiceConfig.autoSwitchThemeWhenTableViewCellReused {
            ch_switchTheme()
        }
    }
    
    override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            ch_exchangeInstanceMethod(Selector("prepareForReuse"), swizzledSelector: Selector("ch_prepareForReuse"))
        }
    }
}

public extension UICollectionReusableView {
    func ch_prepareForReuse() {
        ch_prepareForReuse()
        if ch_themeServiceConfig.autoSwitchThemeWhenCollectionViewCellReused {
            ch_switchTheme()
        }
    }
    
    override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            ch_exchangeInstanceMethod(Selector("prepareForReuse"), swizzledSelector: Selector("ch_prepareForReuse"))
        }
    }
}

public extension UIViewController {
    func ch_registerThemeService() {
        ThemeService.instance.registerViewController(self)
    }
}



