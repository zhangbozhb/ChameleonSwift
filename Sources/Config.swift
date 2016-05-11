//
//  Config.swift
//  ChameleonSwift
//
//  Created by travel on 16/5/11.
//  Copyright © 2016年 travel. All rights reserved.
//

import Foundation
import UIKit

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
    
    
    func initThemeData(obj:AnyObject?) {
        ThemeSwitchDataCenter.initThemeData(obj)
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
