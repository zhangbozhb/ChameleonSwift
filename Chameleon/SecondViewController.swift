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
    
   override func switchTheme(now: Any, pre: Any?) {
        if let now = ChameleonHelper<ColorName>.parse(now) {
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
        view.ch.refresh(refresh: true)
    }
}

class ThirdViewController:UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.yellow
    }
    
   override func switchTheme(now: Any, pre: Any?) {
        print("ThirdViewController switchTheme \(String.init(reflecting: self))")
    }
}


class ForthViewController:ThirdViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.purple
    }
   override func switchTheme(now: Any, pre: Any?) {
        print("ForthViewController switchTheme \(String.init(reflecting: self))")
    }
}

class View1:UIView {
   override func switchTheme(now: Any, pre: Any?) {
        print("View1 switchTheme \(String.init(reflecting: self)) data:\(String(describing: ChameleonHelper<ColorName>.parse(now)))")
    }
}


class View2:View1 {
   override func switchTheme(now: Any, pre: Any?) {
        print("View2 switchTheme \(String.init(reflecting: self)) data:\(String(describing: ChameleonHelper<ColorName>.parse(now)))")
    }
}

