Pod::Spec.new do |s|

  s.name         = "GZCMulitiDelegate"
  s.version      = "0.0.1"
  s.summary      = "A Multicast delegation for Objective-C called GZCMulitiDelegate."
  s.homepage     = "https://github.com/gzhongcheng/GZCMulitiDelegate"
  s.license      = "MIT"
  s.author       = { "gzhongcheng" => "gzhongcheng@qq.com" }
  s.source       = { :git => "https://github.com/gzhongcheng/GZCMulitiDelegate.git", :tag => "0.0.1" }
  s.platform	 = :iOS, "8.0"
  s.framework    = "UIKit"
  s.source_files  = "GZCMulitiDelegate", "GZCMulitiDelegate/*.{h,m}"

end
