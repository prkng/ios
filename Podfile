# Uncomment this line to define a global platform for your project
platform :ios, '10.0'

use_frameworks!

target 'prkng-ios' do

pod 'IQKeyboardManager'
pod 'Mapbox-iOS-SDK', '~> 3.7'
pod 'SDWebImage'
pod 'SVProgressHUD'
pod 'pop'
#pod 'MBXMapKit'
pod 'GeoJSONSerialization'
pod 'GZIP'
pod 'MarqueeLabel'
pod 'CocoaLumberjack'
pod 'GoogleMaps'
pod 'Google/Analytics'
pod 'Google/SignIn'
pod 'SevenSwitch'
pod 'TDOAuth'
pod 'CardIO'

# pod 'MapboxGL'
# pod 'AF+Date+Helper', :git => 'https://github.com/melvitax/AFDateHelper.git'
# pod 'SnapKit'
pod 'SwiftyJSON', '3.0.0'
pod 'Alamofire', '4.5.1'

end

#we do this to avoid "include of non-modular header inside framework module" errors with cocoalumberjack
post_install do |installer|
  installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
    configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  end
end
