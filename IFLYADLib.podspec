# IFLYADLib 6.0.10 模型 A 可组合分发（Core 必选 + 各格式可选）。
# 每个 vendored xcframework 只含自身 .o；对 Core/VideoUI 符号保留未定义引用，在 App link 时统一解析。
# s.source 指向本仓库 GitHub Releases tag 6.0.10 的合并 zip（含 7 个 xcframework device+simulator 切片
#   与三域资源 bundle）；vendored_frameworks / resource_bundles 路径相对该 zip 根。
# 资源已从 IFLYPlayer.bundle 物理三拆；运行时由 IFLYAdResourceLoader 按域定位同名 .bundle。
# 链接需 -ObjC（已内置 OTHER_LDFLAGS），否则静态库 category / +load 会被剥离。

Pod::Spec.new do |s|
  s.name         = 'IFLYADLib'
  s.version      = '6.0.10'
  s.summary      = '科大讯飞消费者BG-AI营销-ADX广告SDK-IFLYADLib（模型 A 可组合）。'
  s.description  = <<-DESC
科大讯飞消费者BG-AI营销-ADX广告SDK-IFLYADLib，使用 OC 实现。
6.0.1 起支持按广告形式可组合接入（模型 A）：Core 必选 + Banner/Splash/Interstitial/NativeFeed/Reward 各格式按需选用，VideoUI 与资源由依赖图自动带入。
                   DESC
  s.homepage     = 'https://github.com/LJMcarryu/IFLYADLib_iOS'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'jmliu6' => 'jmliu6@iflytek.com' }
  s.source       = { :http => 'https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.10/IFLYADLib-modelA-6.0.10.zip' }

  s.platform = :ios, '13.0'
  s.static_framework = true
  s.default_subspecs = 'Full'
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }

  s.subspec 'Core' do |ss|
    ss.vendored_frameworks = 'IFLYAdCore.xcframework'
    ss.resource_bundles = { 'IFLYADLibCoreResources' => ['resources/Core/**/*'] }
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
