//
//  NSNumber+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TFY_OPERATORS){
    TFY_Add,//加
    TFY_Mul,//乘
    TFY_Sub,//减
    TFY_Div//除
};

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (TFY_Tools)

+ (nullable NSNumber *)tfy_numberWithString:(NSString *)string;

//无格式,四舍五入
- (NSString *)tfy_changeToumberFormatterNoStyle;
//小数型,
- (NSString *)tfy_changeToNumberFormatterDecimalStyle;
//货币型,
- (NSString *)tfy_changeToNumberFormatterCurrencyStyle;
//百分比型
- (NSString *)tfy_changeToNumberFormatterPercentStyle;
//科学计数型,
- (NSString *)tfy_changeToNumberFormatterScientificStyle;
//全拼
- (NSString *)tfy_changeToNumberFormatterSpellOutStyle;

/// 运算方法
/// one 第一个数
/// opera 运算方式
/// two 第二个数
+ (NSNumber *)tfy_getResult:(NSNumber *)one operators:(TFY_OPERATORS)opera num:(NSNumber *)two;


@end

NS_ASSUME_NONNULL_END
