
# ChameleonSwift


[![Language: Swift 2](https://img.shields.io/badge/language-swift2-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platform: iOS 8+](https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Cocoapods compatible](https://img.shields.io/badge/Cocoapods-compatible-4BC51D.svg?style=flat)](https://cocoapods.org)
[![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/jiecao-fm/SwiftTheme/blob/master/LICENSE)


A lightweight and pure Swift implemented library for switch app theme/skin. Chameleon aim at provide easy way to enable to app switch theme

If your have any quesion, you can email me(zhangbozhb@gmail.com) or leave message.

## Requirements

* iOS 8.0+
* Xcode 7.0 or above

## Usage
### Simple usage

##### Assume
You can define you theme with any data. Let's assume you theme data is ThemeStyle (Day, Night). ThemeStyle is enum type, however you can define your theme with any type.


**1**, Enable view to switch theme ability:
```swift
let label = UILabel()
label.ch_switchThemeBlock = { (now:AnyObject?, pre:AnyObject?) -> Void in
    // your code change theme/skin
    if let now = ThemeSwitchHelper<ThemeStyle>.parseTheme(now) { // get your ThemeStyle from now
        label.text = "\(now)"
        ...
    }
}
```
Or your can override method of view: ch_switchTheme:pre
```swift
override func ch_switchTheme(now: AnyObject?, pre: AnyObject?) {
    // your code change theme/skin
    if let now = ThemeSwitchHelper<ThemeStyle>.parseTheme(now) {
        ...
    }
}
```
* now: data that you pass to switchTheme. your can use ThemeSwitchHelper<ThemeStyle>.parseTheme(now) get your real theme data
* pre: previous data that you pass to switchTheme


**2** Set your Theme
* Switch whole application theme
``` swift
    ThemeServiceConfig.instance.initThemeData(data: ThemeStyle.Day)
```
* Note: if you not initThemeData, arg now in ch_switchTheme:pre or ch_switchThemeBlock may nil

**3** Switch Theme
* Switch whole application theme
``` swift
    UIApplication.ch_switchTheme(ThemeStyle.Night)
```
* Switch specified view's theme (sub view as well)
``` swift
    viewInstance.ch_switchTheme(ThemeStyle.Night)
 ```
* Switch specified view controller's theme (child view controlls as well)
``` swift
    viewControllerInstance.ch_switchTheme(ThemeStyle.Night)
 ```

### Useful Helper Function
Some useful function define in ThemeSwitchHelper.
* get current theme: ThemeSwitchHelper<Your Defined Theme Class>.currentTheme
* get current theme from args: ThemeSwitchHelper<Your Defined Theme Class>.parseTheme()
* get current theme image: ThemeSwitchHelper<Your Defined Theme Class>.image()
* get current theme color: ThemeSwitchHelper<Your Defined Theme Class>.color()
* get current theme data, if your find image/color cannot satisfy your needs: ThemeSwitchHelper<Your Defined Theme Class>.currentThemeData()


### Advance usage

* 1, Config switch theme
    To save your time, ThemeServiceConfig may be your favor.
    Several properties are pre defined for you. When specified property is true, ch_ch_switchTheme(_:) user it's parent data

    ```swift
        // config your theme switch
        let tsc = ThemeServiceConfig.instance
        tsc.viewAutoSwitchThemeAfterAwakeFromNib = true
        tsc.viewAutoSwitchThemeAfterMovedToWindow = true
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


### Carthage
```bash
github "zhangbozhb/ChameleonSwift"
```



# ChameleonSwift 介绍
ChameleonSwift 提供了一种机制，你可以很方便的使得你的 App 具有多种皮肤和主题.。ChameleonSwift 是一个纯 Swift 实现的扩展。
由于主题/皮肤切换的复杂性，考虑到易于使用和可扩展行，本库并没有采用其他大多数库采用的方式（为不同的 view 添加不同的属性以达到主题切换），而是采用的是扩展 UIView, UIViewController的方式，你可以高度的定制你想要的皮肤。

和其他主题或者皮肤库优点：
* 简单。其他库在使用的时候，不同的View添加不同的属性，类型太多使用起来不容易
* 易于扩展。本库并没有单独的属性用于处理不同主题/皮肤下的表现，而是采用闭包的方式来实现，具有更大的灵活行和自主性
* 高度解耦：本扩展一个简单的配置，你可以专注与业务逻辑，而不需要考虑皮肤/主题支持使得你的代码变得丑陋不堪



## 简单使用：
### 第一步： view / view controller 支持多套皮肤/主题

##### 假设
假设你使用默认的 ThemeStyle（枚举类型,由Day, Night), 下面代码中使用 ThemeStyle 作为你使用的主题类型; 当然在实际使用中, 可以完成你自己定义的主题类型,可以是枚举,数字,类,可以是任意类型

有两种方式：你可以通过闭包，也可以通过 override 父类的方法来实现
闭包实现

```swift
let label = UILabel()
label.ch_switchThemeBlock = { (now:AnyObject?, pre:AnyObject?) -> Void in
    // 你修改主题的代码
    if let now = ThemeSwitchHelper<你定义的主题类型>.parseTheme(now) { // 获取 真正的主题
        label.text = "\(now)"
        ...
    }
}
```
* 注意: now 这个数据可能会空,如果你没有操作步骤二的数据当然你可以完全忽略步骤而, 通过 ThemeSwitchHelper<你定义的主题类型>.currentTheme 获取当前的主题
override方法实现：
```swift
override func ch_switchTheme(now: AnyObject?, pre: AnyObject?) {
    // 你修改主题的代码
     ...
}
```
参数说明：
* now: 你切换主题是传递进来的参数，比如是白天，还是黑夜等待。你可以用 ThemeSwitchHelper<你定义的主题类型>.parseTheme(now),获取当前的主题
* pre: 上次你主题切换使用的参数
好了，通过上面的步骤你已经使得你的view可以支持多种主题了


### 第二步: 设置的主题数据
* 设置整个app
``` swift
    ThemeServiceConfig.instance.initThemeData(data: ThemeStyle.Day)
```
* 设置单个view和subview
``` swift
    viewInstance.ch_switchTheme(ThemeStyle.Night)
 ```
* 设置单个 view controller 和其子 view controller
``` swift
    viewControllerInstance.ch_switchTheme(ThemeStyle.Night)
 ```

### 第三步：切换主题，皮肤
你只需要调用一个方法就可以实现
```swift
    UIApplication.ch_switchTheme(ThemeStyle.Night)
```


当然，你可以选择行的修改你想要改变view / view controller 的主题
view 切换调用:
```swift
    viewInstance.ch_switchTheme(ThemeStyle.Night)
```
view controller 调用:
```swift
    viewControllerInstance.ch_switchTheme(ThemeStyle.Night)
```


## 有用的帮助函数
ThemeSwitchHelper定义了一些有用的函数
* 获取当前的主题: ThemeSwitchHelper<你定义的主题类型>.currentTheme
* 解析参数获取当前主题: ThemeSwitchHelper<你定义的主题类型>.parseTheme()
* 当前主题的图片: ThemeSwitchHelper<你定义的主题类型>.image()
* 当前主题的颜色: ThemeSwitchHelper<你定义的主题类型>.color()
* 当前主题的配置（如果图片,颜色不满足你的需求,你可以使用这个）: ThemeSwitchHelper<你定义的主题类型>.currentThemeData()


## 高级使用：
### 自动调用
在简单使用中，介绍了如何让你的 App 支持主题切换和如何进行切换。但是，你会发现还是很不方面，你需要不怨其烦的手动调用，主题修改的方法。为你将你从这种无止境的烦恼中解放出来。为你提供了主题切换自动调用配置 ThemeServiceConfig。提供的配置，可以满足你的绝大数需求。
* viewAutoSwitchThemeAfterAwakeFromNib： 在 view 从 nib 文件awake的时候，自动调用
* viewAutoSwitchThemeAfterMovedToWindow：在 view 被添加到windows上的时候，自动调用（为什么是这个方法而不是启发window呢？这个请看 apple 的官方文档， 对于 didMoveToWindow 的说明）
* viewControllerAutoSwitchThemeAfterAwakeFromNib：在 view controller 从 nib 文件awake的时候，自动调用
* viewControllerAutoSwitchThemeWhenViewWillAppear：在 view controller 即将显示之前的时候，自动调用

是不是，很方便，简单?

#### 注意
不过任何好用，其实都是由代价的，自动调用使得主题切换调用更隐晦，响应的也不容易调试。为了你更好的使用自动调用，几点注意事项
* 确保不抛出异常： ch_switchThemeBlock 或者 ch_switchTheme(_:pre:)， 不要抛出异常，否则会 crash
* 非主题相关的状态保存在 view 或者 view controller中： 比如 一个 view 具有选中属性，在选中不选中的时候由不同的外观，你需要在某个地方存放这个状态，否则外观会被主题切换破坏调用。比如你 主题切换会把背景色设置为白色或黑色，你的 App 在某个地方人为的设置为红色，而你有恰好的配置了自动调用，那么你可能会惊讶的发现 view 颜色不是你想要的红色，你需要考虑到这一点。比较方便的方式是，你用某种方式记录你设置的红色状态，在 主题切换的时候，发现为红色是不修改背景色。


### 常见问题：
* 1，闭包 ch_switchThemeBlock 和 ch_switchTheme(_:pre:) 方法同时存在，会出现什么问题？
闭包和函数都会被调用，只不过闭包会在函数调用的后面调用

* 2，view controller 主题切换闭包,函数没有调用.
如果一个修改主题的方法写在一个view controller中，而在使用的时候 只是将 controller的view添加到某个view上，而view controller本身没有加到任何 view controller下的时候， 可能出现 该 view contoller的方法，并没有自动调用或者在主题切换的时候也没有自动调用？怎么处理
其实出现这种情况是正常的，这个涉及到本库切换的设计原理（后面提到）。你需要人为的调用主题切换方法，并 viewControllerInstance.ch_registerViewController()进行注册。就可以实现
viewControllerInstance.ch_registerViewController() 这个方法在绝大多数的时候，你可以任何地方使用，不过建议在本情况出现的时候调用（可能导致调用顺序异常）
* 3，主题切换函数或闭包调用顺序问题：
    * 父子view（view controller）调用顺序：先调用子view（view controller）的，在调用父的(parent)
    * 对于单个 view（view controller）：先调用主题切换函数，然后再试主题切换闭包
    * view 和 view controller 调用顺序： App 主题切换的时候，先调用 view 的，然后才是 view controller的
    * view controller 主题切换不会调用其 view 的主题切换函数和闭包


### 原理
采用的是扩展 view，view controller的方式来实现的。 主题切换的时候，是通过遍历 app 的view 和 view controller 树来实现切换的。


### 广告
本库已经在某新闻 App 中使用，经得住考验~
