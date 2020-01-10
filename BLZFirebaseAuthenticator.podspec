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
  
  s.swift_version = "5.1"
  
  # s.resource_bundles = {
  #   'BLZFirebaseAuthenticator' => ['BLZFirebaseAuthenticator/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
  s.subspec "Core" do |ss|
    ss.source_files = 'BLZFirebaseAuthenticator/Classes/Core/*'
    ss.dependency 'Firebase/Core', '~> 6.0'
    ss.dependency 'Firebase/Auth', '~> 6.0'
    ss.dependency 'RxSwift', '~> 4.0'
    ss.framework  = 'UIKit'
  end
  
  s.subspec "Facebook" do |ss|
    ss.source_files = 'BLZFirebaseAuthenticator/Classes/Facebook/*'
    ss.dependency 'BLZFirebaseAuthenticator/Core'
    ss.dependency 'Firebase/Core', '~> 6.0'
    ss.dependency 'Firebase/Auth', '~> 6.0'
    ss.dependency 'RxSwift', '~> 4.0'
    ss.dependency 'FBSDKCoreKit', '~> 5.0'
    ss.dependency 'FBSDKLoginKit', '~> 5.0'
    ss.framework  = 'UIKit'
  end
  
  s.subspec "Google" do |ss|
    ss.source_files = 'BLZFirebaseAuthenticator/Classes/Google/*'
    ss.dependency 'BLZFirebaseAuthenticator/Core'
    ss.dependency 'Firebase/Core', '~> 6.0'
    ss.dependency 'Firebase/Auth', '~> 6.0'
    ss.dependency 'RxSwift', '~> 4.0'
    ss.dependency 'GoogleSignIn', '~> 4.0'
    ss.framework  = 'UIKit'
  end
  
  s.subspec "Email" do |ss|
    ss.source_files = 'BLZFirebaseAuthenticator/Classes/Email/*'
    ss.dependency 'BLZFirebaseAuthenticator/Core'
    ss.dependency 'Firebase/Core', '~> 6.0'
    ss.dependency 'Firebase/Auth', '~> 6.0'
    ss.dependency 'RxSwift', '~> 4.0'
    ss.framework  = 'UIKit'
  end
  
  s.static_framework = true
  
end
