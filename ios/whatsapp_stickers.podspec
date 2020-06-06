#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint whatsapp_stickers.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'whatsapp_stickers'
  s.version          = '1.0.0'
  s.summary          = 'WhatsApp Stickers plugin for Flutter.'
  s.description      = <<-DESC
WhatsApp Stickers plugin for Flutter.
                       DESC
  s.homepage         = 'http://applicazza.dev'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'applicazza' => 'artyom@applicazza.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'libwebp'
  s.dependency 'YYImage'
  s.dependency 'YYImage/WebP'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
