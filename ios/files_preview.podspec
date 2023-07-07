#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint files_preview.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'files_preview'
  s.version          = '0.0.4'
  s.summary          = 'A Flutter plugin view file.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://khohatsi.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Hưng Nguyễn' => 'hungnguyen.it36@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
