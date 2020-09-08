//
//  NSString+TFY_String.m
//  TFY_AutoLMTools
//
//  Created by 田风有 on 2019/5/20.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "NSString+TFY_String.h"
#import "NSNumber+TFY_Tools.h"
#import "NSData+TFY_Data.h"
@implementation NSString (TFY_String)


- (NSString *)tfy_md2String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tfy_md2String];
}

- (NSString *)tfy_md4String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tfy_md4String];
}

- (NSString *)tfy_md5String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tfy_md5String];
}

- (NSString *)tfy_sha1String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tfy_sha1String];
}

- (NSString *)tfy_sha224String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tfy_sha224String];
}

- (NSString *)tfy_sha256String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tfy_sha256String];
}

- (NSString *)tfy_sha384String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tfy_sha384String];
}

- (NSString *)tfy_sha512String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tfy_sha512String];
}

- (NSString *)tfy_hmacMD5StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            tfy_hmacMD5StringWithKey:key];
}

- (NSString *)tfy_hmacSHA1StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            tfy_hmacSHA1StringWithKey:key];
}

- (NSString *)tfy_hmacSHA224StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            tfy_hmacSHA224StringWithKey:key];
}

- (NSString *)tfy_hmacSHA256StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            tfy_hmacSHA256StringWithKey:key];
}

- (NSString *)tfy_hmacSHA384StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            tfy_hmacSHA384StringWithKey:key];
}

- (NSString *)tfy_hmacSHA512StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            tfy_hmacSHA512StringWithKey:key];
}

- (NSString *)tfy_base64EncodedString {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] tfy_base64EncodedString];
}

+ (NSString *)tfy_stringWithBase64EncodedString:(NSString *)base64EncodedString {
    NSData *data = [NSData tfy_dataWithBase64EncodedString:base64EncodedString];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)tfy_stringByURLEncode {
    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        /**
         AFNetworking/AFURLRequestSerialization.m
         
         Returns a percent-escaped string following RFC 3986 for a query string key or value.
         RFC 3986 states that the following characters are "reserved" characters.
         - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
         - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
         In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
         query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
         should be percent-escaped in the query string.
         - parameter string: The string to be percent-escaped.
         - returns: The percent-escaped string.
         */
        static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
        static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
        
        NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
        static NSUInteger const batchSize = 50;
        
        NSUInteger index = 0;
        NSMutableString *escaped = @"".mutableCopy;
        
        while (index < self.length) {
            NSUInteger length = MIN(self.length - index, batchSize);
            NSRange range = NSMakeRange(index, length);
            // To avoid breaking up character sequences such as 👴🏻👮🏽
            range = [self rangeOfComposedCharacterSequencesForRange:range];
            NSString *substring = [self substringWithRange:range];
            NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
            [escaped appendString:encoded];
            
            index += range.length;
        }
        return escaped;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *encoded = (__bridge_transfer NSString *)
        CFURLCreateStringByAddingPercentEscapes(
                                                kCFAllocatorDefault,
                                                (__bridge CFStringRef)self,
                                                NULL,
                                                CFSTR("!#$&'()*+,/:;=?@[]"),
                                                cfEncoding);
        return encoded;
#pragma clang diagnostic pop
    }
}

- (NSString *)tfy_stringByURLDecode {
    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [self stringByRemovingPercentEncoding];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding en = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *decoded = [self stringByReplacingOccurrencesOfString:@"+"
                                                            withString:@" "];
        decoded = (__bridge_transfer NSString *)
        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                NULL,
                                                                (__bridge CFStringRef)decoded,
                                                                CFSTR(""),
                                                                en);
        return decoded;
#pragma clang diagnostic pop
    }
}

