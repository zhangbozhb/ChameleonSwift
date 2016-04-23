//
//  FirstViewController.swift
//  Chameleon
//
//  Created by travel on 16/3/19.
//  Copyright © 2016年 travel. All rights reserved.
//

import UIKit


class CustomerView1:UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func ch_switchTheme(now: String?, pre: String?) {
        if let now = now {
            if let color = ColorName(rawValue: now) {
                self.backgroundColor = UIColor.colorWithHexString(color.rawValue)
            }
        }
    }
}

class CustomerView2:UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    override func ch_shouldSwitchTheme(now: String?, pre: String?) -> Bool {
        if let a = now, b = pre where a != b {
            return false
        }
        return true
    }
    
    override func ch_switchTheme(now: String?, pre: String?) {
        if let now = now {
            if let color = ColorName(rawValue: now) {
                self.backgroundColor = UIColor.colorWithHexString(color.rawValue)
            }
        }
    }
}

class FirstViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var leftPick: UIPickerView!
    @IBOutlet weak var rightPick: UIPickerView!
    
    @IBOutlet weak var systemLabel: UILabel!
    @IBOutlet weak var customerView2: CustomerView2!
    @IBOutlet weak var customerView1: CustomerView1!

    var datas:[ColorName] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datas = [.Ambe, .SA, .AmericanRos, .Amethys, .AndroidGree, .AntiFlashWhit,
                 .AntiqueBras, .AntiqueBronz, .AntiqueFuchsi, .AntiqueRub, .AntiqueWhit,
                 .Ao, .AppleGree, .Aprico, .Aqu, .Aquamarin]
        
        
        systemLabel.ch_switchThemeBlock = { (now:String?, pre:String?) -> Void in
            let df = NSDateFormatter.init()
            df.dateFormat = "mm:ss"
            self.systemLabel.text = df.stringFromDate(NSDate.init())
            
            if let now = now {
                if let color = ColorName(rawValue: now) {
                    self.systemLabel.textColor = UIColor.colorWithHexString(color.rawValue)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datas.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return datas[row].rawValue
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.leftPick {
            customerView1.text = datas[row].rawValue
        } else {
            customerView2.text = datas[row].rawValue
        }
        
        UIApplication.ch_switchTheme(datas[row].rawValue)
    }
}

