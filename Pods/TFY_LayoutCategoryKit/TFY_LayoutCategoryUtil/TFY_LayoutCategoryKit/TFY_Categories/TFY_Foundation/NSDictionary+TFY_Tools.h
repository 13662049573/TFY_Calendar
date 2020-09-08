//
//  NSDictionary+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<__covariant KeyType, __covariant ObjectType> (TFY_Tools)
/**
 升序排列所有keys
 
 */
- (NSArray <KeyType>*)tfy_allKeysSorted;

/**
 升序排列所有keys
 @return 所有value
 */
- (NSArray <ObjectType>*)tfy_allValuesSortedByKeys;

- (BOOL)tfy_containsObjectForKey:(KeyType)key;

/**
 查找字典中包含的key并返回字典
 */
- (NSDictionary *)tfy_entriesForKeys:(NSArray <KeyType>*)keys;

/**
 json字符串
 */
- (NSString *)tfy_jsonString;

/**
 更具可读性的json字符串
 */
- (NSString *)tfy_jsonPrettyString;
@end
@interface NSDictionary <KeyType, ObjectType> (Plist)

+ (nullable NSDictionary <KeyType ,ObjectType>*)tfy_dictionaryWithPlistData:(NSData *)plist;

+ (nullable NSDictionary <KeyType ,ObjectType>*)tfy_dictionaryWithPlistString:(NSString *)plist;

+ (nullable NSDictionary *)tfy_pathForResource:(nullable NSString *)name ofType:(nullable NSString *)ext;

- (nullable NSData *)tfy_plistData;

- (nullable NSString *)tfy_plistString;

@end

@interface NSDictionary (ValueDefault)

- (BOOL)tfy_boolValueForKey:(NSString *)key default:(BOOL)def;

- (char)tfy_charValueForKey:(NSString *)key default:(char)def;
- (unsigned char)tfy_unsignedCharValueForKey:(NSString *)key default:(unsigned char)def;

- (short)tfy_shortValueForKey:(NSString *)key default:(short)def;
- (unsigned short)tfy_unsignedShortValueForKey:(NSString *)key default:(unsigned short)def;

- (int)tfy_intValueForKey:(NSString *)key default:(int)def;
- (unsigned int)tfy_unsignedIntValueForKey:(NSString *)key default:(unsigned int)def;

- (long)tfy_longValueForKey:(NSString *)key default:(long)def;
- (unsigned long)tfy_unsignedLongValueForKey:(NSString *)key default:(unsigned long)def;

- (long long)tfy_longLongValueForKey:(NSString *)key default:(long long)def;
- (unsigned long long)tfy_unsignedLongLongValueForKey:(NSString *)key default:(unsigned long long)def;

- (float)tfy_floatValueForKey:(NSString *)key default:(float)def;
- (double)tfy_doubleValueForKey:(NSString *)key default:(double)def;

- (NSInteger)tfy_integerValueForKey:(NSString *)key default:(NSInteger)def;
- (NSUInteger)tfy_unsignedIntegerValueForKey:(NSString *)key default:(NSUInteger)def;

- (nullable NSNumber *)tfy_numberValueForKey:(NSString *)key default:(nullable NSNumber *)def;
- (nullable NSString *)tfy_stringValueForKey:(NSString *)key default:(nullable NSString *)def;

- (NSArray *)tfy_arrayValueForKey:(NSString *)key default:(nullable NSArray *)def;
- (NSDictionary *)tfy_dicValueForKey:(NSString *)key default:(nullable NSDictionary *)def;

@end
#define TFY_MUTABLEDICTION_PROPERTY @property (nonatomic, strong, readonly) NSMutableDictionary <KeyType, ObjectType> *

@interface NSMutableDictionary <KeyType, ObjectType> (TFY_Category)

+ (nullable NSMutableDictionary <KeyType ,ObjectType>*)tfy_dictionaryWithPlistData:(NSData *)plist;

+ (nullable NSMutableDictionary <KeyType ,ObjectType>*)tfy_dictionaryWithPlistString:(NSString *)plist;

- (nullable ObjectType)tfy_popObjectForKey:(KeyType)aKey;

- (NSDictionary <KeyType, ObjectType>*)tfy_popEntriesForKeys:(NSArray <KeyType>*)keys;

TFY_MUTABLEDICTION_PROPERTY ( ^ addValueForKey)(ObjectType object, KeyType key);

TFY_MUTABLEDICTION_PROPERTY ( ^ addValueForKeyWithDefault)(ObjectType value, KeyType key, ObjectType defaultValue);

TFY_MUTABLEDICTION_PROPERTY ( ^ removeValueForKey)(KeyType key);

@end
NS_ASSUME_NONNULL_END
