

Pod::Spec.new do |spec|

  spec.name         = "TFY_CalendarKiit"

  spec.version      = "2.3.0"

  spec.summary      = "日历完美处理，适合各种场景使用.可以下载demo 学习"

  spec.description  = <<-DESC
                      日历完美处理，适合各种场景使用.可以下载demo 学习
                    DESC

  spec.homepage     = "https://github.com/13662049573/TFY_Calendar"
  
  spec.license      = "MIT"
  
  spec.platform     = :ios, "12.0"

  spec.author       = { "tfyzxc13662049573" => "420144542@qq.com" }
  
  spec.source       = { :git => "https://github.com/13662049573/TFY_Calendar.git", :tag => spec.version }

  spec.source_files  = "TFY_Calendar/TFY_CalendarKiit/**/*.{h,m}"

  spec.frameworks    = "Foundation","UIKit"

  spec.xcconfig      = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include" }
  
  spec.requires_arc = true

end
