//
//  NSString+TFY_String.h
//  TFY_AutoLMTools
//
//  Created by 田风有 on 2019/5/20.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (TFY_String)
/**
 *  md2 hash, 返回小写字符串.
 */
- (nullable NSString *)tfy_md2String;

/**
 *  md4 hash, 返回小写字符串.
 */
- (nullable NSString *)tfy_md4String;

/**
 *  md5 hash, 返回小写字符串.
 */
- (nullable NSString *)tfy_md5String;

/**
 *  sha1 hash, 返回小写字符串.
 */
- (nullable NSString *)tfy_sha1String;

/**
 *  sha224 hash, 返回小写字符串.
 */
- (nullable NSString *)tfy_sha224String;

/**
 *  sha256 hash, 返回小写字符串.
 */
- (nullable NSString *)tfy_sha256String;
/**
 *  sha384 hash, 返回小写字符串.
 */
- (nullable NSString *)tfy_sha384String;
/**
 *  sha512 hash, 返回小写字符串.
 */
- (nullable NSString *)tfy_sha512String;
/**
 * HMAC MD5 hash, 返回一个小写字符串。此 HMAC 进程将密钥与消息数据混合，使用哈希函数对混合结果进行哈希计算，将所得哈希值与该密钥混合，然后再次应用哈希函数。
 */
- (nullable NSString *)tfy_hmacMD5StringWithKey:(NSString *)key;

/**
 * HMAC SHA1 hash, 返回一个小写字符串。此 HMAC 进程将密钥与消息数据混合，使用哈希函数对混合结果进行哈希计算，将所得哈希值与该密钥混合，然后再次应用哈希函数。
 */
- (nullable NSString *)tfy_hmacSHA1StringWithKey:(NSString *)key;

/**
 * HMAC SHA224 hash, 返回一个小写字符串。此 HMAC 进程将密钥与消息数据混合，使用哈希函数对混合结果进行哈希计算，将所得哈希值与该密钥混合，然后再次应用哈希函数。
 */
- (nullable NSString *)tfy_hmacSHA224StringWithKey:(NSString *)key;

/**
 * HMAC SHA256 hash, 返回一个小写字符串。此 HMAC 进程将密钥与消息数据混合，使用哈希函数对混合结果进行哈希计算，将所得哈希值与该密钥混合，然后再次应用哈希函数。
 */
- (nullable NSString *)tfy_hmacSHA256StringWithKey:(NSString *)key;

/**
 * HMAC SHA384 hash, 返回一个小写字符串。此 HMAC 进程将密钥与消息数据混合，使用哈希函数对混合结果进行哈希计算，将所得哈希值与该密钥混合，然后再次应用哈希函数。
 */
- (nullable NSString *)tfy_hmacSHA384StringWithKey:(NSString *)key;

/**
 * HMAC SHA512 hash, 返回一个小写字符串。此 HMAC 进程将密钥与消息数据混合，使用哈希函数对混合结果进行哈希计算，将所得哈希值与该密钥混合，然后再次应用哈希函数。
 */
- (nullable NSString *)tfy_hmacSHA512StringWithKey:(NSString *)key;
/**
 * 采用 base64 对 字符串 进行编码。为了使二进制数据可以通过非纯 8-bit 的传输层传输.
 */
- (nullable NSString *)tfy_base64EncodedString;
/**
 * 对 base64 编码字符串进行解码
 */
+ (nullable NSString *)tfy_stringWithBase64EncodedString:(NSString *)base64EncodedString;
/**
 * URL 编码，使用 string 符合 URL 的规范，因为在标准的 URL 规范中中文和很多的字符是不允许出现在 URL 中的。
 */
- (NSString *)tfy_stringByURLEncode;
/**
 * URL 解码，返回 URL 编码前的字符串.
 */
- (NSString *)tfy_stringByURLDecode;
/**
 * 使字符串避开 HTML 语句，例如："a < b" 转成 "a&lt;b"。
 */
