//
//  FirstViewController.swift
//  Chameleon
//
//  Created by travel on 16/3/19.
//  Copyright © 2016年 travel. All rights reserved.
//

import UIKit


class FirstViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    var datas:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        datas = ["redColor", "greenColor", "yellowColor", "purpleColor"]
        

        label1.ch_switchThemeBlock = { (now:AnyObject?, pre:AnyObject?) -> Void in
            self.label1.text = "label1\(now)"
        }
        
        label2.ch_switchThemeBlock = { (now:AnyObject?, pre:AnyObject?) -> Void in
            self.label2.text = "label2\(now)"
        }
        
        label3.ch_switchThemeBlock = { (now:AnyObject?, pre:AnyObject?) -> Void in
            self.label3.text = "label3\(now)"
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
        return datas[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ThemeService.instance.switchTheme(row)
    }
    
    override func ch_switchTheme(now: AnyObject?, pre: AnyObject?) {
        if let style = now as? NSNumber {
            switch(style.integerValue) {
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

