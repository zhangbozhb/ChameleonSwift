//
//  SecondViewController.swift
//  Chameleon
//
//  Created by travel on 16/3/19.
//  Copyright © 2016年 travel. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func ch_shouldSwitchTheme(now: AnyObject?, pre: AnyObject?) -> Bool {
        if let a = now as? String, b = pre as? String where a != b{
            return false
        }
        return true
    }
    
    override func ch_switchTheme(now: AnyObject?, pre: AnyObject?) {
        if let now = now, value = now as? String {
            if let color = ColorName(rawValue: value) {
                self.view.backgroundColor = UIColor.colorWithHexString(color.rawValue)
            }
        }
    }

}

