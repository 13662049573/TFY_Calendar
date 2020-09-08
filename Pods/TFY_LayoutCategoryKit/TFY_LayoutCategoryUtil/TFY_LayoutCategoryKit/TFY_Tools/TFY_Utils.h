//
//  Utils.h
//  LayoutCategoryUtil
//
//  Created by 田风有 on 2020/9/4.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WKWebView.h>

static NSString * _Nonnull const AppLanguage = @"appLanguage";

#define Localized(key, comment)  [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:AppLanguage]] ofType:@"lproj"]] localizedStringForKey:(key) value:@"" table:comment]

NS_ASSUME_NONNULL_BEGIN

#pragma mark*******************************************判断获取网络数据****************************************

typedef enum : NSInteger {
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
} NetworkStatus;

typedef enum : NSUInteger {
    SSOperatorsTypeChinaTietong,//中国铁通
    SSOperatorsTypeTelecom,//中国电信
    SSOperatorsTypeChinaUnicom,//中国联通
    SSOperatorsTypeChinaMobile,//中国移动
    SSOperatorsTypeUnknown,//未知
} SSOperatorsType;


extern NSString *kReachabilityChangedNotification;

#pragma mark****************************************手机权限授权方法开始****************************************

typedef enum : NSInteger {
    Celsius = 0,
    Fahrenheit,
} Temperature;

@interface TFY_Utils : NSObject
#pragma mark------------------------------------------gcd定时器方法---------------------------------------

/**初始化计时器*/
- (instancetype)initWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats queue:(dispatch_queue_t)queue block:(void (^)(void))block;

/**启动*/
- (void)start;
/**暂停*/
- (void)pause;

/**继续*/
- (void)resume;

/**销毁*/
- (void)cancel;

#pragma mark------------------------------------------手机获取网络监听方法---------------------------------------
/** v用于检查给定主机名的可访问性。*/
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

/** 用于检查给定IP地址的可达性。*/
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

/** 检查默认路由是否可用。应该由未连接到特定主机的应用程序使用。*/
+ (instancetype)reachabilityForInternetConnection;

/** 开始侦听当前运行循环的可达性通知。*/
- (BOOL)startNotifier;
- (void)stopNotifier;

- (NetworkStatus)currentReachabilityStatus;

/** WWAN可能可用，但在建立连接之前不会处于活动状态。 WiFi可能需要VPN on Demand连接。*/
- (BOOL)connectionRequired;
/**获取网络状态 2G/3G/4G/wifi*/
+(NSString *)getNetconnType;

#pragma mark------------------------------------------各种方法使用------------------------------------------

#pragma mark------------------------------------------国际化设置---------------------------------------

+(instancetype)shareInstance;

/**初始化多语言功能*/
- (void)initLanguage;

/**当前语言*/
- (NSString *)currentLanguage;

/***设置要转换的语言*/
- (void)setLanguage:(NSString *)language;

/***设置为系统语言*/
- (void)systemLanguage;
/**将视图添加最上层的--Window--*/
- (UIWindow*)lastWindow;

#pragma mark****************************************字符串方法***************************************

/***  获取长度为stringLength的随机字符串, 随机数字字符混合类型字符串函数*/
+(NSString *)getRandomString:(NSInteger)stringLength;

/***  随机数字类型字符串函数*/
+(NSString *)getRandomNumberString:(NSInteger)stringLength;

/***  随机字符类型字符串函数*/
+(NSString *)getRandomCharacterString:(NSInteger)stringLength;

/***  获取wifi信号 method*/
+(NSString*)currentWifiSSID;

/***  获取设备的UUID*/
+(NSString *)gen_uuid;

/***  替换掉Json字符串中的换行符*/
+(NSString *)ReplacingNewLineAndWhitespaceCharactersFromJson:(NSString *)jsonStr;

/***  把多个json字符串转为一个json字符串*/
+(NSString *)objArrayToJSON:(NSArray *)array;

/***   获取当前时间*/
+(NSString *)audioTime;

