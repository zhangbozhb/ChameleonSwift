
# ChameleonSwift


A lightweight and pure Swift implemented library for switch app theme/skin. Chameleon aim at provide easy way to enable to app switch theme

## Requirements

* iOS 8.0
* Xcode 7.0 or above

## Usage
### Simple usage
**1**, Enable view to switch theme ability:
```swift
let label = UILabel()
label.ch_switchThemeBlock = { (now:AnyObject?, pre:AnyObject?) -> Void in
    label.text = "change theme"
    // your code change theme/skin
    ...
}
```
Or your can override method of view: ch_switchTheme:pre
```swift
override func ch_switchTheme(now: AnyObject?, pre: AnyObject?) {
    // your code change theme/skin
     ...
}
override func ch_shouldSwitchTheme(now:AnyObject?, pre: AnyObject?) -> Bool {
    // if false return ch_switchTheme:pre will not called
    return true 
}
```
* now: data that you pass to switchTheme
* pre: previous data that you pass to switchTheme


**2** Switch Theme
* Switch whole application theme
    ```swift
        UIApplication.ch_switchTheme(yourdata)
    ```
* Switch specified view's theme
    ```swift
        viewInstance.ch_switchTheme(yourdata)
    ```
* Switch specified view controller's theme
    ```swift
        viewControllerInstance.ch_switchTheme(yourdata)
    ```

### Advance usage

* 1, Config switch theme
    To save your time, ThemeServiceConfig may be your favor.
    Several properties are pre defined for you. When specified property is true, ch_ch_switchTheme(_:) user it's parent data

    ```swift
        // 配置主题修改
        let tsc = ThemeServiceConfig.instance
        tsc.viewAutoSwitchThemeAfterAwakeFromNib = true
        tsc.viewAutoSwitchThemeAfterMovedToSuperView = true
        tsc.viewAutoSwitchThemeWhenTableViewCellReused = true
        tsc.viewAutoSwitchThemeWhenCollectionViewCellReused = true
        tsc.viewControllerAutoSwitchThemeAfterAwakeFromNib = false
        tsc.viewControllerAutoSwitchThemeWhenViewWillAppear = true
    ```
    **Note**: Be wared you should promise you method ch_switchTheme(_:pre:) and ch_switchThemeBlock run without exceptions. If unfortunately it happend, you app will crash.

* 2, What happened when both ch_switchTheme(_:pre:) and ch_switchThemeBlock are defined?

    Both of them will be called, and ch_switchThemeBlock run after ch_switchTheme(_:pre:)

* 3, What happened when you change cheme in view and viewController?
    Yes, Both of them will be called, and viewController's switch theme method run after view done.

* 4, You may find your switch theme method not call when you view controller is beyong applicaiton rootViewController tree. In this case, you normal is call ch_registerViewController()
    ```
    viewControllerInstance.ch_registerViewController()
    ```
    In most cases, your do not need call this method, how ever your are free to call this method at any time


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

``` bash
$ gem install cocoapods
```

To integrate ChameleonSwift into your Xcode project using CocoaPods, specify it in your `Podfile`:

``` ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'ChameleonSwift'
```

Then, run the following command:

``` bash
$ pod install
```

You should open the `{Project}.xcworkspace` instead of the `{Project}.xcodeproj` after you installed anything from CocoaPods.

For more information about how to use CocoaPods, I suggest [this tutorial](http://www.raywenderlich.com/64546/introduction-to-cocoapods-2).
