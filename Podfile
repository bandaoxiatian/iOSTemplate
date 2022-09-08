source 'https://cdn.cocoapods.org/'

platform :ios, '13.0'
inhibit_all_warnings!
use_modular_headers!

# xcremotecache
def xcremotecacheConfig(finalTarget, mode, enabled)
  config = {
    'enabled' => enabled,
    'cache_addresses' => ['http://10.1.125.142:8080/cache'],
    'primary_repo' => 'git@github.com:bandaoxiatian/iOSTemplate.git',
    'mode' => mode,
#    'exclude_build_configurations' => ['Release', 'InHouse'], # useless
    'primary_branch' => 'main'
  }
  if mode == 'producer'
    config['final_target'] = finalTarget
  elsif mode == 'consumer'
    config['check_platform'] = 'iphoneos'
    config['check_build_configuration'] = 'Debug'
  end
  xcremotecache(config)
  puts "[XCRC CONFIG]:\n #{config}\n"
end

xcremotecache_final_target = 'iOSTemplate'
xcremotecache_mode_default = 'producer'
xcremotecache_mode = (ENV['XCRC_MODE'].nil? || ENV['XCRC_MODE'].empty?) ? xcremotecache_mode_default : ENV['XCRC_MODE']
xcremotecache_enabled = (xcremotecache_mode == xcremotecache_mode_default || ENV['BUILD_CONFIGURATION'] == 'Debug') ? true : false
plugin 'cocoapods-xcremotecache'
xcremotecacheConfig(xcremotecache_final_target, xcremotecache_mode, xcremotecache_enabled)

target 'iOSTemplate' do
#  use_frameworks!

pod 'Alamofire'
pod 'RxSwift'
pod 'RxRelay'
pod 'RxCocoa'

end
