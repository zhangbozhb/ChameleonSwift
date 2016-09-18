#
#  pod spec lint ChameleonSwift.podspec--allow-warnings --verbose
#  pod trunk push ChameleonSwift.podspec --allow-warnings --verbose

Pod::Spec.new do |s|

  s.name         = "ChameleonSwift"
  s.version      = "2.0"
  s.summary      = "A lightweight and pure Swift implemented library for change app theme/skin"

  s.description  = <<-DESC
                   A lightweight and pure Swift implemented library for switch app theme/skin
                   * Chameleon aim at provide easy way to enable to app switch theme
                   DESC

  s.homepage     = "https://github.com/zhangbozhb/ChameleonSwift"
  # s.screenshots  = https://github.com/zhangbozhb/ChameleonSwift.gif"

  s.license      = { :type => "MIT" }

  s.author             = { "travel" => "zhangbozhb@gmail.com" }
  s.social_media_url   = "http://twitter.com/travel_zh"

  s.ios.deployment_target = "8.0"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/zhangbozhb/ChameleonSwift.git", :tag => s.version }

  s.source_files  = ["Sources/*.swift", "Sources/*.{h,m}"]
  s.exclude_files = "Sources/Exclude"

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
end
