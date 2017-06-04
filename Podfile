# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'Slide' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Slide
pod 'IQKeyboardManagerSwift'
pod 'Firebase/Core'
pod 'Firebase/Database'
pod 'Firebase/Auth'
pod 'Firebase/Storage'
pod 'Firebase/Messaging'
pod 'FacebookCore'
pod 'FacebookLogin'
pod 'FacebookShare'
pod 'SwiftyJSON'
pod 'ObjectMapper'
pod 'Kingfisher', '~> 3.0'
pod 'GoogleMaps'
pod 'GooglePlaces'
pod 'FloatRatingView', '~> 2.0.0'
pod 'TTTAttributedLabel'
#pod 'NoChat'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

end
