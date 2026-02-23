platform :ios, '16.0'
use_frameworks!

target 'Tajma' do
  pod 'SQLite.swift'
end

target 'TajmaWidget' do
  pod 'SQLite.swift'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end
