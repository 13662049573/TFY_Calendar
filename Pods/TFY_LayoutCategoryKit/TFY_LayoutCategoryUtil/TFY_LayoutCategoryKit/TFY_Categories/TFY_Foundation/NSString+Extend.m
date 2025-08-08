//
//  NSString+Extend.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/1/12.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "NSString+Extend.h"

#define TFY_S __weak typeof(self) weakSelf = self;

@implementation NSString (Extend)

- (NSArray *)getAllRangeOfString:(NSString *)searchString
{
    if (self.length <= 0 || !searchString || searchString.length <= 0) {
        return nil;
    }
    NSMutableArray * arr = [NSMutableArray array];
    NSString * newStr = [self copy];
    NSRange range = [newStr rangeOfString:searchString];
    [arr addObject:[NSValue valueWithRange:range]];
    while (range.location != NSNotFound) {
        NSInteger start = range.location + range.length;
        if (start >= self.length) {
            break;
        }
        newStr = [self substringFromIndex:start];
        range = [newStr rangeOfString:searchString];
        range.location += start;
        [arr addObject:[NSValue valueWithRange:range]];
        
    }
    return arr;
}


+ (NSString *)transform:(NSString *)chinese
{
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    return pinyin;
}

+ (NSString *)changeChineseToPinYin:(NSString *)str block:(searchDictBlock)dictBlock
{
    if (str && str.length > 0 ) {
        //首先去掉空格
        NSCharacterSet * ignoreSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        //去掉字符串中的所有特殊符号
        NSArray * strList = [str componentsSeparatedByCharactersInSet:ignoreSet];
        NSMutableString *trimmedString = [NSMutableString string];
        for (NSString * tmpStr in strList) {
            [trimmedString appendString:tmpStr];
        }
        
        NSMutableDictionary <NSNumber *,NSMutableArray *> * PYDict = [NSMutableDictionary dictionary];
        
        NSMutableString *result = [NSMutableString  string];
        BOOL isJustChinese = YES;
        for (int i=0; i<[trimmedString length]; i++)
        {
            NSString * tmpStr = [trimmedString substringWithRange:NSMakeRange(i, 1)];
            NSString * realStr = @"";
            if ([self IsChineseForString:tmpStr]) {
                realStr = [[self transform:tmpStr] uppercaseString];
            }
            else
            {
                realStr = [tmpStr uppercaseString];
                isJustChinese = NO;
            }
            [result appendString:realStr];
            
            //数组 从后往前匹配，防止有相同的拼音
            NSRange range = [result rangeOfString:realStr options:NSBackwardsSearch];
            NSMutableArray * indexArr = [NSMutableArray array];
            for (NSUInteger j = range.location; j < range.location + range.length; j ++) {
                [indexArr addObject:@(j)];
            }
            [PYDict setObject:indexArr forKey:@(i)];
        }
        
        if (dictBlock) {
            dictBlock(PYDict,isJustChinese);
        }
        return result;
    }
    return nil;
}


+ (NSString *)changeChineseToPinYinFirstLetter:(NSString *)str
{
    if (str && str.length > 0 ) {
        
        NSMutableString *result = [NSMutableString  string];
        for (int i=0; i<[str length]; i++)
        {
            NSString * tmpStr = [str substringWithRange:NSMakeRange(i, 1)];
            if ([self IsChineseForString:tmpStr]) {
                NSString * firstLetter = [[[self transform:tmpStr] substringWithRange:NSMakeRange(0, 1)] uppercaseString];
                [result appendString:firstLetter];
            }
            else
            {
                [result appendString:[tmpStr uppercaseString]];
            }
        }
        return result;
    }
    return nil;
}

//只能穿一个字符的字符串进去
+ (BOOL)IsChineseForString:(NSString *)string
{
    int a = [string characterAtIndex:0];
    if (a < 0x9fff && a > 0x4e00)
    {
        return  YES;
    }
    return NO;
}

@end

@interface TFY_SearchStringManager ()
@property (nonatomic, strong) NSString * searchPYStr;
@property (nonatomic, strong) NSString * sourcePYStr;

@property (nonatomic, strong) NSDictionary <NSNumber *,NSMutableArray *> * searchPYDict;
@property (nonatomic, strong) NSDictionary <NSNumber *,NSMutableArray *> * sourcePYDict;


@property (nonatomic, strong) NSCache * strCache;
@property (nonatomic, strong) NSCache * dictCache;
@property (nonatomic, strong) NSCache * numberCache;

//如果搜索字符为纯中文 则不需要匹配首字母
@property (nonatomic, assign) BOOL  isMatchingFirstLetter;
@end

@implementation TFY_SearchStringManager

+ (instancetype)sharedSearchStringManager
{
    static TFY_SearchStringManager * wkssm = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wkssm = [TFY_SearchStringManager new];
        wkssm.isMatchingFirstLetter = YES;
    });
    return wkssm;
}

- (NSCache *)strCache
{
    if (!_strCache) {
        _strCache = [[NSCache alloc] init];
    }
    return _strCache;
}

- (NSCache *)dictCache
{
    if (!_dictCache) {
        _dictCache = [[NSCache alloc] init];
    }
    return _dictCache;
}

- (NSCache *)numberCache
{
    if (!_numberCache) {
        _numberCache = [[NSCache alloc] init];
    }
    return _numberCache;
}