- (NSString *)tfy_stringByEscapingHTML;
/**
 * 给出最大宽高，计算字符串的 size.
 */
- (CGSize)tfy_sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;
/**
 * 返回字符串的宽度
 */
- (CGFloat)tfy_widthForFont:(UIFont *)font;
/**
 * 给出最大宽度，返回字符串的高度
 */
- (CGFloat)tfy_heightForFont:(UIFont *)font width:(CGFloat)width;

// 兼容 NSNumber 的部分属性，用这些属性时可以将 NSString 当做 NSNumber 来使用.
@property (readonly) char tfy_charValue;
@property (readonly) unsigned char tfy_unsignedCharValue;
@property (readonly) short tfy_shortValue;
@property (readonly) unsigned short tfy_unsignedShortValue;
@property (readonly) unsigned int tfy_unsignedIntValue;
@property (readonly) long tfy_longValue;
@property (readonly) unsigned long tfy_unsignedLongValue;
@property (readonly) unsigned long long tfy_unsignedLongLongValue;
@property (readonly) NSUInteger tfy_unsignedIntegerValue;
/**
 * 生成一个 UUID（通用唯一识别码）
 */
+ (NSString *)tfy_stringWithUUID;

/**
 * 将 UTF32 Char 字符串转换为NSString
 */
+ (nullable NSString *)tfy_stringWithUTF32Char:(UTF32Char)char32;

/**
 * 将长度为 length 的 UTF32 Char 字符串数组转换为 NSString
 */
+ (nullable NSString *)tfy_stringWithUTF32Chars:(const UTF32Char *)char32 length:(NSUInteger)length;
/**
 * 将range位置的字符转为 UTF32 Char 字符串数组再枚举数组元素执行 block ，直到设置 *stop 为 YES
 */
- (void)tfy_enumerateUTF32CharInRange:(NSRange)range usingBlock:(void (^)(UTF32Char char32, NSRange range, BOOL *stop))block;
/**
 * 去掉在头部和尾部的空白字符（空格和换行）
 */
- (NSString *)tfy_stringByTrim;
/**
 * 添加scale到文件名末尾，例如 /p/name.png 变成 /p/name.png@2x.
 */
- (NSString *)tfy_stringByAppendingNameScale:(CGFloat)scale;
/**
 * 添加scale到文件路径末尾，例如 /p/name.png 变成 /p/name@2x.png.
 */
- (NSString *)tfy_stringByAppendingPathScale:(CGFloat)scale;
/**
 * 返回文件的 Scalee. e.g：
 */
- (CGFloat)tfy_pathScale;
/**
 * 判断字符串是否不为空， nil, @"", @"  ", @"\n" 都是空. 如果为空返回：NO 非空返回：YES
 */
- (BOOL)tfy_isNotBlank;
/**
 * 判断字符串是否包含 string
 */
- (BOOL)tfy_containsString:(NSString *)string;
/**
 * 判断当前的字符串是不是url
 */
- (BOOL)tfy_isUrl;
/**
 * 判断字符串是否包含 set 。NSCharacterSet为一组Unicode字符。
 */
- (BOOL)tfy_containsCharacterSet:(NSCharacterSet *)set;
/**
 * 字符串转换为 NSNumber，转换失败返回nil
 */
- (nullable NSNumber *)tfy_numberValue;
/**
 * 字符串转换为 UTF-8 编码的数据
 */
- (nullable NSData *)tfy_dataValue;
/**
 * 返回一个起点为 0，宽度为字符串字符长度的 NSRange数据
 */
- (NSRange)tfy_rangeOfAll;
/**
 * 将json字符串进行解码，返回一个字典或者字符串。例如 NSString: @"{"name":"a","count":2}"  => NSDictionary: @[@"name":@"a",@"count”:@2]。
 */
- (nullable id)tfy_jsonValueDecoded;
/**
 * 获取 UTF8 编码 name 文件里的内容。类似[UIImage imageNamed:]
 */
