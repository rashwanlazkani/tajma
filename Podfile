# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
# Uncomment this line if you're using Swift
use_frameworks!

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3'
    end
  end
end

target 'Tajma' do
pod 'SQLite.swift'
  pod 'Alamofire', '~> 4.0'
end

target 'TajmaToday' do
pod 'SQLite.swift'
  pod 'Alamofire', '~> 4.0'
end