- (NSString *)tfy_stringByEscapingHTML {
    NSUInteger len = self.length;
    if (!len) return self;
    
    unichar *buf = malloc(sizeof(unichar) * len);
    if (!buf) return nil;
    [self getCharacters:buf range:NSMakeRange(0, len)];
    
    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < len; i++) {
        unichar c = buf[i];
        NSString *esc = nil;
        switch (c) {
            case 34: esc = @"&quot;"; break;
            case 38: esc = @"&amp;"; break;
            case 39: esc = @"&apos;"; break;
            case 60: esc = @"&lt;"; break;
            case 62: esc = @"&gt;"; break;
            default: break;
        }
        if (esc) {
            [result appendString:esc];
        } else {
            CFStringAppendCharacters((CFMutableStringRef)result, &c, 1);
        }
    }
    free(buf);
    return result;
}

- (CGSize)tfy_sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

- (CGFloat)tfy_widthForFont:(UIFont *)font {
    CGSize size = [self tfy_sizeForFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping];
    return size.width;
}

- (CGFloat)tfy_heightForFont:(UIFont *)font width:(CGFloat)width {
    CGSize size = [self tfy_sizeForFont:font size:CGSizeMake(width, HUGE) mode:NSLineBreakByWordWrapping];
    return size.height;
}

- (BOOL)tfy_matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:NULL];
    if (!pattern) return NO;
    return ([pattern numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)] > 0);
}

- (void)tfy_enumerateRegexMatches:(NSString *)regex
                      options:(NSRegularExpressionOptions)options
                   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block {
    if (regex.length == 0 || !block) return;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!regex) return;
    [pattern enumerateMatchesInString:self options:kNilOptions range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        block([self substringWithRange:result.range], result.range, stop);
    }];
}

- (NSString *)tfy_stringByReplacingRegex:(NSString *)regex
                             options:(NSRegularExpressionOptions)options
                          withString:(NSString *)replacement; {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!pattern) return self;
    return [pattern stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replacement];
}

- (char)tfy_charValue {
    return self.tfy_numberValue.charValue;
}

- (unsigned char)tfy_unsignedCharValue {
    return self.tfy_numberValue.unsignedCharValue;
}

- (short)tfy_shortValue {
    return self.tfy_numberValue.shortValue;
}

- (unsigned short)tfy_unsignedShortValue {
    return self.tfy_numberValue.unsignedShortValue;
}

- (unsigned int)tfy_unsignedIntValue {
    return self.tfy_numberValue.unsignedIntValue;
}

- (long)tfy_longValue {
    return self.tfy_numberValue.longValue;
}

- (unsigned long)tfy_unsignedLongValue {
    return self.tfy_numberValue.unsignedLongValue;
}

- (unsigned long long)tfy_unsignedLongLongValue {
    return self.tfy_numberValue.unsignedLongLongValue;
}

- (NSUInteger)tfy_unsignedIntegerValue {
    return self.tfy_numberValue.unsignedIntegerValue;
}


+ (NSString *)tfy_stringWithUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)string;
}

+ (NSString *)tfy_stringWithUTF32Char:(UTF32Char)char32 {
    char32 = NSSwapHostIntToLittle(char32);
    return [[NSString alloc] initWithBytes:&char32 length:4 encoding:NSUTF32LittleEndianStringEncoding];
}

+ (NSString *)tfy_stringWithUTF32Chars:(const UTF32Char *)char32 length:(NSUInteger)length {
    return [[NSString alloc] initWithBytes:(const void *)char32
                                    length:length * 4
                                  encoding:NSUTF32LittleEndianStringEncoding];
}

