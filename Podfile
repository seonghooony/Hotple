# Uncomment the next line to define a global platform for your project
# platform :ios, '14.0'

target 'Hotple' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Hotple
  pod 'Alamofire'
  pod 'RxAlamofire'
  pod 'Kingfisher'
  pod 'RxKingfisher'
  pod 'ReactorKit'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxGesture'
  pod 'RxDataSources'
  pod 'RxFlow'
  pod 'SnapKit'
  pod 'RxKakaoSDK'
  pod 'naveridlogin-sdk-ios'
  pod 'NMapsMap','3.15.0'
  pod 'FirebaseAnalytics'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'lottie-ios'
  pod 'RxViewController'
  pod 'Then'
  pod 'SkeletonView'

end

post_install do |installer|

  installer.generated_projects.each do |project|
      project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
          end
      end
  end

  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
  end
end