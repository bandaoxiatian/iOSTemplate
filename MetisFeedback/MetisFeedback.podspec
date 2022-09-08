
Pod::Spec.new do |s|
  s.name             = 'MetisFeedback'
  s.version          = '0.1.0'
  s.summary          = 'MetisFeedback'
  s.homepage         = 'https://wiki.zhenguanyu.com/iOS/Modules'
  s.license          = 'Private'
  s.author           = { 'liulj' => 'liulj@yuanfudao.com' }
  s.source           = { :git => 'git@gitlab-ee.zhenguanyu.com:metis-mobile/ios/metis-module-feedback.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'Classes/**/*'
  s.resource_bundles = {
    'MetisFeedback' => ['Assets/**/*']
  }

   s.dependency 'MetisLego', '~> 0.1'
   s.dependency 'MetisUI', '~> 0.1'
   s.dependency 'MetisAccount'
end
