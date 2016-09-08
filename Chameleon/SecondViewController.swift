//
//  SecondViewController.swift
//  Chameleon
//
//  Created by travel on 16/3/19.
//  Copyright © 2016年 travel. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    @IBOutlet weak var testViewContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func ch_switchTheme(now: AnyObject, pre: AnyObject?) {
        if let now = ThemeSwitchHelper<ColorName>.parseTheme(now) {
            view.backgroundColor = UIColor.colorWithHexString(now.rawValue)
        }
    }
    
    @IBAction func showV1(sender: AnyObject) {
        for t in testViewContainer.subviews {
            t.removeFromSuperview()
        }
        let v1 = View1.init(frame: CGRectMake(0, 0, 50, 50))
        v1.backgroundColor = UIColor.greenColor()
        testViewContainer.addSubview(v1)
    }
    @IBAction func showV2(sender: AnyObject) {
        for t in testViewContainer.subviews {
            t.removeFromSuperview()
        }
        let v2 = View2.init(frame: CGRectMake(0, 0, 50, 50))
        v2.backgroundColor = UIColor.redColor()
        testViewContainer.addSubview(v2)
    }

    @IBAction func showThird(sender: AnyObject) {
        navigationController?.pushViewController(ThirdViewController(), animated: false)
    }
    @IBAction func showForth(sender: AnyObject) {
        navigationController?.pushViewController(ForthViewController(), animated: false)
    }
    
    @IBAction func refreshCurrentView(sender: AnyObject) {
        view.ch_switchTheme(refresh: true)
    }
}

class ThirdViewController:UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.yellowColor()
    }
    
    override func ch_switchTheme(now: AnyObject, pre: AnyObject?) {
        super.ch_switchTheme(now, pre: pre)
        print("ThirdViewController ch_switchTheme \(NSStringFromClass(self.dynamicType))")
    }
}


class ForthViewController:ThirdViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.purpleColor()
    }
    override func ch_switchTheme(now: AnyObject, pre: AnyObject?) {
        super.ch_switchTheme(now, pre: pre)
        print("ForthViewController ch_switchTheme \(NSStringFromClass(self.dynamicType))")
    }
}

class View1:UIView {
    override func ch_switchTheme(now: AnyObject, pre: AnyObject?) {
        super.ch_switchTheme(now, pre: pre)
        print("View1 ch_switchTheme \(NSStringFromClass(self.dynamicType)) data:\(ThemeSwitchHelper<ColorName>.parseTheme(now))")
    }
}


class View2:View1 {
    override func ch_switchTheme(now: AnyObject, pre: AnyObject?) {
        super.ch_switchTheme(now, pre: pre)
        print("View2 ch_switchTheme \(NSStringFromClass(self.dynamicType)) data:\(ThemeSwitchHelper<ColorName>.parseTheme(now))")
    }
}

