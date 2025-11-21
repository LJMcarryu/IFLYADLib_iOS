Pod::Spec.new do |spec|

  spec.name         = "IFLYADLib"
  spec.version      = "5.4.8"
  spec.summary      = "科大讯飞消费者BG-AI营销-ADX广告SDK-IFLYADLib."
  spec.description  = <<-DESC
科大讯飞消费者BG-AI营销-ADX广告SDK-IFLYADLib.使用OC实现
                   DESC

  spec.homepage     = "https://github.com/LJMcarryu/IFLYADLib_iOS"
  spec.license = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "jmliu6" => "jmliu6@iflytek.com" }
  spec.platform     = :ios, "11.0"
  spec.source       = { :git => "https://github.com/LJMcarryu/IFLYADLib_iOS.git", :tag => "#{spec.version}" }

  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.ios.vendored_frameworks = 'IFLYADLib.framework'

  spec.static_framework = true
  spec.resource  = "IFLYADLib.framework/IFLYPlayer.bundle"

end