- (void)tfy_enumerateUTF32CharInRange:(NSRange)range usingBlock:(void (^)(UTF32Char char32, NSRange range, BOOL *stop))block {
    NSString *str = self;
    if (range.location != 0 || range.length != self.length) {
        str = [self substringWithRange:range];
    }
    NSUInteger len = [str lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
    UTF32Char *char32 = (UTF32Char *)[str cStringUsingEncoding:NSUTF32LittleEndianStringEncoding];
    if (len == 0 || char32 == NULL) return;
    
    NSUInteger location = 0;
    BOOL stop = NO;
    NSRange subRange;
    UTF32Char oneChar;
    
    for (NSUInteger i = 0; i < len; i++) {
        oneChar = char32[i];
        subRange = NSMakeRange(location, oneChar > 0xFFFF ? 2 : 1);
        block(oneChar, subRange, &stop);
        if (stop) return;
        location += subRange.length;
    }
}

- (NSString *)tfy_stringByTrim {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

- (NSString *)tfy_stringByAppendingNameScale:(CGFloat)scale {
    if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
    return [self stringByAppendingFormat:@"@%@x", @(scale)];
}

- (NSString *)tfy_stringByAppendingPathScale:(CGFloat)scale {
    if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
    NSString *ext = self.pathExtension;
    NSRange extRange = NSMakeRange(self.length - ext.length, 0);
    if (ext.length > 0) extRange.location -= 1;
    NSString *scaleStr = [NSString stringWithFormat:@"@%@x", @(scale)];
    return [self stringByReplacingCharactersInRange:extRange withString:scaleStr];
}

- (CGFloat)tfy_pathScale {
    if (self.length == 0 || [self hasSuffix:@"/"]) return 1;
    NSString *name = self.stringByDeletingPathExtension;
    __block CGFloat scale = 1;
    [name tfy_enumerateRegexMatches:@"@[0-9]+\\.?[0-9]*x$" options:NSRegularExpressionAnchorsMatchLines usingBlock: ^(NSString *match, NSRange matchRange, BOOL *stop) {
        scale = [match substringWithRange:NSMakeRange(1, match.length - 2)].doubleValue;
    }];
    return scale;
}

- (BOOL)tfy_isNotBlank {
    NSCharacterSet *blank = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![blank characterIsMember:c]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)tfy_containsString:(NSString *)string {
    if (string == nil) return NO;
    return [self rangeOfString:string].location != NSNotFound;
}

- (BOOL)tfy_containsCharacterSet:(NSCharacterSet *)set {
    if (set == nil) return NO;
    return [self rangeOfCharacterFromSet:set].location != NSNotFound;
}

- (NSNumber *)tfy_numberValue {
    return [NSNumber tfy_numberWithString:self];
}

- (NSData *)tfy_dataValue {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSRange)tfy_rangeOfAll {
    return NSMakeRange(0, self.length);
}

- (id)tfy_jsonValueDecoded {
    return [[self tfy_dataValue] tfy_jsonValueDecoded];
}

+ (NSString *)tfy_stringNamed:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@""];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    if (!str) {
        path = [[NSBundle mainBundle] pathForResource:name ofType:@"txt"];
        str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    }
    return str;
}
/**
 * 根据字体、行数、行间距和指定的宽度constrainedWidth计算文本占据的size lineSpacing 行间距 constrainedWidth 文本指定的宽度
 */
