#
# Be sure to run `pod lib lint PXBifrost.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PXBifrost'
  s.version          = '0.1.0'
  s.summary          = 'iOS 组件化基础 SDK'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  iOS 组件化基础 SDK
                       DESC

  s.homepage         = 'https://github.com/pianxian/PXBifrost'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pianxian' => '935932000@qq.com' }
  s.source           = { :git => 'https://github.com/pianxian/PXBifrost.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Pod/Classes/**/*.h'
  s.default_subspecs = 'All'
  s.requires_arc = true
  
  s.subspec 'All' do |subspec|
    subspec.dependency 'PXBifrost/Core'
    subspec.dependency 'PXBifrost/Mediator'
    subspec.dependency 'PXBifrost/Service'
    subspec.dependency 'PXBifrost/Router'
  end

  s.subspec 'Core' do |subspec|
    subspec.source_files = 'Classes/Core/**/*.{h,m,c}'
  end

  s.subspec 'Mediator' do |subspec|
    subspec.source_files = 'Classes/Mediator/**/*.{h,m,c}'
  end

  s.subspec 'Service' do |subspec|
    subspec.source_files = 'Classes/Service/**/*.{h,m,c}'
  end

  s.subspec 'Router' do |subspec|
    subspec.source_files = 'Classes/Router/**/*.{h,m,c}'
  end

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }
  
end
