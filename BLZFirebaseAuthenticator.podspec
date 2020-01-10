#
# Be sure to run `pod lib lint BLZFirebaseAuthenticator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BLZFirebaseAuthenticator'
  s.version          = '0.1.0'
  s.summary          = 'Wrapper for Firebase Authentication ecosystem'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Wrapper for Firebase Authentication ecosystem that allow you to easily add Facebook, Google and Email authentication to your app'

  s.homepage         = 'https://github.com/LeonardoPasseri/BLZFirebaseAuthenticator'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Leonardo Passeri' => 'leonardo@balzo.eu' }
  s.source           = { :git => 'https://github.com/LeonardoPasseri/BLZFirebaseAuthenticator.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'

  s.source_files = 'BLZFirebaseAuthenticator/Classes/**/*'
  
  s.swift_version = "5.1"
  
  # s.resource_bundles = {
  #   'BLZFirebaseAuthenticator' => ['BLZFirebaseAuthenticator/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Firebase/Core', '~> 6.0'
  s.dependency 'Firebase/Auth', '~> 6.0'
  s.dependency 'GoogleSignIn', '~> 4.0'
  s.dependency 'RxSwift', '~> 4.0'
  s.dependency 'FBSDKCoreKit', '~> 5.0'
  s.dependency 'FBSDKLoginKit', '~> 5.0'
  
  s.static_framework = true
  
  
end