- (CGSize)tfy_textSizeWithFont:(UIFont*)font numberOfLines:(NSInteger)numberOfLines lineSpacing:(CGFloat)lineSpacing constrainedWidth:(CGFloat)constrainedWidth{
    if (self.length == 0) {
        return CGSizeZero;
    }
    CGFloat oneLineHeight = font.lineHeight;
    CGSize textSize = [self boundingRectWithSize:CGSizeMake(constrainedWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    //  行数
    CGFloat rows = textSize.height / oneLineHeight;
    CGFloat realHeight = oneLineHeight;
    // 0 不限制行数，真实高度加上行间距
    if (numberOfLines == 0) {
        if (rows >= 1) {
            realHeight = (rows * oneLineHeight) + (rows - 1) * lineSpacing;
        }
    } else {
        //  行数超过指定行数的时候，限制行数
        if (rows > numberOfLines) {
            rows = numberOfLines;
        }
        realHeight = (rows * oneLineHeight) + (rows - 1) * lineSpacing;
    }
    //  返回真实的宽高
    return CGSizeMake(constrainedWidth, realHeight);
}

/**
 *  根据字体、行数、行间距和指定的宽度constrainedWidth计算文本占据的size
 */
- (CGSize)tfy_textSizeWithFont:(UIFont *)font numberOfLines:(NSInteger)numberOfLines constrainedWidth:(CGFloat)constrainedWidth{
    if (self.length == 0) {
        return CGSizeZero;
    }
    CGFloat oneLineHeight = font.lineHeight;
    CGSize textSize = [self boundingRectWithSize:CGSizeMake(constrainedWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    //  行数
    CGFloat rows = textSize.height / oneLineHeight;
    CGFloat realHeight = oneLineHeight;
    // 0 不限制行数，真实高度加上行间距
    if (numberOfLines == 0) {
        if (rows >= 1) {
            realHeight = (rows * oneLineHeight) + (rows - 1) ;
        }
    } else {
        //  行数超过指定行数的时候，限制行数
        if (rows > numberOfLines) {
            rows = numberOfLines;
        }
        realHeight = (rows * oneLineHeight) + (rows - 1) ;
    }
    //  返回真实的宽高
    return CGSizeMake(constrainedWidth, realHeight);
}

/**
 *  计算字符串长度（一行时候）
 */
- (CGSize)tfy_textSizeWithFont:(UIFont*)font limitWidth:(CGFloat)maxWidth{
    CGSize size = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, 36)options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)  attributes:@{ NSFontAttributeName : font} context:nil].size;
    size.width = size.width > maxWidth ? maxWidth : size.width;
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    return size;
}

   //获取当前的时间
+(NSString*)tfy_getCurrentTimes{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    NSLog(@"currentTimeString =  %@",currentTimeString);
    return currentTimeString;
}
//获取当前时间戳有两种方法(以秒为单位)
+(NSString *)tfy_getNowTimeTimestamp{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;
}
 
+(NSString *)tfy_getNowTimeTimestamp2{
 
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    return timeString;
}
 //获取当前时间戳  （以毫秒为单位）
+(NSString *)tfy_getNowTimeTimestamp3{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    return timeSp;
}
/**
 *   给的是毫秒 返回 YYYY-MM-dd
 */
+ (NSString *)tfy_stringToDate:(NSString *)string{
    //给的是毫秒
    //    NSTimeInterval time = [string doubleValue]/1000.0 + 28800;//因为时差问题要加8小时 == 28800 sec
    //    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:time];
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //    NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
    //    return currentDateStr;
    
    long long time=[string longLongValue];
    
    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:time/1000.0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString*timeString=[formatter stringFromDate:d];
    return timeString;
}
/**
 *   给的是毫秒 返回  HH:mm
 */
+ (NSString *)tfy_stringHHMMToDate:(NSString *)string{
    //给的是毫秒
    //    NSTimeInterval time = [string doubleValue]/1000.0 + 28800;//因为时差问题要加8小时 == 28800 sec
    //    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:time];
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //    NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
    //    return currentDateStr;
    
    long long time=[string longLongValue];
    
    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:time/1000.0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"HH:mm"];
    
    NSString*timeString=[formatter stringFromDate:d];
    return timeString;
}
/**
 *   给的是毫秒 返回  MM-dd HH:mm
 */
+(NSString *)tfy_stringToDateNoYear:(NSString *)date{
    long long time=[date longLongValue];
    
    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:time/1000.0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"MM-dd HH:mm"];
    
    NSString*timeString=[formatter stringFromDate:d];
    return timeString;
    
}
/**
*   给的是毫秒  返回  yyyy/MM/dd
*/
+(NSString *)tfy_stringToDateOnlyYear:(NSString *)dateStr{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy/MM/dd";
    NSDate *date = [format dateFromString:dateStr];
    
    NSTimeInterval interval = [date timeIntervalSince1970];
    long long totalMilliseconds = interval*1000 ;
    return [NSString stringWithFormat:@"%lld",totalMilliseconds];
}

+(NSString *)tfy_birthdayTime:(NSString *)str{
    long long time=[str longLongValue];
    
    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:time];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"yyyy/MM/dd"];
    
    NSString*timeString=[formatter stringFromDate:d];
    return timeString;
}
/**
*   给的是毫秒  返回 yyyy年M月d日
*/
+ (NSString *)tfy_dateToString:(NSString *)dateString{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy年M月d日";
    NSDate *date = [format dateFromString:dateString];
    
    NSTimeInterval interval = [date timeIntervalSince1970];
    long long totalMilliseconds = interval*1000 ;
    return [NSString stringWithFormat:@"%lld",totalMilliseconds];
}
/**
 *   给的是毫秒 yyyy-MM-dd HH:mm
 */