/***   字符串时间——时间戳*/
+(NSString *)cTimestampFromString:(NSString *)theTime;

/***   时间戳——字符串时间*/
+(NSString *)cStringFromTimestamp:(NSString *)timestamp;

/***  两个时间之差*/
+(NSString *)intervalFromLastDate:(NSString *)dateString1 toTheDate:(NSString *)dateString2;

/***   一个时间距现在的时间*/
+(NSString *)intervalSinceNow:(NSString *)theDate;

/***  将字符串转化为中文时间*/
+(NSString *)Formatter:(NSString *)time;

/***  去掉手机号码上的+号和+86*/
+(NSString *)formatPhoneNum:(NSString *)phone;

/***  手机系统版本*/
+(NSString *)phoneVersions;

/***  设备名称*/
+(NSString *)deviceName;

/***  获取当前版本号*/
+(NSString *)cfbundleVersion;

/***  获取当前应用名称*/
+(NSString *)cfbundleDisplayName;

/***  当前应用软件版本*/
+(NSString *)cfbundleShortVersionString;

/***  国际化区域名称*/
+(NSString *)localizedModel;

/***  获取当前年份*/
+(NSString *)setDateFormat;

/***  当前使用的语言*/
+(NSString *)defaultsTH;

/***  程序主目录，可见子目录(3个):Documents、Library、tmp*/
+(NSString *)homePath;

/***   程序目录，不能存任何东西*/
+(NSString *)appPath;

/***  文档目录，需要ITUNES同步备份的数据存这里，可存放用户数据*/
+(NSString *)docPath;

/***  配置目录，配置文件存这里*/
+(NSString *)libPrefPath;

/***  缓存目录，系统永远不会删除这里的文件，ITUNES会删除*/
+(NSString *)libCachePath;

/***  临时缓存目录，APP退出后，系统可能会删除这里的内容*/
+(NSString *)tmpPath;

/***  获取本机IP*/
+(NSString *)getIPAddress;

/***  获取WIFI的MAC地址*/
+(NSString *)getWifiBSSID;

/***   获取WIFI名字*/
+(NSString *)getWifiSSID;

/***  针对蜂窝网络判断是3G或者4G*/
+(NSString *)getNetType;
/**获取营运商*/
+(SSOperatorsType)getOperatorsType;
/***  获取设备IDFV*/
+(NSString *)getDeviceIDFV;

/***  获取设备IMEI*/
+(NSString*)getDeviceIMEI;

/***  获取设备MAC*/
+(NSString*)getDeviceMAC;

/***  获取设备UUID*/
+(NSString*)getDeviceUUID;

/***  截取字符串后几位*/
+(NSString *)substring:(NSString *)substring length:(NSInteger )lengths;

/***  不需要加密的参数请求*/
+(NSString *)requestparmereaddWithDict:(NSDictionary *)dict;

/***  秒数转换成时间,时，分，秒 转换成时分秒*/
+(NSString *)timeFormatted:(int)totalSeconds;

/***  视频显示时间*/
+(NSString *)convertSecond2Time:(int)second;

/***   将时间数据（毫秒）转换为天和小时*/
+(NSString*)getOvertime:(NSString*)mStr;

/***   获取图片格式*/
+(NSString *)typeForImageData:(NSData *)data;

/***  指定字符串末尾倒数第5个 是 . 替换成自己需要的字符*/
+(NSString *)stringByReplacing_String:(NSString *)str withString:(NSString *)String;

/***  字典转化成字符串*/
+(NSString*)dictionaryToJsonString:(NSDictionary *)dic;

/***  图片转f字符串*/
+(NSString *)imageToString:(UIImage *)image;

/***   出生日期计算星座*/
+(NSString *)getAstroWithMonth:(int)m day:(int)d;

/***   计算生肖*/
+(NSString *)getZodiacWithYear:(NSString *)year;

/***  将中文字符串转为拼音*/
+(NSString *)chineseStringToPinyin:(NSString *)string;

