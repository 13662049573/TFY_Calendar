//
//  TFY_ExpressionManager.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/10/23.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_Expression : NSObject

@property (readonly, nonatomic, copy) NSString *regex;
@property (readonly, nonatomic, copy) NSString *plistName;
@property (readonly, nonatomic, copy) NSString *bundleName;

+ (instancetype)expressionWithRegex:(NSString*)regex plistName:(NSString*)plistName bundleName:(NSString*)bundleName;

@end

@interface TFY_ExpressionManager : NSObject

+ (instancetype)sharedInstance;

//获取对应的表情attrStr
+ (NSAttributedString*)expressionAttributedStringWithString:(id)string expression:(TFY_Expression*)expression;
//给一个str数组，返回其对应的表情attrStr数组，顺序一致
+ (NSArray *)expressionAttributedStringsWithStrings:(NSArray*)strings expression:(TFY_Expression*)expression;
//同上，但是以回调方式返回
+ (void)expressionAttributedStringsWithStrings:(NSArray*)strings expression:(TFY_Expression*)expression callback:(void(^)(NSArray *result))callback;

@end

NS_ASSUME_NONNULL_END
