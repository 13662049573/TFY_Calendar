//
//  NSString+Extend.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/1/12.
//  Copyright © 2023 田风有. All rights reserved.
//

/** 使用方式
 - (void)searchKeyChange:(NSNotification *)noti
 {
     UITextField * tf = noti.object;
     NSString *title2 = str;
     NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithString:title2];
     if (tf.text && tf.text.length > 0) {
         TFY_SearchStringManager * ssm = [TFY_SearchStringManager sharedSearchStringManager];
         ssm.searchStr = tf.text;
         ssm.sourceStr = str;
         NSArray <NSValue *> * ranges = [ssm matching];
         for (NSValue * v in ranges) {
             NSRange range = [v rangeValue];
             [att addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:253 / 255.0 green:100 / 255.0 blue:85 / 255.0 alpha:1] range:range];
         }
     }
     self.textLabel.attributedText = att;
 }
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^searchDictBlock)(NSDictionary<NSNumber *,NSMutableArray *>  *,BOOL isJustChinese);

@interface NSString (Extend)
- (NSArray *)getAllRangeOfString:(NSString *)searchString;
+ (NSString *)transform:(NSString *)chinese;
+ (NSString *)changeChineseToPinYin:(NSString *)str block:(searchDictBlock)dictBlock;
+ (NSString *)changeChineseToPinYinFirstLetter:(NSString *)str;
+ (BOOL)IsChineseForString:(NSString *)string;
@end

@interface TFY_SearchStringManager : NSObject
+ (instancetype)sharedSearchStringManager;
@property (nonatomic, strong) NSString * searchStr;
@property (nonatomic, strong) NSString * sourceStr;
- (NSMutableArray <NSValue *> *)matching;
@end

NS_ASSUME_NONNULL_END