/***  iOS 隐藏手机号码中间的四位数字*/
+(NSString *)numberSuitScanf:(NSString*)number;

/***  银行卡号的格式只显示最后四个数字其他*代替*/
+(NSString *)getNewBankNumWitOldBankNum:(NSString *)bankNum;

/***  邮箱的隐藏显示用*替换*/
+(NSString *)hiddenEmailNum:(NSString *)EmailStr;

/***  去掉小数点后无效的0*/
+ (NSString *)deleteFailureZero:(NSString *)string;

/***  根据字节大小返回文件大小字符KB、MB*/
+ (NSString *)stringFromByteCount:(long long)byteCount;

/***  获得设备型号*/
+ (NSString *)getCurrentDeviceModel;

/***  根据字节大小返回文件大小字符KB、MB GB*/
+(NSString *)convertFileSize:(long long)size;

/*** 获取当前IP地址*/
+(nullable NSString*)getCurrentWifiIP;

#pragma mark****************************************判断方法****************************************
/***  判断字符串是否是纯数字*/
+(BOOL)isPureNumber:(NSString *)string;

/***  判断数组是否为空*/
+(BOOL)isBlankArray:(NSArray *)array;

/***  拿去存储的当前状态 */
+(BOOL)addWithisLink:(NSString *)isLink;

/***  判断目录是否存在，不存在则创建*/
+(BOOL)hasLive:(NSString *)path;

/***   判断字符串是否为空  @return YES or NO*/
+(BOOL)judgeIsEmptyWithString:(NSString *)string;

/**检测用户输入密码是否以字母开头，6-18位数字和字母组合 YES NO */
+(BOOL)detectionIsPasswordQualified:(NSString *)patternStr;

/*** 检测字符串中是否包含表情符号*/
+(BOOL)stringContainsEmoji:(NSString *)string;

/*** 判断字符串是否是整形数字*/
+(BOOL)isPureInt:(NSString *)string;

/*** 判断是否为空NSNumber对象，nil,NSNull都为空，不是NSNumber对象也判为空*/
+(BOOL)emptyNSNumber:(NSNumber *)number;

/***  判断是否为空NSDictionary对象，nil,NSNull,@{}都为空,零个键值对也是空，不是NSDictionary对象也判为空*/
+(BOOL)emptyNSDictionary:(NSDictionary *)dictionary;

/***  判断是否为空NSSet对象，nil,NSNull,@{}都为空，零个键值对也是空不是NSSet对象也判为空*/
+(BOOL)emptyNSSet:(NSSet *)set;

/***  判断email格式是否正确，符合格式则YES，否则为NO*/
+(BOOL)email:(NSString *)email;

/***  验证手机号 符合则为YES，不符合则为NO*/
+(BOOL)mobilePhoneNumber:(NSString *)mobile;

/***  判断是否全数字 符合则为YES，不符合则为NO*/
+(BOOL)OnlyDigitalNumber:(NSString *)number;

/*** 判断是不是小数，如1.2这样  符合则为YES，不符合则为NO*/
+(BOOL)floatNumber:(NSString *)number;

/***   判断版本号是否发生变化，有为 yes*/
+(BOOL)version_CFBundleShortVersionString;

/**  判断手机是否越狱*/
+(BOOL)isJailBreak;

/***  判断是否需要过滤的特殊字符：~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€。*/
+(BOOL)isIncludeSpecialCharact:(NSString *)str;

/***  验证身份证号码*/
+ (BOOL)isIdentityCardNumber:(NSString *)number;

/***  验证香港身份证号码*/
+ (BOOL)isIdentityHKCardNumber:(NSString *)number;

/***  验证密码格式（包含大写、小写、数字）*/
+ (BOOL)isConformSXPassword:(NSString *)password;

/***  验证护照*/
+ (BOOL)isPassportNumber:(NSString *)number;

/***  判断是否为纯汉字*/
+ (BOOL)isChineseCharacters:(NSString *)string;

