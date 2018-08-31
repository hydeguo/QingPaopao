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

end


post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
