

Pod::Spec.new do |spec|

  spec.name         = "TFY_CalendarKiit"

  spec.version      = "2.0.0"

  spec.summary      = "日历完美处理，适合各种场景使用."

  spec.description  = <<-DESC
                      日历完美处理，适合各种场景使用.
                    DESC

  spec.homepage     = "http://EXAMPLE/TFY_CalendarKiit"
  
  spec.license      = "MIT"
  
  spec.platform     = :ios, "10.0"

  spec.author       = { "tfyzxc13662049573" => "420144542@qq.com" }
  
  spec.source       = { :git => "http://EXAMPLE/TFY_CalendarKiit.git", :tag => spec.version }

  spec.source_files  = "TFY_Calendar/TFY_CalendarKiit/TFY_CalendarDynamicHeader.h", "TFY_Calendar/TFY_CalendarKiit/**/*.{h,m}"

  spec.frameworks    = "Foundation","UIKit"

  spec.xcconfig      = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include" }
  
  spec.requires_arc = true

end
