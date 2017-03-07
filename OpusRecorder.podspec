#
# Be sure to run `pod lib lint OpusRecorder.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OpusRecorder'
  s.version          = '0.1.0'
  s.summary          = 'A voice recorder that encodes audio using opus codec.'
  s.homepage         = 'https://github.com/obaskanderi/OpusRecorder'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'obaskanderi' => 'omairb@gmail.com' }
  s.source           = { :git => 'https://github.com/obaskanderi/OpusRecorder.git', :tag => s.version.to_s }
  s.platform         = :ios, "9.0"  
  s.source_files     = 'OpusRecorder/Classes/**/*'
  s.dependency 'opus-ios', '~> 1.1.3'
  s.dependency 'ogg-ios', '~> 1.3.2'
end
