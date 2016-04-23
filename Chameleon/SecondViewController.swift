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
    
    override func ch_shouldSwitchTheme(now: String?, pre: String?) -> Bool {
        if let a = now, b = pre where a != b{
            return false
        }
        return true
    }
    
    override func ch_switchTheme(now: String?, pre: String?) {
        if let now = now {
            if let color = ColorName(rawValue: now) {
                self.view.backgroundColor = UIColor.colorWithHexString(color.rawValue)
            }
        }
    }

}

