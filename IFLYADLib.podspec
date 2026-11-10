# 通用版按广告形式组合接入。
# 每个 vendored xcframework 只含自身 .o；对 Core/VideoUI 符号保留未定义引用，在 App link 时统一解析。
#   （含 7 个 xcframework device+simulator 切片与三域资源 bundle）；vendored_frameworks / resource_bundles 路径相对该 zip 根。

Pod::Spec.new do |s|
  s.name = 'IFLYADLib'
  s.version = '6.5.0'
  s.summary = '讯飞广告 iOS SDK，支持按广告形式组合接入。'
  s.homepage = 'https://github.com/LJMcarryu/IFLYADLib_iOS'
  s.author = 'LJMcarryu'
  s.source = { :http => 'https://download-adsdk.voiceads.cn/ios_sdk/6.5.0/general/IFLYADLib-modelA-6.5.0.zip' }
  s.license = { :type => 'MIT', :file => 'LICENSE' }

  # iOS 11 声明只可随重新构建并验证过的新版本二进制发布；不得套用到旧 release 产物。
  s.platform = :ios, '11.0'
  s.static_framework = true
  s.default_subspecs = 'Full'
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '$(inherited) -ObjC' }
  # 静态 XCFramework 最终由宿主 App 链接，必须同步传播到 aggregate/user target。
  s.user_target_xcconfig = { 'OTHER_LDFLAGS' => '$(inherited) -ObjC' }

  s.subspec 'Core' do |ss|
    ss.vendored_frameworks = 'IFLYAdCore.xcframework'
    ss.resource_bundles = { 'IFLYADLibCoreResources' => ['resources/Core/**/*'] }
    ss.frameworks = 'AdSupport'
    ss.weak_frameworks = 'AppTrackingTransparency'
  end

  s.subspec 'VideoUI' do |ss|
    ss.dependency 'IFLYADLib/Core'
    ss.vendored_frameworks = 'IFLYAdVideoUI.xcframework'
    ss.resource_bundles = { 'IFLYADLibVideoUIResources' => ['resources/VideoUI/**/*'] }
  end

  s.subspec 'Banner' do |ss|
    ss.dependency 'IFLYADLib/Core'
    ss.vendored_frameworks = 'IFLYAdBanner.xcframework'
  end

  s.subspec 'NativeFeed' do |ss|
    ss.dependency 'IFLYADLib/Core'
    ss.vendored_frameworks = 'IFLYAdNativeFeed.xcframework'
  end

  s.subspec 'Splash' do |ss|
    ss.dependency 'IFLYADLib/Core'
    ss.dependency 'IFLYADLib/VideoUI'
    ss.vendored_frameworks = 'IFLYAdSplash.xcframework'
  end

  s.subspec 'Interstitial' do |ss|
    ss.dependency 'IFLYADLib/Core'
    ss.dependency 'IFLYADLib/VideoUI'
    ss.vendored_frameworks = 'IFLYAdInterstitial.xcframework'
  end

  s.subspec 'Reward' do |ss|
    ss.dependency 'IFLYADLib/Core'
    ss.dependency 'IFLYADLib/VideoUI'
    ss.vendored_frameworks = 'IFLYAdReward.xcframework'
    ss.resource_bundles = { 'IFLYADLibRewardResources' => ['resources/Reward/**/*'] }
  end

  s.subspec 'Full' do |ss|
    ss.dependency 'IFLYADLib/Banner'
    ss.dependency 'IFLYADLib/Splash'
    ss.dependency 'IFLYADLib/Interstitial'
    ss.dependency 'IFLYADLib/NativeFeed'
    ss.dependency 'IFLYADLib/Reward'
  end
end