+(NSString *)tfy_togetherToTime:(NSString *)dateStr{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *date = [format dateFromString:dateStr];
    
    NSTimeInterval interval = [date timeIntervalSince1970];
    long long totalMilliseconds = interval*1000 ;
    return [NSString stringWithFormat:@"%lld",totalMilliseconds];
}
/**
*   给的是毫秒  yyyy-MM-dd HH:mm:ss
*/
+(NSString *)tfy_chooseDateToTime:(NSString *)dateStr{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [format dateFromString:dateStr];
    
    NSTimeInterval interval = [date timeIntervalSince1970];
    long long totalMilliseconds = interval*1000 ;
    return [NSString stringWithFormat:@"%lld",totalMilliseconds];
}

/**
*   给的是分  返回 yyyy-MM-dd HH:mm
*/
+(NSString *)tfy_timeWithStr:(NSString *)str{
    long long time=[str longLongValue];
    
    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:time/1000.0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString*timeString=[formatter stringFromDate:d];
    return timeString;
}
/**
*   给的是分  返回 HH:mm
*/
+(NSString *)tfy_logTimeWithStr:(NSString *)str{
    long long time=[str longLongValue];
    
    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:time/1000];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"HH:mm"];
    
    NSString*timeString=[formatter stringFromDate:d];
    return timeString;
}
/**
*   给的是毫秒  返回 MM.dd
*/
+ (NSString *)tfy_secondsStringToDate:(NSString *)string{
    //给的是秒
    //NSTimeInterval time = [string doubleValue] + 28800;//因为时差问题要加8小时 == 28800 sec
    NSTimeInterval time = [string doubleValue]/1000;
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM.dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
    return currentDateStr;
}
/**
 移除结尾的子字符串, 可以输入多个
 */
- (NSString *)tfy_removeLastSubStrings:(NSString *)string, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray *tempArr = @[].mutableCopy;
    if (string) {
        // 取出第一个参数
        [tempArr addObject:string];
        // 定义一个指向个数可变的参数列表指针；
        va_list args;
        // 用于存放取出的参数
        NSString *arg;
        // 初始化变量刚定义的va_list变量，这个宏的第二个参数是第一个可变参数的前一个参数，是一个固定的参数
        va_start(args, string);
        // 遍历全部参数 va_arg返回可变的参数(a_arg的第二个参数是你要返回的参数的类型)
        while ((arg = va_arg(args, NSString *))) {
            [tempArr addObject:arg];
        }
        // 清空参数列表，并置参数指针args无效
        va_end(args);
    }
    
    return [self tfy_removeLastSubStringsArray:tempArr];
}

/**
 移除结尾的子字符串, 使用数组传递多个
 */
- (NSString *)tfy_removeLastSubStringsArray:(NSArray<NSString *> *)strings {
    NSString *result = self;
    BOOL isHaveSubString = NO;
    for (int i = 0; i < strings.count; i++) {
        NSString *subString = strings[i];
        if ([result hasSuffix:subString]) {
            result = [result tfy_removeLastSubString:subString];
            isHaveSubString = YES;
        }
    }
    if (isHaveSubString) {
        result = [result tfy_removeLastSubStringsArray:strings];
    }
    return result;
}

/**
 移除结尾的子字符串
 */
- (NSString *)tfy_removeLastSubString:(NSString *)string
{
    NSString *result = self;
    if ([result hasSuffix:string]) {
        result = [result substringToIndex:self.length - string.length];
        result = [result tfy_removeLastSubString:string];
    }
    return result;
}
/**
 * 判断当前的字符串是不是url
 */
- (BOOL)tfy_isUrl{
    if(self == nil) {
        return NO;
    }
    NSString *url;
    if (self.length>4 && [[self substringToIndex:4] isEqualToString:@"www."]) {
        url = [NSString stringWithFormat:@"http://%@",self];
    }else{
        url = self;
    }
    NSString *urlRegex = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    return [urlTest evaluateWithObject:url];
}

