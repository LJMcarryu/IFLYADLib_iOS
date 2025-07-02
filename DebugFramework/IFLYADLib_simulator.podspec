Pod::Spec.new do |spec|

  spec.name         = "IFLYADLib_simulator"
  spec.version      = "5.2.10"
  spec.summary      = "(含模拟器版本)科大讯飞消费者BG-AI营销-ADX广告SDK-IFLYADLib."
  spec.description  = <<-DESC
(含模拟器版本)科大讯飞消费者BG-AI营销-ADX广告SDK-IFLYADLib.使用OC实现
                   DESC

  spec.homepage     = "https://github.com/LJMcarryu/IFLYADLib_iOS"
  spec.license = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "jmliu6" => "jmliu6@iflytek.com" }
  spec.platform     = :ios, "11.0"
  spec.source       = { :git => "https://github.com/LJMcarryu/IFLYADLib_iOS.git", :tag => "#{spec.version}" }

  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  spec.ios.vendored_frameworks = 'IFLYADLib.framework'

  spec.static_framework = true
  spec.resource  = "IFLYADLib.framework/IFLYPlayer.bundle"

end
