//
//  TFY_AlertHUD.h
//  TFY_ProgressHUD
//
//  Created by 田风有 on 2023/7/22.
//  Copyright © 2023 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFY_ProgressHUD.h"
#import "TFY_PopupMenu.h"

#define TFYAlert [TFY_AlertHUD shareInstance]

NS_ASSUME_NONNULL_BEGIN

@interface TFY_AlertHUD : NSObject

+ (TFY_AlertHUD *)shareInstance;

/** 菊花 */
- (void)showIndeterminate;
- (void)showIndeterminateWithStatus:(nullable NSString *)status;

/** 成功 */
- (void)showSuccessWithStatus:(nullable NSString *)status;
/** 失败 */
- (void)showErrorWithStatus:(nullable NSString *)status;
- (void)showErrorWithError:(nullable NSError *)error;
/** 警告 */
- (void)showInfoWithStatus:(nullable NSString *)status;

/** 文字提示 */
- (void)showStatus:(nullable NSString *)status;
- (void)showRedStatus:(nullable NSString *)status;

/** 进度条 */
- (void)showBarDeterminateWithProgress:(CGFloat)progress;
- (void)showBarDeterminateWithProgress:(CGFloat)progress status:(nullable NSString *)status;
/**圆形进度条**/
- (void)showRoundDeterminateWithProgress:(CGFloat)progress;
- (void)showRoundDeterminateWithProgress:(CGFloat)progress status:(nullable NSString *)status;
/**自定义进度条**/
- (void)showWithProgress:(CGFloat)progress Mode:(ProgressHUDMode)mode status:(nullable NSString *)status;

/** 隐藏 */
- (void)hide;

@end

NS_ASSUME_NONNULL_END
