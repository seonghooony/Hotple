# Uncomment the next line to define a global platform for your project
# platform :ios, '14.0'

target 'Hotple' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Hotple
  pod 'Alamofire'
  pod 'RxAlamofire'
  pod 'ReactorKit'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxFlow'
  pod 'SnapKit'
  pod 'RxKakaoSDK', '~> 2.13.1'
  pod 'naveridlogin-sdk-ios'
  pod 'FirebaseAnalytics'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
  end
end