- (void)setSourceStr:(NSString *)sourceStr
{
    if ( sourceStr != nil && sourceStr.length > 0 && ![_sourceStr isEqualToString:sourceStr]) {
        _sourceStr = sourceStr;
        
        
        NSString * cacheSourcePYStr = [self.strCache objectForKey:_sourceStr];
        NSDictionary * cacheSourcePYDict = [self.dictCache objectForKey:_sourceStr];
        
        if (cacheSourcePYStr && cacheSourcePYDict) {
            self.sourcePYStr = cacheSourcePYStr;
            self.sourcePYDict = cacheSourcePYDict;
        }
        else
        {
            TFY_S
            self.sourcePYStr = [NSString changeChineseToPinYin:_sourceStr block:^(NSDictionary<NSNumber *,NSMutableArray *> *dict,BOOL isJustChinese) {
                weakSelf.sourcePYDict = dict;
            }];
        }
    }
}
- (void)setSearchStr:(NSString *)searchStr
{
    if ( searchStr != nil && searchStr.length > 0 && ![_searchStr isEqualToString:searchStr]) {
        _searchStr = searchStr;
        
        NSString * cacheSearchPYStr = [self.strCache objectForKey:_searchStr];
        NSDictionary * cacheSearchPYDict = [self.dictCache objectForKey:_searchStr];
        NSNumber * cacheSearchIsMattingFirstLetter = [self.numberCache objectForKey:_searchStr];
        if (cacheSearchPYStr && cacheSearchPYDict && cacheSearchIsMattingFirstLetter) {
            self.searchPYStr = cacheSearchPYStr;
            self.searchPYDict = cacheSearchPYDict;
            self.isMatchingFirstLetter = [cacheSearchIsMattingFirstLetter boolValue];
        }
        else
        {
            TFY_S
            self.searchPYStr = [NSString changeChineseToPinYin:_searchStr block:^(NSDictionary<NSNumber *,NSMutableArray *> *dict,BOOL isJustChinese) {
                weakSelf.searchPYDict = dict;
                weakSelf.isMatchingFirstLetter = !isJustChinese;
            }];
        }
    
    }
}

- (void)setSourcePYStr:(NSString *)sourcePYStr
{
    _sourcePYStr = sourcePYStr;
    [self.strCache setObject:_sourcePYStr forKey:_sourceStr];
}

-(void)setSearchPYStr:(NSString *)searchPYStr
{
    _searchPYStr = searchPYStr;
    [self.strCache setObject:_searchPYStr forKey:_searchStr];
}

- (void)setSearchPYDict:(NSDictionary<NSNumber *,NSMutableArray *> *)searchPYDict
{
    _searchPYDict = searchPYDict;
    [self.dictCache setObject:_searchPYDict forKey:_searchStr];
}

- (void)setSourcePYDict:(NSDictionary<NSNumber *,NSMutableArray *> *)sourcePYDict
{
    _sourcePYDict = sourcePYDict;
    [self.dictCache setObject:_sourcePYDict forKey:_sourceStr];
}

- (void)setIsMatchingFirstLetter:(BOOL)isMatchingFirstLetter
{
    _isMatchingFirstLetter = isMatchingFirstLetter;
    [self.numberCache setObject:@(isMatchingFirstLetter) forKey:_searchStr];
}

- (NSMutableArray <NSValue *> *)matching
{
    //拼音rangge
    NSArray <NSValue *> * AllPYRange =  [self.sourcePYStr getAllRangeOfString:self.searchPYStr];
    NSMutableArray <NSValue *> * RealAllPYRange = [NSMutableArray array];
    for (NSValue * rangeValue in AllPYRange) {
        NSRange PYRange = [rangeValue rangeValue];
        NSMutableArray * numbers = [NSMutableArray array];
        //把rangge转为数字数组
        for (NSUInteger j = PYRange.location; j < PYRange.location + PYRange.length; j ++) {
            [numbers addObject:@(j)];
        }
        NSMutableSet * sourcePYDictRangeKeys = [NSMutableSet set];
        for (NSNumber * key in [self.sourcePYDict allKeys]) {
            NSMutableArray * values = [self.sourcePYDict objectForKey:key];
            for (NSNumber * tmpB in numbers) {
                if ([values containsObject:tmpB]) {
                    [sourcePYDictRangeKeys addObject:key];
                }
            }
        }
        NSArray * realRangeArr = [sourcePYDictRangeKeys allObjects];
        realRangeArr = [realRangeArr sortedArrayUsingComparator:^NSComparisonResult(NSNumber *  _Nonnull obj1, NSNumber *  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        NSUInteger location = [[realRangeArr firstObject] unsignedIntegerValue];
        NSUInteger length = [realRangeArr count];
        NSRange realRange = NSMakeRange(location, length);
        [RealAllPYRange addObject:[NSValue valueWithRange:realRange]];
    }
    NSMutableArray * resultRangeArr = [NSMutableArray arrayWithArray:RealAllPYRange];
    if (self.isMatchingFirstLetter) {
        NSString * upLetterKey = [NSString changeChineseToPinYinFirstLetter:self.searchStr];
        NSString * upLetterTitle = [NSString changeChineseToPinYinFirstLetter:self.sourceStr];
        NSArray <NSValue *> * FirstLetterRanges = [upLetterTitle getAllRangeOfString:upLetterKey];
        [resultRangeArr addObjectsFromArray:FirstLetterRanges];
    }
    return resultRangeArr;

}


@end
