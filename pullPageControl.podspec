Pod::Spec.new do |s|

  s.name         = "pullPageControl"
  s.version      = "1.0.1"
  s.summary      = "Pull to Refresh and Infinity Scroll"
  s.homepage     = "https://github.com/DimaAvvakumov/PullPageControl.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Dmitry Avvakumov" => "avvakumov@it-baker.ru" }
  s.platform     = :ios, "8.2"

  s.source       = { :git => "https://github.com/DimaAvvakumov/PullPageControl.git" }
  s.source_files = 'PodClasses/*.swift'
  s.framework    = "UIKit"
  s.requires_arc = true

  s.dependency 'RxSwift', '> 4'
  s.dependency 'RxCocoa', '> 4'
  
  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '4.0',
  }
  
end
