//
//  NSDictionary+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "NSDictionary+TFY_Tools.h"
#import "NSString+TFY_String.h"
#import "NSData+TFY_Data.h"

@implementation NSDictionary (TFY_Tools)

- (NSArray <id>*)tfy_allKeysSorted{
    return [[self allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSArray <id>*)tfy_allValuesSortedByKeys{
    NSArray *sortedKeys = [self tfy_allKeysSorted];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (id key in sortedKeys) {
        [arr addObject:self[key]];
    }
    return arr;
}

- (BOOL)tfy_containsObjectForKey:(id)key{
    if (!key) return NO;
    return self[key] != nil;
}


- (NSDictionary *)tfy_entriesForKeys:(NSArray <id>*)keys{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    for (id key in keys) {
        id value = self[key];
        if (value) dic[key] = value;
    }
    return dic;
}

- (NSString *)tfy_jsonString{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
    return nil;
}

- (NSString *)tfy_jsonPrettyString{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
        return jsonData.tfy_utf8String;
    }
    return nil;
}

@end

@implementation NSDictionary (Plist)

+ (NSDictionary *)tfy_dictionaryWithPlistData:(NSData *)plist {
    if (!plist) return nil;
    NSDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:plist options:NSPropertyListImmutable format:NULL error:NULL];
    if ([dictionary isKindOfClass:[NSDictionary class]]) return dictionary;
    return nil;
}

+ (NSDictionary *)tfy_dictionaryWithPlistString:(NSString *)plist {
    if (!plist) return nil;
    NSData* data = [plist dataUsingEncoding:NSUTF8StringEncoding];
    return [self tfy_dictionaryWithPlistData:data];
}

- (NSData *)tfy_plistData {
    return [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListBinaryFormat_v1_0 options:kNilOptions error:NULL];
}

- (NSString *)tfy_plistString {
    NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListXMLFormat_v1_0 options:kNilOptions error:NULL];
    if (xmlData) return xmlData.tfy_utf8String;
    return nil;
}

/**
 *   返回字典所获取的数据
 */
+(nullable NSDictionary *)tfy_pathForResource:(nullable NSString *)name ofType:(nullable NSString *)ext{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    
    NSString *shoppingStr = [NSString stringWithContentsOfFile:path usedEncoding:nil error:nil];
    
    NSDictionary *shoppingDic = [self tfy_dictionaryWithJsonString:shoppingStr];
    
    return shoppingDic;
}

+(NSDictionary *)tfy_dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err)
    {
        return nil;
    }
    return dic;
}

/** 将Dictionary转为NSData 将字典转换成json格式字符串,不含 这些符号*/
+ (NSData *)tfy_compactFormatDataForDictionary:(NSDictionary *)dicJson {
    if (![dicJson isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicJson options:0 error:nil];
    if (![jsonData isKindOfClass:[NSData class]]) {
        return nil;
    }
    return jsonData;
}

@end


static NSNumber *NSNumberFromID(id value) {
    static NSCharacterSet *dot;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
    });
    if (!value || value == [NSNull null]) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSString *lower = ((NSString *)value).lowercaseString;
        if ([lower isEqualToString:@"true"] || [lower isEqualToString:@"yes"]) return @(YES);
        if ([lower isEqualToString:@"false"] || [lower isEqualToString:@"no"]) return @(NO);
        if ([lower isEqualToString:@"nil"] || [lower isEqualToString:@"null"] || [lower isEqualToString:@"<null>"] || [lower isEqualToString:@"(null)"]) return nil;
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            return @(((NSString *)value).doubleValue);
        } else {
            return @(((NSString *)value).longLongValue);
        }
    }
    return nil;
}

#define RETURN_VALUE(_type_)                                                     \
if (!key) return def;                                                            \
id value = self[key];                                                            \
if (!value || value == [NSNull null]) return def;                                \
if ([value isKindOfClass:[NSNumber class]]) return ((NSNumber *)value)._type_;   \
if ([value isKindOfClass:[NSString class]]) return NSNumberFromID(value)._type_; \
return def;

@implementation NSDictionary (ValueDefault)
- (BOOL)tfy_boolValueForKey:(NSString *)key default:(BOOL)def {
    RETURN_VALUE(boolValue);
}

- (char)tfy_charValueForKey:(NSString *)key default:(char)def {
    RETURN_VALUE(charValue);
}

- (unsigned char)tfy_unsignedCharValueForKey:(NSString *)key default:(unsigned char)def {
    RETURN_VALUE(unsignedCharValue);
}

- (short)tfy_shortValueForKey:(NSString *)key default:(short)def {
    RETURN_VALUE(shortValue);
}

