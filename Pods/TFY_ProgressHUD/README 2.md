# TFY_ProgressHUD

使用 pod 'TFY_ProgressHUD'

typedef enum : NSUInteger{
    ProgressHUDMaskTypeNone = 1,  // 当提示显示的时间，用户仍然可以做其他操作，比如View 上面的输入等
    ProgressHUDMaskTypeClear,     // 用户不可以做其他操作
    ProgressHUDMaskTypeBlack,     // 用户不可以做其他操作，并且背景色是黑色
    ProgressHUDMaskTypeGradient   // 用户不可以做其他操作，并且背景色是渐变的
}ProgressHUDMaskType;

@interface TFY_ProgressHUD : UIView
/**
 *  不带任何文字的弹出框
 */
+ (void)show;
/**
 *  提示弹框 输入文字
 */
+ (void)showWithStatus:(NSString*)status;
/**
 *  展示状态  status   显示状态  maskType 枚举类型
 */
+ (void)showWithStatus:(NSString*)status maskType:(ProgressHUDMaskType)maskType;

+ (void)showWithMaskType:(ProgressHUDMaskType)maskType;
/**
 *  展示成功的状态  string 传字符串
 */
+ (void)showSuccessWithStatus:(NSString*)string;
/**
 *  展示成功的状态 string   传字符串  duration 设定显示时间
 */
+ (void)showSuccessWithStatus:(NSString *)string duration:(NSTimeInterval)duration;
/**
 *  展示失败的状态 string 字符串
 */
+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showErrorWithStatus:(NSString *)string duration:(NSTimeInterval)duration;
/**
 *  展示提示信息  string 字符串
 */
+ (void)showPromptWithStatus:(NSString *)string;
+ (void)showPromptWithStatus:(NSString *)string duration:(NSTimeInterval)duration;
/**
 *  在显示时更改HUD的加载状态。
 */
+ (void)setStatus:(NSString*)string;
/**
 *  简单地用淡出+缩放动画来解散HUD。
 */
+ (void)dismiss;
/**
 *  显示成功图标图像
 */
+ (void)dismissWithSuccess:(NSString*)successString;
+ (void)dismissWithSuccess:(NSString*)successString afterDelay:(NSTimeInterval)seconds;
/**
 *  显示错误图标图像。
 */
+ (void)dismissWithError:(NSString*)errorString;
+ (void)dismissWithError:(NSString*)errorString afterDelay:(NSTimeInterval)seconds;
+ (void)dismissWithPrompt:(NSString *)promptString;
+ (void)dismissWithPrompt:(NSString *)promptString afterDelay:(NSTimeInterval)seconds;

+ (BOOL)isVisible;

+ (TFY_ProgressHUD*)sharedView ;

- (void)dismissWithNoAni;
