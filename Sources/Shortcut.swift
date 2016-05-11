//
//  Shortcut.swift
//  ChameleonSwift
//
//  Created by travel on 16/5/11.
//  Copyright © 2016年 travel. All rights reserved.
//

import Foundation
import UIKit


public extension ThemeServiceConfig {
    /**
     init theme data
     be awared: this method should call once
     
     - parameter data: theme
     
     - returns: void
     */
    func initThemeData<T>(data data:T) {
        ThemeSwitchDataCenter.initThemeData(data)
    }
}

/// theme helper
public class ThemeSwitchHelper<T where T: Hashable> {
    
    /**
     get current theme
     
     - returns: current theme
     */
    final class func currentTheme() -> T? {
        return ThemeSwitchDataCenter.themeData()
    }
    
    /**
     get current theme data
     
     - parameter data: theme data config for themes
     - parameter d:    default value if theme value for current thme is not in input data
     
     - returns: current theme value
     */
    final class func currentThemeData<D> (data:[T: D], d:D? = nil) -> D? {
        if let s = self.currentTheme() {
            return data[s]
        }
        return d
    }
    
    /**
     use parse theme from data
     this func used in ch_shouldSwitchTheme(_:pre:), ch_switchTheme(_:pre:), notificaiton (useinfo["data"])
     
     - parameter data: data to parse
     
     - returns: theme
     */
    final class func parseTheme(data:AnyObject?) -> T? {
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
    public class func image(images:[T: UIImage]) -> UIImage? {
        return self.currentThemeData(images)
    }
    
    /**
     get current theme color
     
     - parameter colors: theme color config
     
     - returns: color
     */
    public class func color(colors:[T: UIColor]) -> UIColor? {
        return self.currentThemeData(colors)
    }
}
