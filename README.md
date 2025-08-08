# 📅 TFY_Calendar

<div align="center">

![TFY_Calendar Logo](https://img.shields.io/badge/TFY_Calendar-v2.3.4-blue.svg)
![iOS Version](https://img.shields.io/badge/iOS-15.0+-green.svg)
![Swift Support](https://img.shields.io/badge/Swift-Supported-orange.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

**🎯 完美日历处理数据，适合各种场景**

[English](README.md) | [中文](README_CN.md)

</div>

---

## ✨ 特性

- 🎨 **高度可定制** - 支持自定义外观、颜色、字体等
- 📱 **iOS 15+ 支持** - 完美适配最新iOS系统
- 🚀 **Swift 友好** - 完整的Swift支持，使用`NS_SWIFT_NAME`优化
- 📊 **多种显示模式** - 月视图、周视图灵活切换
- 🎯 **事件管理** - 支持事件标记、多事件显示
- 🌙 **农历支持** - 内置农历显示功能
- 🔄 **流畅动画** - 平滑的切换和滚动动画
- 📋 **数据源驱动** - 灵活的数据源和代理模式
- 🎪 **占位符控制** - 多种占位符显示策略
- 🔗 **联动选择** - 支持日期范围联动选择

## 🎨 功能展示

### 基础日历
- 月视图/周视图切换
- 自定义工作日显示
- 今天日期高亮
- 选中状态管理

### 高级功能
- 事件点显示
- 自定义单元格
- 农历显示
- 范围选择
- 联动填充

### 外观定制
- 字体自定义
- 颜色主题
- 边框样式
- 圆角设置
- 间距调整

## 📦 安装

### CocoaPods

```ruby
pod 'TFY_Calendar'
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/your-repo/TFY_Calendar.git", from: "2.3.4")
]
```

### 手动安装

1. 下载项目文件
2. 将 `TFY_CalendarKiit` 文件夹添加到您的项目中
3. 导入头文件：`#import "TFY_CalendarKiit.h"`

## 🚀 快速开始

### 基础使用

```objc
#import "TFY_CalendarKiit.h"

@interface ViewController () <TFYCa_CalendarDelegate, TFYCa_CalendarDataSource>
@property (nonatomic, strong) TFY_Calendar *calendar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建日历
    self.calendar = [[TFY_Calendar alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 300)];
    self.calendar.delegate = self;
    self.calendar.dataSource = self;
    [self.view addSubview:self.calendar];
    
    // 基本配置
    self.calendar.scope = TFYCa_CalendarScopeMonth;
    self.calendar.allowsSelection = YES;
    self.calendar.allowsMultipleSelection = NO;
}

@end
```

### Swift 使用

```swift
import TFY_CalendarKiit

class ViewController: UIViewController {
    
    private var calendar: TFY_Calendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建日历
        calendar = TFY_Calendar(frame: CGRect(x: 0, y: 100, width: view.frame.size.width, height: 300))
        calendar.delegate = self
        calendar.dataSource = self
        view.addSubview(calendar)
        
        // 基本配置
        calendar.scope = .month
        calendar.allowsSelection = true
        calendar.allowsMultipleSelection = false
    }
}

// MARK: - TFYCa_CalendarDelegate
extension ViewController: TFYCa_CalendarDelegate {
    func calendar(_ calendar: TFY_Calendar, didSelectDate date: Date, atMonthPosition monthPosition: TFYCa_CalendarMonthPosition) {
        print("选中日期: \(date)")
    }
}
```

## 🎨 自定义外观

```objc
// 配置外观
TFY_CalendarAppearance *appearance = self.calendar.appearance;

// 字体设置
appearance.titleFont = [UIFont systemFontOfSize:16];
appearance.subtitleFont = [UIFont systemFontOfSize:12];
appearance.weekdayFont = [UIFont boldSystemFontOfSize:14];

// 颜色设置
appearance.titleDefaultColor = [UIColor blackColor];
appearance.titleSelectionColor = [UIColor whiteColor];
appearance.selectionColor = [UIColor systemBlueColor];
appearance.todayColor = [UIColor systemRedColor];

// 边框设置
appearance.borderRadius = 8.0;
appearance.borderDefaultColor = [UIColor lightGrayColor];
appearance.borderSelectionColor = [UIColor systemBlueColor];
```

## 📊 数据源配置

```objc
// 实现数据源方法
- (NSString *)calendar:(TFY_Calendar *)calendar titleForDate:(NSDate *)date {
    // 自定义日期标题
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"d";
    return [formatter stringFromDate:date];
}

- (NSString *)calendar:(TFY_Calendar *)calendar subtitleForDate:(NSDate *)date {
    // 自定义副标题
    return @"事件";
}

- (NSInteger)calendar:(TFY_Calendar *)calendar numberOfEventsForDate:(NSDate *)date {
    // 返回事件数量
    return 3;
}

- (NSDate *)minimumDateForCalendar:(TFY_Calendar *)calendar {
    // 最小日期
    return [NSDate date];
}

- (NSDate *)maximumDateForCalendar:(TFY_Calendar *)calendar {
    // 最大日期
    return [[NSDate date] dateByAddingTimeInterval:365*24*60*60];
}
```

## 🎯 高级功能

### 事件显示

```objc
// 设置事件颜色
- (NSArray<UIColor *> *)calendar:(TFY_Calendar *)calendar 
                        appearance:(TFY_CalendarAppearance *)appearance 
              eventDefaultColorsForDate:(NSDate *)date {
    return @[[UIColor redColor], [UIColor blueColor], [UIColor greenColor]];
}
```

### 自定义单元格

```objc
// 注册自定义单元格
[self.calendar registerClass:[CustomCalendarCell class] forCellReuseIdentifier:@"CustomCell"];

// 实现自定义单元格
- (__kindof TFY_CalendarCell *)calendar:(TFY_Calendar *)calendar 
                               cellForDate:(NSDate *)date 
                          atMonthPosition:(TFYCa_CalendarMonthPosition)position {
    CustomCalendarCell *cell = [calendar dequeueReusableCellWithIdentifier:@"CustomCell" 
                                                                  forDate:date 
                                                          atMonthPosition:position];
    // 配置单元格
    return cell;
}
```

### 联动选择

```objc
// 设置联动填充类型
self.calendar.appearance.cellFillType = TFYCa_CellfillTypeLinkage;

// 实现联动选择逻辑
- (TFYCa_fillTypeLinkageSelectionType)calendar:(TFY_Calendar *)calendar 
                                      appearance:(TFY_CalendarAppearance *)appearance 
                               linkageDefaultForDate:(NSDate *)date {
    // 返回联动选择类型
    return TFYCa_fillTypeLinkageSelectionTypeMiddle;
}
```

## 📱 系统要求

- **iOS**: 15.0+
- **Xcode**: 13.0+
- **Swift**: 5.0+
- **Objective-C**: 支持

## 🔧 配置选项

### 日历属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `scope` | `TFYCa_CalendarScope` | 显示模式（月/周） |
| `scrollDirection` | `TFYCa_CalendarScrollDirection` | 滚动方向 |
| `allowsSelection` | `BOOL` | 是否允许选择 |
| `allowsMultipleSelection` | `BOOL` | 是否允许多选 |
| `pagingEnabled` | `BOOL` | 是否启用分页 |
| `placeholderType` | `TFYCa_CalendarPlaceholderType` | 占位符类型 |

### 外观属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `titleFont` | `UIFont` | 日期字体 |
| `subtitleFont` | `UIFont` | 副标题字体 |
| `selectionColor` | `UIColor` | 选中颜色 |
| `todayColor` | `UIColor` | 今天颜色 |
| `borderRadius` | `CGFloat` | 圆角半径 |

## 🎨 主题示例

### 默认主题
```objc
appearance.titleDefaultColor = [UIColor blackColor];
appearance.selectionColor = [UIColor systemBlueColor];
appearance.todayColor = [UIColor systemRedColor];
```

### 深色主题
```objc
appearance.titleDefaultColor = [UIColor whiteColor];
appearance.selectionColor = [UIColor systemBlueColor];
appearance.todayColor = [UIColor systemOrangeColor];
```

### 自定义主题
```objc
appearance.titleDefaultColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
appearance.selectionColor = [UIColor colorWithRed:0.1 green:0.6 blue:0.9 alpha:1.0];
appearance.todayColor = [UIColor colorWithRed:0.9 green:0.3 blue:0.3 alpha:1.0];
```

## 🤝 贡献

我们欢迎所有形式的贡献！

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目基于 MIT 许可证开源 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者！

---

<div align="center">

**⭐ 如果这个项目对您有帮助，请给我们一个星标！**

Made with ❤️ by TFY Team

</div>
