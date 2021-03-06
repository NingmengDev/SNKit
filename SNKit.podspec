#
# Be sure to run `pod lib lint SNKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SNKit'
  s.version          = '1.0.2'
  s.summary          = 'Provides some useful classes, structs and extensions.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  SNKit is a collection of useful classes, structs and extensions.
                       DESC

  s.homepage         = 'https://github.com/NingmengDev/SNKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ningmeng' => 'ningmengdev@163.com' }
  s.source           = { :git => 'https://github.com/NingmengDev/SNKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.requires_arc = true
  s.frameworks = 'Foundation', 'UIKit'
  
  # s.source_files = 'SNKit/Classes/**/*'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  # s.resource_bundles = {
  #   'SNKit' => ['SNKit/Assets/*.png']
  # }

  # Base
  s.subspec 'Base' do |sp|
      sp.source_files = 'SNKit/Classes/Base/**/*'
  end
  
  # Extension
  s.subspec 'Extension' do |sp|
      sp.source_files = 'SNKit/Classes/Extension/**/*'
  end
  
  # Networking
  s.subspec 'Networking' do |sp|
      sp.source_files = 'SNKit/Classes/Networking/**/*'
      sp.dependency 'Moya'
  end
  
  # View
  s.subspec 'View' do |sp|
      sp.source_files = 'SNKit/Classes/View/**/*'
      sp.resource_bundles = {
          'SNProgressHUD' => ['SNKit/Assets/SNProgressHUD.xcassets']
      }
      sp.dependency 'DZNEmptyDataSet'
      sp.dependency 'MBProgressHUD'
      sp.dependency 'MJRefresh'
  end
  
  # Controller
  s.subspec 'Controller' do |sp|
      sp.source_files = 'SNKit/Classes/Controller/**/*'
  end
  
  # Utils
  s.subspec 'Utils' do |sp|
      sp.source_files = 'SNKit/Classes/Utils/**/*'
  end
  
end