+ (nullable NSString *)tfy_stringNamed:(NSString *)name;
/**
 * 根据字体、行数、行间距和指定的宽度constrainedWidth计算文本占据的size lineSpacing 行间距 constrainedWidth 文本指定的宽度
 */
- (CGSize)tfy_textSizeWithFont:(UIFont *)font numberOfLines:(NSInteger)numberOfLines lineSpacing:(CGFloat)lineSpacing constrainedWidth:(CGFloat)constrainedWidth;
/**
 *  根据字体、行数、行间距和指定的宽度constrainedWidth计算文本占据的size
 */
- (CGSize)tfy_textSizeWithFont:(UIFont *)font numberOfLines:(NSInteger)numberOfLines constrainedWidth:(CGFloat)constrainedWidth;
/**
 *  计算字符串长度（一行时候）
 */
- (CGSize)tfy_textSizeWithFont:(UIFont*)font limitWidth:(CGFloat)maxWidth;
/**
 * /获取当前的时间
 */
+(NSString*)tfy_getCurrentTimes;
/**
 * 获取当前时间戳有两种方法(以秒为单位)
 */
+(NSString *)tfy_getNowTimeTimestamp;
+(NSString *)tfy_getNowTimeTimestamp2;
 /**
  * 获取当前时间戳  （以毫秒为单位）
  */
+(NSString *)tfy_getNowTimeTimestamp3;
/**
 *   给的是毫秒 返回 YYYY-MM-dd
 */
+ (NSString *)tfy_stringToDate:(NSString *)string;

/**
 *   给的是毫秒 返回  HH:mm
 */
+ (NSString *)tfy_stringHHMMToDate:(NSString *)string;
/**
 *   给的是毫秒 返回  MM-dd HH:mm
 */
+(NSString *)tfy_stringToDateNoYear:(NSString *)date;
/**
 *   给的是毫秒  返回  yyyy/MM/dd
 */
+(NSString *)tfy_stringToDateOnlyYear:(NSString *)dateStrv;

+(NSString *)tfy_birthdayTime:(NSString *)str;
/**
*   给的是毫秒  返回 yyyy年M月d日
*/
+ (NSString *)tfy_dateToString:(NSString *)dateString;
/**
 *   给的是毫秒 yyyy-MM-dd HH:mm
 */
+(NSString *)tfy_togetherToTime:(NSString *)dateStr;
/**
*   给的是毫秒  yyyy-MM-dd HH:mm:ss
*/
+(NSString *)tfy_chooseDateToTime:(NSString *)dateStr;
/**
*   给的是分  返回 yyyy-MM-dd HH:mm
*/
+(NSString *)tfy_timeWithStr:(NSString *)str;
/**
*   给的是分  返回 HH:mm
*/
+(NSString *)tfy_logTimeWithStr:(NSString *)str;
/**
*   给的是毫秒  返回 MM.dd
*/
+ (NSString *)tfy_secondsStringToDate:(NSString *)string;
/**
 移除结尾的子字符串
 */
- (NSString *)tfy_removeLastSubString:(NSString *)string;
/**
 移除结尾的子字符串, 使用数组传递多个
 */
- (NSString *)tfy_removeLastSubStringsArray:(NSArray<NSString *> *)strings;
/**
 移除结尾的子字符串, 可以输入多个
 */
- (NSString *)tfy_removeLastSubStrings:(NSString *)string, ... NS_REQUIRES_NIL_TERMINATION;
/**
 * ----两个数相加-----------
 */
+(NSString *)tfy_calculateByadding:(NSString *)number1 secondNumber:(NSString *)number2;
/**
 * ----两个数相减------------ number1 - number2
 */
+(NSString *)tfy_calculateBySubtractingMinuend:(NSString *)number1 subtractorNumber:(NSString *)number2;
/**
 * ----两个数相乘------------
 */
+(NSString *)tfy_calculateByMultiplying:(NSString *)number1 secondNumber:(NSString *)number2;
/**
 * ----两个数相除------------
 */
