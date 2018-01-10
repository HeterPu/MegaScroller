Pod::Spec.new do |s|
  s.name         = "MegaScroller"
  s.version      = "1.0.0"
  s.ios.deployment_target = '6.0'
  s.summary      = "A Megascroller on ios,which implement by Objective-C. "
  s.homepage     = "https://github.com/HeterPu/MegaScroller"
  s.license      = "MIT"
  s.author             = { "HuterPu" => "wycgpeterhu@sina.com" }
  s.social_media_url   = "http://weibo.com/u/2342495990"
  s.source       = { :git => "https://github.com/HeterPu/MegaScroller.git", :tag => s.version }
  s.source_files  = "MegaScrollerTEST/MegaScrollerTEST/MegaScroller"
  s.requires_arc = true

  s.frameworks = 'Foundation', 'UIKit'
end
