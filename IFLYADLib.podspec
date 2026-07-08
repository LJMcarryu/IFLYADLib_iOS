# 模型 A 可组合分发 podspec。
# 每个 vendored xcframework 只含自身 .o；对 Core/VideoUI 符号保留未定义引用，在 App link 时统一解析。
# 对外分发在【公开仓 LJMcarryu/IFLYADLib_iOS】：s.source 指向其 GitHub Releases tag 6.0.12 的合并 zip
#   （含 7 个 xcframework device+simulator 切片与三域资源 bundle）；vendored_frameworks / resource_bundles 路径相对该 zip 根。
#   本仓库私有，仅承载源码/构建脚本；此 podspec 与公开仓一致。
# 换版本/主机时：重跑 scripts/package-model-a-release.sh 产合并 zip 与 7 个单模块 zip，更新两仓 :http URL 与版本。
# 资源已从 IFLYPlayer.bundle 物理三拆；运行时由 IFLYAdResourceLoader 按域定位同名 .bundle。

Pod::Spec.new do |s|
  s.name = 'IFLYADLib'
  s.version = '6.0.12'
  s.summary = 'IFLYADLib model A composable SDK distribution.'
  s.homepage = 'https://github.com/LJMcarryu/IFLYADLib_iOS'
  s.author = { 'IFLY' => 'placeholder@example.com' }
  s.source = { :http => 'https://github.com/LJMcarryu/IFLYADLib_iOS/releases/download/6.0.12/IFLYADLib-modelA-6.0.12.zip' }
  s.license = { :type => 'MIT', :file => 'LICENSE' }

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