#pragma mark ----两个数相加-----------

+(NSString *)tfy_calculateByadding:(NSString *)number1 secondNumber:(NSString *)number2
{
    NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:number1];
    NSDecimalNumber *num2 = [NSDecimalNumber decimalNumberWithString:number2];
    NSDecimalNumber *addingNum = [num1 decimalNumberByAdding:num2];
    return [addingNum stringValue];
}

#pragma mark ----两个数相减------------ number1 - number2
+(NSString *)tfy_calculateBySubtractingMinuend:(NSString *)number1 subtractorNumber:(NSString *)number2
{
    NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:number1];
    NSDecimalNumber *num2 = [NSDecimalNumber decimalNumberWithString:number2];
    NSDecimalNumber *addingNum = [num1 decimalNumberBySubtracting:num2];
    return [addingNum stringValue];
    
}

#pragma mark ----两个数相乘------------
+(NSString *)tfy_calculateByMultiplying:(NSString *)number1 secondNumber:(NSString *)number2
{
    NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:number1];
    NSDecimalNumber *num2 = [NSDecimalNumber decimalNumberWithString:number2];
    NSDecimalNumber *multiplyingNum = [num1 decimalNumberByMultiplyingBy:num2];
    return [multiplyingNum stringValue];
    
}

#pragma mark ----两个数相除------------
+ (NSString *)tfy_calculateByDividingNumber:(NSString *)number1 secondNumber:(NSString *)number2
{
    NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:number1];
    NSDecimalNumber *num2 = [NSDecimalNumber decimalNumberWithString:number2];
    NSDecimalNumber *dividingNum = [num1 decimalNumberByDividingBy:num2];
    return [dividingNum stringValue];
    
}

#pragma mark ----四舍五入------------
+ (NSString *)tfy_calculateTargetNumber:(NSString *)targetNumber ByRounding:(NSUInteger)scale
{
    NSDecimalNumberHandler * handler = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundPlain scale:scale raiseOnExactness:NO raiseOnOverflow:YES raiseOnUnderflow:YES raiseOnDivideByZero:YES];
    NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:targetNumber];
    NSDecimalNumber *roundingNum = [num1 decimalNumberByRoundingAccordingToBehavior:handler];
    return [roundingNum stringValue];
}


#pragma mark ----是否相等------------
+ (BOOL)tfy_calculateIsEqualNumber:(NSString *)number1 secondNumber:(NSString *)number2
{
    NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:number1];
    NSDecimalNumber *num2 = [NSDecimalNumber decimalNumberWithString:number2];
    NSComparisonResult result = [num1 compare:num2];
    if (result == NSOrderedSame) {
        return YES;
    }
    return NO;
}

#pragma mark ----是否大于------------
+ (BOOL)tfy_calculateNumber: (NSString *)number1 IsGreaterThan:(NSString *)number2
{
    NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:number1];
    NSDecimalNumber *num2 = [NSDecimalNumber decimalNumberWithString:number2];
    NSComparisonResult result = [num1 compare:num2];
    if (result == NSOrderedDescending) {
        return YES;
    }
    return NO;
    
}

#pragma mark ----是否小于------------
+ (BOOL)tfy_calculateNumber:(NSString *)number1  IsLessThan:(NSString *)number2
{
    NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:number1];
    NSDecimalNumber *num2 = [NSDecimalNumber decimalNumberWithString:number2];
    NSComparisonResult result = [num1 compare:num2];
    if (result == NSOrderedAscending) {
        return YES;
    }
    return NO;
    
}
#pragma mark --10指数运算--------
+(NSString *)tfy_calculateTargetNumber:(NSString *)number1 ByRonding:(short)power
{
    NSDecimalNumber * balanceNumber = [[NSDecimalNumber alloc]initWithString:number1];
    
    NSDecimalNumber * ehNumber = [balanceNumber decimalNumberByMultiplyingByPowerOf10:-power];
    
    return [ehNumber stringValue];
}