/*** 判断是否包含字母*/
+ (BOOL)isContainLetters:(NSString *)string;

/***  判断4-8位汉字：位数可更改*/
+ (BOOL)combinationChineseCharacters:(NSString *)string;

/***  判断6-18位字母或数字组合：位数可更改*/
+ (BOOL)combinationOfLettersOrNumbers:(NSString *)string;

/***  判断仅中文、字母或数字*/
+ (BOOL)isChineseOrLettersOrNumbers:(NSString *)string;

/*** 判断6~18位字母开头，只能包含“字母”，“数字”，“下划线”：位数可更改*/
+ (BOOL)isValidPassword:(NSString *)string;

/*** 判断是否为大写字母*/
+ (BOOL)isCapitalLetters:(NSString *)string;

/***  判断是否为小写字母*/
+ (BOOL)isLowercaseLetters:(NSString *)string;

/*** 判断是否以字母开头*/
+ (BOOL)isLettersBegin:(NSString *)string;

/*** 判断是否以汉字开头*/
+ (BOOL)isChineseBegin:(NSString *)string;

/***  验证运营商:移动*/
+ (BOOL)isMobilePperators:(NSString *)string;

/***  验证运营商:联通*/
+ (BOOL)isUnicomPperators:(NSString *)string;

/*** 验证运营商:电信*/
+ (BOOL)isTelecomPperators:(NSString *)string;

/***  判断数组中数字是否连续*/
+(BOOL)suibian:(NSArray*)array;

/***  判断数组中，字母是否连续*/
+(BOOL)hasSerialSubstrWithString:(NSString*)string;

/*** pincode是相同的或连续的*/
+(BOOL)checkPincode:(NSString*)pincode;

/*** 检测WIFI功能是否打开*/
+(BOOL)isWiFiOpened;

/**判断当前时间和结束时间是否是将来  YES */
+(BOOL)compareDate:(NSDate*)stary withDate:(NSDate*)end;
/**
 * 识别整体字符串里面是否包含指定字符串  YES
 */
+(BOOL)judgmentstring:(NSString *)string OfString:(NSString *)ofString;
/**是否开插sim卡*/
+ (BOOL)simCardInseerted;
#pragma mark****************************************没有返回方法****************************************

#pragma  mark - NSUserDefaults存取操作
/***  存储当前BOOL*/
+(void)saveBoolValueInUD:(BOOL)value forKey:(NSString *)key;

/***  存储当前NSString*/
+(void)saveStrValueInUD:(NSString *)str forKey:(NSString *)key;

/***  存储当前NSData*/
+(void)saveDataValueInUD:(NSData *)data forKey:(NSString *)key;

/***  存储当前NSDictionary*/
+(void)saveDicValueInUD:(NSDictionary *)dic forKey:(NSString *)key;

/***  存储当前NSArray*/
+(void)saveArrValueInUD:(NSArray *)arr forKey:(NSString *)key;

/***  存储当前NSDate*/
+(void)saveDateValueInUD:(NSDate *)date forKey:(NSString *)key;

/***  存储当前NSInteger*/
+(void)saveIntValueInUD:(NSInteger)value forKey:(NSString *)key;

/***   保存模型id*/
+(void)saveValueInUD:(id)value forKey:(NSString *)key;

/***  获取保存的id*/
+(id)getValueInUDWithKey:(NSString *)key;

/***   图片点击放大缩小*/
+(void)showImage:(UIImageView*)avatarImageView;

/***  获取保存的NSDate*/
+(NSDate *)getDateValueInUDWithKey:(NSString *)key;

/***  获取保存的NSString*/
+(NSString *)getStrValueInUDWithKey:(NSString *)key;

/***  获取保存的NSInteger*/
+(NSInteger )getIntValueInUDWithKey:(NSString *)key;

/***  获取保存的NSDictionary*/
+(NSDictionary *)getDicValueInUDWithKey:(NSString *)key;

/***  获取保存的NSArray*/
+(NSArray *)getArrValueInUDWithKey:(NSString *)key;

