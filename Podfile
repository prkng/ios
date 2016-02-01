# Uncomment this line to define a global platform for your project
platform :ios, '7.0'

target 'prkng-ios' do

pod 'IQKeyboardManager', '3.2.4'
pod 'Mapbox-iOS-SDK', '1.6.0'
pod 'SDWebImage', '3.7.2'
pod 'SVProgressHUD', :head #should eventually be '1.1.4' when it's released
pod 'pop', '~> 1.0'
#pod 'MBXMapKit'
pod 'GeoJSONSerialization'
pod 'GZIP'
pod 'MarqueeLabel'
pod 'CocoaLumberjack'
pod 'GoogleMaps'
pod 'Google/Analytics'
pod 'Google/SignIn'
pod 'SevenSwitch', '~>1.4'
pod 'TDOAuth'
pod 'CardIO'
#pod 'SZTextView' #no longer used, gives a uitextview with placeholder text

#the pods below should only be enabled if we move to ios 8
#use_frameworks!
#pod 'MapboxGL'
#pod 'AF+Date+Helper', :git => 'https://github.com/melvitax/AFDateHelper.git'
#pod 'SnapKit'
#pod 'SwiftyJSON'
#pod 'Alamofire'

end

link_with 'prkng-ios'

#we do this to avoid "include of non-modular header inside framework module" errors with cocoalumberjack
post_install do |installer|
  installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
    configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  end
end