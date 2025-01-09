#
#  Be sure to run `pod spec lint DriveMetaDataiOSSDK.podspec.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

 
  spec.name         = "DriveMetaDataiOSSDK"
  spec.version      = "0.0.7"
  spec.summary      = "DriveMetaDataiOSSDK is a analytics tools"
  spec.license      = "MIT"
  spec.author             = { "Ranjeet Ranjan" => "ranjeet@drivemetadata.com" }
  spec.homepage     = "https://www.drivemetadata.com"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.platform     = :ios,"12"
  spec.swift_version = '4.0'
  spec.source       = { :git =>"https://github.com/drivemetadata/DriveMetaDataiOSSDK.git", :tag => "0.0.7" }
  spec.source_files  = 'DMD/**/*.{swift,h,m}'
  spec.exclude_files = 'DMD/**/*.plist'
  spec.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'No' }
  spec.requires_arc  = true

end
