#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint security_plus.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'security_plus'
  s.version          = '1.0.0'
  s.summary          = 'A new Flutter plugin to detect root and jail break.'
  s.homepage         = 'https://github.com/abdelrahmanbonna'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'AB Solutions' => 'abdelrahmanbonna@outlook.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
