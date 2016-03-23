#
#  Be sure to run `pod spec lint ChameleonSwift.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#  pod trunk push ChameleonSwift.podspec

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "ChameleonSwift"
  s.version      = "0.0.3"
  s.summary      = "A lightweight and pure Swift implemented library for change app theme/skin"

  s.description  = <<-DESC
                   A lightweight and pure Swift implemented library for switch app theme/skin
                   * Chameleon aim at provide easy way to enable to app switch theme
                   DESC

  s.homepage     = "https://github.com/zhangbozhb/Chameleon"
  # s.screenshots  = https://github.com/zhangbozhb/Chameleon.gif"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "travel" => "zhangbozhb@gmail.com" }
  s.social_media_url   = "http://twitter.com/travel_zh"

  s.ios.deployment_target = "8.0"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/zhangbozhb/Chameleon.git", :tag => s.version }

  s.source_files  = "Sources/*.swift", "Sources/*.{h,m}"
  s.exclude_files = "Sources/Exclude"


end