#pragma mark ---------单纯保留小数位数----------
+(NSString *)tfy_calculateRetainedDecimalNumber:(NSString *)targetNumber ByRonding:(short)power
{
    NSDecimalNumber * balanceNumber = [[NSDecimalNumber alloc]initWithString:targetNumber];
    NSDecimalNumberHandler * hander = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:4 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSNumber *changeNumber = [balanceNumber decimalNumberByRoundingAccordingToBehavior:hander];
    
    return [changeNumber stringValue];
    
}

#pragma mark - NSAttributedString
- (NSAttributedString *)tfy_attributedStringWithLineSpace:(CGFloat)lineSpace {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;
    NSRange range = NSMakeRange(0, self.length);
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    return attributedString;
}

///拼音 ->pinyin
- (NSString*)tfy_transformToPinyin{
    NSMutableString *mutableString=[NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)mutableString,NULL,kCFStringTransformToLatin,false);
    mutableString = (NSMutableString*)[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    mutableString = [[mutableString stringByReplacingOccurrencesOfString:@" " withString:@""] mutableCopy];
    return mutableString.lowercaseString;
}

///拼音首字母 -> py
- (NSString *)tfy_transformToPinyinFirstLetter{
    NSMutableString *stringM = [NSMutableString string];
    NSString *temp  =  nil;
    for(int i =0; i < [self length]; i++){
        temp = [self substringWithRange:NSMakeRange(i, 1)];
        NSMutableString *mutableString=[NSMutableString stringWithString:temp];
        CFStringTransform((CFMutableStringRef)mutableString,NULL,kCFStringTransformToLatin,false);
        mutableString = (NSMutableString*)[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
        mutableString =  [[mutableString substringToIndex:1] mutableCopy];
        [stringM appendString:(NSString *)mutableString];
    }
    return stringM.lowercaseString;
}

+ (NSString *)tfy_covert:(NSUInteger)num{
    NSString *numStr = [NSString stringWithFormat:@"%lu",(unsigned long)num];
    NSString *resultStr = @"";
    for (int i=0; i<[numStr length]; ++i) {
        NSString *tempStr = [numStr substringWithRange:NSMakeRange(i, 1)];
        resultStr  = [resultStr stringByAppendingString:[self tfy_numberTransformWord:[tempStr integerValue]]];
    }
    
    if (num/10 == 1) {
        if ([[resultStr substringToIndex:1] isEqualToString:@"一"] ) {
            if ([[resultStr substringToIndex:2] isEqualToString:@"一零"]) {
                resultStr = @"十";
            } else {
                resultStr = [NSString stringWithFormat:@"十%@", [resultStr substringFromIndex:1]];
            }
        }
    }
    
    NSMutableString *resultString = [[NSMutableString alloc] initWithString:resultStr];
    
    if (num/10 > 1) {
        [resultString insertString:@"十" atIndex:1];
    }else if (num/100 != 0) {
        resultString = [NSMutableString stringWithString:resultStr];
        [resultString insertString:@"百" atIndex:1];
        [resultString insertString:@"十" atIndex:3];
    }else if (num/1000 != 0) {
        resultString = [NSMutableString stringWithString:resultStr];
        [resultString insertString:@"千" atIndex:1];
        [resultString insertString:@"百" atIndex:3];
        [resultString insertString:@"十" atIndex:5];
    }
    
    return resultString;
}
+ (NSString *)tfy_numberTransformWord:(NSUInteger) num
{
    switch (num) {
        case 0:
            return @"零";
            break;
            
        case 1:
            return @"一";
            break;
            
        case 2:
            return @"二";
            break;
            
        case 3:
            return @"三";
            break;
            
        case 4:
            return @"四";
            break;
            
        case 5:
            return @"五";
            break;
            
        case 6:
            return @"六";
            break;
            
        case 7:
            return @"七";
            break;
            
        case 8:
            return @"八";
            break;
            
        case 9:
            return @"九";
            break;
            
        default:
            return nil;
            break;
    }
}

- (NSData *)tfy_utf8Data{
    NSString *string = self;
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}
/**
 *  拼接http://或者https://
 */
+ (NSString *)tfy_getCompleteWebsite:(NSString *)urlStr{
    NSString *returnUrlStr = nil;
    NSString *scheme = nil;
    
    assert(urlStr != nil);
    
    urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (urlStr != nil) && (urlStr.length != 0) ) {
        NSRange  urlRange = [urlStr rangeOfString:@"://"];
        if (urlRange.location == NSNotFound) {
            returnUrlStr = [NSString stringWithFormat:@"http://%@", urlStr];
        } else {
            scheme = [urlStr substringWithRange:NSMakeRange(0, urlRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
                || ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                returnUrlStr = urlStr;
            } else {
                //不支持的URL方案
            }
        }
    }
    return returnUrlStr;
}

+ (NSString *)tfy_getStringWithRange:(NSRange)range
{
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < range.length ; i++) {
        [string appendString:@" "];
    }
    return string;
}
/**
 * 传入时间 2020-04-09 返回 星座
 */
