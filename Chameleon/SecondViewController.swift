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
        if let a = now as? NSNumber, b = pre as? NSNumber {
            return a.integerValue == b.integerValue + 1
        }
        return true
    }
    
    override func ch_switchTheme(now: AnyObject?, pre: AnyObject?) {
        if let style = now as? NSNumber {
            switch(style.integerValue - 1) {
            case 0:
                view.backgroundColor = UIColor.redColor()
            case 1:
                view.backgroundColor = UIColor.greenColor()
            case 2:
                view.backgroundColor = UIColor.blueColor()
            case 3:
                view.backgroundColor = UIColor.yellowColor()
            default:
                view.backgroundColor = UIColor.purpleColor()
            }
        } else {
            view.backgroundColor = UIColor.grayColor()
        }
    }

}