/***  获取保存的NSData*/
+(NSData *)getdataValueInUDWithKey:(NSString *)key;

/***   归档*/
+ (void)keyedArchiverObject:(id)object ForKey:(NSString *)key ToFile:(NSString *)path;

/***  反归档*/
+(NSArray *)keyedUnArchiverForKey:(NSString *)key FromFile:(NSString *)path;

/***  将数组拆分成固定长度的子数组*/
+(NSArray *)splitArray:(NSArray *)array withSubSize:(int)subSize;

/***  获取保存的BOOL*/
+(BOOL)getBoolValueInUDWithKey:(NSString *)key;

/***  删除对应的KEY*/
+(void)removeValueInUDWithKey:(NSString *)key;

/***  直接跳转到手机浏览器*/
+(void)openURLAtSafari:(NSString *)urlString;

/***  设置语音提示*/
+(void)SpeechSynthesizer:(NSString *)SpeechUtterancestring;

/***  心跳动画*/
+(void)heartbeatView:(UIView *)view duration:(CGFloat)fDuration maxSize:(CGFloat)fMaxSize durationPerBeat:(CGFloat)fDurationPerBeat;

/***  保存数组数据以  data.plist*/
+(void)save:(NSArray *)Array data_plist:(NSString *)plistname;

/***  拨打电话号码*/
+(void)makePhoneCallWithNumber:(NSString *)number;

/***   调转到系统邮箱*/
+(void)makeEmil:(NSString *)mailbox;

/***  保存相应viwe的图片到相册*/
+(void)savePhoto:(UIView *)views;
+(void)saveImage:(UIImage *)image assetCollectionName:(NSString *)collectionName;

/***  修改状态栏的颜色*/
+ (void)statusBarBackgroundColor:(UIColor *)statusBarColor;

/***  改变导航栏工具条字体颜色 0 为白色 1 为黑色*/
+(void)BackstatusBarStyle:(NSInteger)index;

/***  按钮旋转动画*/
+(void)RotatinganimationView:(UIButton *)btn animateWithDuration:(NSTimeInterval)duration;

/***  得到中英文混合字符串长度*/
+ (int)lengthForText:(NSString *)text;

/***  清楚缓存数据*/
+(void)clearFile;

/***  打印成员变量列表*/
+ (void)runTimeConsoleMemberListWithClassName:(Class)className;

/***  打印属性列表*/
+ (void)runTimeConsolePropertyListWithClassName:(Class)className;

/***  截取控制器所生产图片*/
+ (void)screenSnapshot:(UIView *)snapshotView finishBlock:(void(^)(UIImage *snapShotImage))finishBloc;

#pragma mark****************************************其他方法****************************************
/***  过滤数组中相等的数据*/
+(NSArray *)filterSameObject:(NSArray *)array;

/***  获取保存好的数组数据以  data.plist*/
+(NSArray *)readsenderArraydata_plist:(NSString *)plistname;

/***  获取某个view在屏幕上的frame*/
+(CGRect)rectFromSunView:(UIView *)view;

/***  获取缓存数据单位 M*/
+(float)readCacheSize;

/*** 温度单位转换方法*/
+ (CGFloat)temperatureUnitExchangeValue:(CGFloat)value changeTo:(Temperature)unit;
/**
 *  横屏截图长度 --- 获取主图片数据所返回的总图片长度 vertical 横屏 1 竖屏 0
 */
+ (void)WKWebViewScroll:(WKWebView *)webView vertical:(NSInteger)vertical CaptureCompletionHandler:(void(^)(UIImage *capturedImage))completionHandler;
@end

@interface UIView (Utils_Chain)
/**
 *  截取图片会带哦
 */
- (void)screenSnapshot:(void(^)(UIImage *snapShotImage))finishBlock;
@end

@interface NSBundle (Utils_Chain)
/**
 * 语言数据
 */
+(void)setLanguage:(NSString *)language;

@end

NS_ASSUME_NONNULL_END