+(NSString *)tfy_getXingzuo:(NSDate *)in_date{
    //计算星座
    NSString *retStr=@"";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM"];
    int i_month=0;
    NSString *theMonth = [dateFormat stringFromDate:in_date];
    if([[theMonth substringToIndex:0] isEqualToString:@"0"]){
        i_month = [[theMonth substringFromIndex:1] intValue];
    }else{
        i_month = [theMonth intValue];
    }
    [dateFormat setDateFormat:@"dd"];
    int i_day=0;
    NSString *theDay = [dateFormat stringFromDate:in_date];
    if([[theDay substringToIndex:0] isEqualToString:@"0"]){
        i_day = [[theDay substringFromIndex:1] intValue];
    }else{
        i_day = [theDay intValue];
    }
    switch (i_month) {
        case 1:
            if(i_day>=20 && i_day<=31){
                retStr=@"水瓶座";
            }
            if(i_day>=1 && i_day<=19){
                retStr=@"摩羯座";
            }
            break;
        case 2:
            if(i_day>=1 && i_day<=18){
                retStr=@"水瓶座";
            }
            if(i_day>=19 && i_day<=31){
                retStr=@"双鱼座";
            }
            break;
        case 3:
            if(i_day>=1 && i_day<=20){
                retStr=@"双鱼座";
            }
            if(i_day>=21 && i_day<=31){
                retStr=@"白羊座";
            }
            break;
        case 4:
            if(i_day>=1 && i_day<=19){
                retStr=@"白羊座";
            }
            if(i_day>=20 && i_day<=31){
                retStr=@"金牛座";
            }
            break;
        case 5:
            if(i_day>=1 && i_day<=20){
                retStr=@"金牛座";
            }
            if(i_day>=21 && i_day<=31){
                retStr=@"双子座";
            }
            break;
        case 6:
            if(i_day>=1 && i_day<=21){
                retStr=@"双子座";
            }
            if(i_day>=22 && i_day<=31){
                retStr=@"巨蟹座";
            }
            break;
        case 7:
            if(i_day>=1 && i_day<=22){
                retStr=@"巨蟹座";
            }
            if(i_day>=23 && i_day<=31){
                retStr=@"狮子座";
            }
            break;
        case 8:
            if(i_day>=1 && i_day<=22){
                retStr=@"狮子座";
            }
            if(i_day>=23 && i_day<=31){
                retStr=@"处女座";
            }
            break;
        case 9:
            if(i_day>=1 && i_day<=22){
                retStr=@"处女座";
            }
            if(i_day>=23 && i_day<=31){
                retStr=@"天秤座";
            }
            break;
        case 10:
            if(i_day>=1 && i_day<=23){
                retStr=@"天秤座";
            }
            if(i_day>=24 && i_day<=31){
                retStr=@"天蝎座";
            }
            break;
        case 11:
            if(i_day>=1 && i_day<=21){
                retStr=@"天蝎座";
            }
            if(i_day>=22 && i_day<=31){
                retStr=@"射手座";
            }
            break;
        case 12:
            if(i_day>=1 && i_day<=21){
                retStr=@"射手座";
            }
            if(i_day>=21 && i_day<=31){
                retStr=@"摩羯座";
            }
            break;
    }
    return retStr;
}


@end
