//
//  Datas.swift
//  Chameleon
//
//  Created by travel on 16/3/22.
//  Copyright © 2016年 travel. All rights reserved.
//

import Foundation
import UIKit

enum ColorName:String {
    case Ambe = "#FFBF0"
    case SA = "#FF7E0"
    case AmericanRos = "#FF033"
    case Amethys = "#9966C"
    case AndroidGree = "#A4C63"
    case AntiFlashWhit = "#F2F3F"
    case AntiqueBras = "#CD957"
    case AntiqueBronz = "#665D1"
    case AntiqueFuchsi = "#915C8"
    case AntiqueRub = "#841B2"
    case AntiqueWhit = "#FAEBD"
    case Ao = "#00800"
    case AppleGree = "#8DB60"
    case Aprico = "#FBCEB"
    case Aqu = "#00FFF"
    case Aquamarin = "#7FFFD"
}

public extension UIColor {
    
    public class func colorWithRGB(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        let base: CGFloat = 255.0
        return UIColor(red: red/base, green: green/base, blue: blue/base, alpha: alpha)
    }
    
    public class func colorWithHex(_ hex: Int, alpha: Float = 1.0) -> UIColor {
        let blue = hex & 0xFF
        let green = (hex >> 8) & 0xFF
        let red = (hex >> 16) & 0xFF
        return self.colorWithRGB(CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
    public class func colorWithHexString(_ hexString: String, alpha: Float = 1.0) -> UIColor {
        var hexStr = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if (hexStr.hasPrefix("#")) {
            hexStr = hexStr.substring(from: hexStr.index(after: hexStr.startIndex))
        }
        var hex:CUnsignedInt = 0
        Scanner.init(string: hexStr).scanHexInt32(&hex)
        
        let blue = hex & 0xFF
        let green = (hex >> 8) & 0xFF
        let red = (hex >> 16) & 0xFF
        return self.colorWithRGB(CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
}