- (unsigned short)tfy_unsignedShortValueForKey:(NSString *)key default:(unsigned short)def {
    RETURN_VALUE(unsignedShortValue);
}

- (int)tfy_intValueForKey:(NSString *)key default:(int)def {
    RETURN_VALUE(intValue);
}

- (unsigned int)tfy_unsignedIntValueForKey:(NSString *)key default:(unsigned int)def {
    RETURN_VALUE(unsignedIntValue);
}

- (long)tfy_longValueForKey:(NSString *)key default:(long)def {
    RETURN_VALUE(longValue);
}

- (unsigned long)tfy_unsignedLongValueForKey:(NSString *)key default:(unsigned long)def {
    RETURN_VALUE(unsignedLongValue);
}

- (long long)tfy_longLongValueForKey:(NSString *)key default:(long long)def {
    RETURN_VALUE(longLongValue);
}

- (unsigned long long)tfy_unsignedLongLongValueForKey:(NSString *)key default:(unsigned long long)def {
    RETURN_VALUE(unsignedLongLongValue);
}

- (float)tfy_floatValueForKey:(NSString *)key default:(float)def {
    RETURN_VALUE(floatValue);
}

- (double)tfy_doubleValueForKey:(NSString *)key default:(double)def {
    RETURN_VALUE(doubleValue);
}

- (NSInteger)tfy_integerValueForKey:(NSString *)key default:(NSInteger)def {
    RETURN_VALUE(integerValue);
}

- (NSUInteger)tfy_unsignedIntegerValueForKey:(NSString *)key default:(NSUInteger)def {
    RETURN_VALUE(unsignedIntegerValue);
}

- (NSNumber *)tfy_numberValueForKey:(NSString *)key default:(NSNumber *)def {
    if (!key) return def;
    id value = self[key];
    if (!value || value == [NSNull null]) return def;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) return NSNumberFromID(value);
    return def;
}

- (NSString *)tfy_stringValueForKey:(NSString *)key default:(NSString *)def {
    if (!key) return def;
    id value = self[key];
    if (!value || value == [NSNull null]) return def;
    if ([value isKindOfClass:[NSString class]]) return value;
    if ([value isKindOfClass:[NSNumber class]]) return ((NSNumber *)value).description;
    return def;
}
- (NSArray *)tfy_arrayValueForKey:(NSString *)key default:(NSArray *)def{
    if (!key) return def;
    id value = self[key];
    if (!value || value == [NSNull null]) return def;
    if (![value isKindOfClass:[NSArray class]]) return def;
    return value;
}
- (NSDictionary *)tfy_dicValueForKey:(NSString *)key default:(NSDictionary *)def{
    if (!key) return def;
    id value = self[key];
    if (!value || value == [NSNull null]) return def;
    if (![value isKindOfClass:[NSDictionary class]]) return def;
    return value;
}
@end
@implementation NSMutableDictionary (TFY_Category)

+ (NSMutableDictionary *)tfy_dictionaryWithPlistData:(NSData *)plist {
    if (!plist) return nil;
    NSMutableDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:plist options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
    if ([dictionary isKindOfClass:[NSMutableDictionary class]]) return dictionary;
    return nil;
}

+ (NSMutableDictionary *)tfy_dictionaryWithPlistString:(NSString *)plist {
    if (!plist) return nil;
    NSData* data = [plist dataUsingEncoding:NSUTF8StringEncoding];
    return [self tfy_dictionaryWithPlistData:data];
}

- (id)tfy_popObjectForKey:(id)aKey {
    if (!aKey) return nil;
    id value = self[aKey];
    [self removeObjectForKey:aKey];
    return value;
}

- (NSDictionary *)tfy_popEntriesForKeys:(NSArray *)keys {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    for (id key in keys) {
        id value = self[key];
        if (value) {
            [self removeObjectForKey:key];
            dic[key] = value;
        }
    }
    return dic;
}

- (NSMutableDictionary <id, id>* _Nonnull (^)(id _Nonnull, id _Nonnull))addValueForKey{
    return ^ (id value, id key){
        if (key) {
            [self setValue:value forKey:key];
        }
        return self;
    };
}

- (NSMutableDictionary <id, id>* _Nonnull (^)(id _Nonnull, id _Nonnull, id _Nonnull))addValueForKeyWithDefault{
    return ^ (id value, id key, id defaultValue){
        if (key) {
            if (!value && defaultValue) {
                value = defaultValue;
            }
            [self setValue:value forKey:key];
        }
        return self;
    };
}

- (NSMutableDictionary <id, id>* _Nonnull (^)(id _Nonnull))removeValueForKey{
    return ^ (id key){
        if (key) {
            [self removeObjectForKey:key];
        }
        return self;
    };
}

@end
