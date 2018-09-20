# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'

target 'Mywopin' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

    pod 'R.swift'
#    pod 'Toast-Swift'
    pod 'RxCocoa',    '~> 4.0'
    pod 'Moya/RxSwift'
    pod 'IHKeyboardAvoiding', '~> 4.0'
#    pod 'Hero'
    pod 'ChromaColorPicker'
    pod 'DLLocalNotifications'
    pod 'PKHUD'
    pod 'CocoaMQTT'
    pod 'QRCodeReader.swift', '~> 8.2.0'
    pod 'Kingfisher'
#    pod 'mob_paysdk'
    pod 'mob_paysdk/Channels/WeChat'
#    pod 'mob_paysdk/Channels/AliPay'
#    pod 'mob_paysdk/Channels/UnionPay'
    pod 'Disk', '~> 0.3.3'
    pod 'WordPress-Aztec-iOS', '1.0.0'
    pod 'WordPress-Editor-iOS', '1.0.0'
    pod 'Gridicons'
    pod 'Alamofire'
    
    pod 'Firebase/Core'
    pod 'Fabric', '~> 1.7.11'
    pod 'Crashlytics'
end


post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
