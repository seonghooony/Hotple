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

  # pod 'RxKakaoSDK'
  pod 'RxKakaoSDKCommon'  # 필수 요소를 담은 공통 모듈
  pod 'RxKakaoSDKAuth'  # 카카오 로그인
  pod 'RxKakaoSDKUser'  # 사용자 관리
  pod 'RxKakaoSDKTalk'  # 친구, 메시지(카카오톡)
  pod 'RxKakaoSDKShare'  # 메시지(카카오톡 공유)

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

  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
  end

  installer.generated_projects.each do |project|
      project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
          end
      end
  end

  
end