+ (NSString *)tfy_calculateByDividingNumber:(NSString *)number1 secondNumber:(NSString *)number2;
/**
 * ----四舍五入------------
 */
+ (NSString *)tfy_calculateTargetNumber:(NSString *)targetNumber ByRounding:(NSUInteger)scale;
/**
 * ----是否相等------------
 */
+ (BOOL)tfy_calculateIsEqualNumber:(NSString *)number1 secondNumber:(NSString *)number2;
/**
 * ----是否大于------------
 */
+ (BOOL)tfy_calculateNumber: (NSString *)number1 IsGreaterThan:(NSString *)number2;
/**
 * ----是否小于------------
 */
+ (BOOL)tfy_calculateNumber:(NSString *)number1  IsLessThan:(NSString *)number2;
/**
 * --10指数运算--------
 */
+(NSString *)tfy_calculateTargetNumber:(NSString *)number1 ByRonding:(short)power;
/**
 * ---------单纯保留小数位数----------
 */
+(NSString *)tfy_calculateRetainedDecimalNumber:(NSString *)targetNumber ByRonding:(short)power;
/**
  * 文字间距
 */
- (NSAttributedString *)tfy_attributedStringWithLineSpace:(CGFloat)lineSpace;
///拼音 ->pinyin
- (NSString*)tfy_transformToPinyin;

///拼音首字母 -> py
- (NSString *)tfy_transformToPinyinFirstLetter;

- (NSData *)tfy_utf8Data;
/**
 *  拼接http://或者https://
 */
+ (NSString *)tfy_getCompleteWebsite:(NSString *)urlStr;
/**
 * 根据长度返回字符串
 */
+ (NSString *)tfy_getStringWithRange:(NSRange)range;
/**
 * 传入时间 2020-04-09 返回 星座
 */
+ (NSString *)tfy_getXingzuo:(NSDate *)in_date;
/**
    获取字符串行数和每行的数据
 */
+ (NSArray *)tfy_getLinesArrayOfStringInrowsOfString:(NSString *)text withFont:(UIFont *)font withWidth:(CGFloat)width;
/**
 *   一个时间距现在的时间
 */
+(NSString *)tfy_intervalSinceNow:(NSString *)theDate;

/**
 带子节的string转为NSData
 
 NSData类型
 */
-(NSData*)tfy_convertBytesStringToData ;

/**
 十进制转十六进制
 
 十六进制字符串
 */
- (NSString *)tfy_decimalToHex;

/**
 十进制转十六进制
 length   总长度，不足补0
 十六进制字符串
 */
- (NSString *)tfy_decimalToHexWithLength:(NSUInteger)length;

/**
 十六进制转十进制
 
 十进制字符串
 */
- (NSString *)tfy_hexToDecimal;
/*
 二进制转十进制
 
十进制字符串
 */
- (NSString *)tfy_binaryToDecimal;

/**
 十进制转二进制
 
 二进制字符串
 */
- (NSString *)tfy_decimalToBinary;
/**
 时间戳转标准时间
 
 标准时间 YYYY-MM-dd HH:mm:ss
 */
- (NSString *)tfy_timestampToStandardtime;

/**
 时间戳转标准时间
 
 标准时间数组 @[YYYY-MM-dd, HH:mm:ss]
 */
- (NSArray *)tfy_timestampToStandardtimes;

/// double 类型转化为一位小数字符串
+ (NSString *)keeponedecimalplaceDoubleOne:(double)value;
/// double 类型转化为二位小数字符串
+ (NSString *)keeponedecimalplaceDoubleTwo:(double)value;
/// CGFloat 类型转化为一位小数字符串
+ (NSString *)keeponedecimalplaceFloatOne:(CGFloat)value;
/// CGFloat 类型转化为二位小数字符串
+ (NSString *)keeponedecimalplaceFloatTwo:(CGFloat)value;

///  转字符
- (NSString *)safePathString;
@end

NS_ASSUME_NONNULL_END
