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
    
    override func ch_switchTheme(_ now: Any, pre: Any?) {
        if let now = ThemeSwitchHelper<ColorName>.parseTheme(now) {
            view.backgroundColor = UIColor.colorWithHexString(now.rawValue)
        }
    }
    
    @IBAction func showV1(_ sender: AnyObject) {
        for t in testViewContainer.subviews {
            t.removeFromSuperview()
        }
        let v1 = View1.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        v1.backgroundColor = UIColor.green
        testViewContainer.addSubview(v1)
    }
    @IBAction func showV2(_ sender: AnyObject) {
        for t in testViewContainer.subviews {
            t.removeFromSuperview()
        }
        let v2 = View2.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        v2.backgroundColor = UIColor.red
        testViewContainer.addSubview(v2)
    }

    @IBAction func showThird(_ sender: AnyObject) {
        navigationController?.pushViewController(ThirdViewController(), animated: false)
    }
    @IBAction func showForth(_ sender: AnyObject) {
        navigationController?.pushViewController(ForthViewController(), animated: false)
    }
    
    @IBAction func refreshCurrentView(_ sender: AnyObject) {
        view.ch_switchTheme(refresh: true)
    }
}

class ThirdViewController:UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.yellow
    }
    
    override func ch_switchTheme(_ now: Any, pre: Any?) {
        super.ch_switchTheme(now, pre: pre)
        print("ThirdViewController ch_switchTheme \(NSStringFromClass(type(of: self)))")
    }
}


class ForthViewController:ThirdViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.purple
    }
    override func ch_switchTheme(_ now: Any, pre: Any?) {
        super.ch_switchTheme(now, pre: pre)
        print("ForthViewController ch_switchTheme \(NSStringFromClass(type(of: self)))")
    }
}

class View1:UIView {
    override func ch_switchTheme(_ now: Any, pre: Any?) {
        super.ch_switchTheme(now, pre: pre)
        print("View1 ch_switchTheme \(NSStringFromClass(type(of: self))) data:\(ThemeSwitchHelper<ColorName>.parseTheme(now))")
    }
}


class View2:View1 {
    override func ch_switchTheme(_ now: Any, pre: Any?) {
        super.ch_switchTheme(now, pre: pre)
        print("View2 ch_switchTheme \(NSStringFromClass(type(of: self))) data:\(ThemeSwitchHelper<ColorName>.parseTheme(now))")
    }
}

