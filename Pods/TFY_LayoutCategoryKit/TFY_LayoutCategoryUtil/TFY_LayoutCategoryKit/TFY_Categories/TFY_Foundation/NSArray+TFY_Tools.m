//
//  NSArray+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "NSArray+TFY_Tools.h"
#import "NSData+TFY_Data.h"
#import "NSString+TFY_String.h"

@implementation NSArray (TFY_Tools)

- (id)tfy_randomObject{
    NSInteger count = self.count;
    if (count == 0) return nil;
    return self[arc4random_uniform((u_int32_t)count)];
}

- (id)tfy_safe_objectAtIndex:(NSUInteger)index{
    return index < self.count ? self[index]:nil;
}

- (CGFloat)tfy_maxObject{
    return [[self valueForKeyPath:@"@max.self"] floatValue];
}

- (CGFloat)tfy_minObject{
    return [[self valueForKeyPath:@"@min.self"] floatValue];
}

- (CGFloat)tfy_sumObject{
    return [[self valueForKeyPath:@"@sum.self"] floatValue];
}

@end

@implementation NSArray (Plist)

+ (nullable NSArray *)tfy_arrayWithPlistData:(NSData *)plist{
    if (!plist) return nil;
    NSArray *array = [NSPropertyListSerialization propertyListWithData:plist options:NSPropertyListImmutable format:NULL error:NULL];
    if ([array isKindOfClass:[NSArray class]]) return array;
    return nil;
}

+ (nullable NSArray *)tfy_arrayWithPlistString:(NSString *)plist{
    if (!plist) return nil;
    return [self tfy_arrayWithPlistData:plist.tfy_utf8Data];
}

- (nullable NSData *)tfy_plistData{
    return [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
}
- (NSString *)tfy_plistString{
    NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListXMLFormat_v1_0 options:kNilOptions error:NULL];
    if (xmlData) return xmlData.tfy_utf8String;
    return nil;
}


- (NSString *)tfy_jsonString{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        return [NSJSONSerialization dataWithJSONObject:self options:0 error:NULL].tfy_utf8String;
    }
    return nil;
}

- (NSString *)tfy_jsonPrettyString{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        return [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:NULL].tfy_utf8String;
    }
    return nil;
}

@end

@implementation NSMutableArray (TFY_Tools)

+ (NSMutableArray *)tfy_arrayWithPlistData:(NSData *)plist {
    if (!plist) return nil;
    NSMutableArray *array = [NSPropertyListSerialization propertyListWithData:plist options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
    if ([array isKindOfClass:[NSMutableArray class]]) return array;
    return nil;
}

+ (NSMutableArray *)tfy_arrayWithPlistString:(NSString *)plist {
    if (!plist) return nil;
    NSData* data = plist.tfy_utf8Data;
    return [self tfy_arrayWithPlistData:data];
}

- (void)tfy_removeFirstObject{
    if (self.count) {
        [self removeObjectAtIndex:0];
    }
}

- (id)tfy_popLastObject{
    id obj = nil;
    if (self.count) {
        obj = self.lastObject;
        [self removeLastObject];
    }
    return obj;
}

- (id)tfy_popFirstObject{
    id obj = nil;
    if (self.count) {
        obj = self.firstObject;
        [self tfy_removeFirstObject];
    }
    return obj;
}

- (NSMutableArray <id>* _Nonnull (^)(id _Nonnull))addObjectChain{
    return ^ (id data){
        if (data) {
            [self addObject:data];
        }
        return self;
    };
}

- (NSMutableArray <id>* _Nonnull (^)(id _Nonnull))removeObjectChain{
    return ^ (id data){
        if (data) {
            [self removeObject:data];
        }
        return self;
    };
}

- (NSMutableArray <id>* _Nonnull (^)(id _Nonnull))addObjectChainPre{
    return ^ (id data){
        if (data) {
            [self insertObject:data atIndex:0];
        }
        return self;
    };
}

- (NSMutableArray <id>* _Nonnull (^)(NSArray <id> * _Nonnull))addObjectsChain{
    return ^ (id data){
        if (data) {
            [self addObjectsFromArray:data];
        }
        return self;
    };
}

- (NSMutableArray <id>* _Nonnull (^)(NSArray <id>* _Nonnull, NSUInteger))insertObjectsChainAtIndex{
    return ^ (NSArray * data, NSUInteger index){
        if (data) {
            NSUInteger i = index;
            for (id obj in data) {
                [self insertObject:obj atIndex:i++];
            }
        }
        return self;
    };
}

- (NSMutableArray <id>* _Nonnull (^)(NSArray<id> * _Nonnull))addObjectsChainPre{
    return ^ (NSArray * data){
        if (data) {
            NSUInteger i = 0;
            for (id obj in data) {
                [self insertObject:obj atIndex:i++];
            }
        }
        return self;
    };
}

- (void)tfy_reverse {
    NSUInteger count = self.count;
    int mid = floor(count / 2.0);
    for (NSUInteger i = 0; i < mid; i++) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:(count - (i + 1))];
    }
}

- (void)tfy_shuffle {
    for (NSUInteger i = self.count; i > 1; i--) {
        [self exchangeObjectAtIndex:(i - 1)
                  withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    }
}

@end
