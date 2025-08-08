//
//  UITextView+Placeholder.h
//  shore
//
//  Created by 田风有 on 2023/4/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^textViewHeightDidChangedBlock)(CGFloat currentTextViewHeight);

@interface UITextView (Placeholder)

@property (nonatomic, readonly) UITextView *tfy_placeholderTextView NS_SWIFT_NAME(placeholderTextView);
/* 占位文字 */
@property (nonatomic, strong) IBInspectable NSString *tfy_placeholder;

@property (nonatomic, strong) NSAttributedString *tfy_attributedPlaceholder;
/* 占位文字颜色 */
@property (nonatomic, strong) IBInspectable UIColor *tfy_placeholderColor;

/* 最大高度，如果需要随文字改变高度的时候使用 */
@property (nonatomic, assign) CGFloat tfy_maxHeight;
/* 最小高度，如果需要随文字改变高度的时候使用 */
@property (nonatomic, assign) CGFloat tfy_minHeight;

@property (nonatomic, copy) textViewHeightDidChangedBlock tfy_textViewHeightDidChanged;

+ (UIColor *)tfy_defaultPlaceholderColor;

/* 获取图片数组 */
- (NSArray *)tfy_getImages;

/* 自动高度的方法，maxHeight：最大高度 */
- (void)tfy_autoHeightWithMaxHeight:(CGFloat)maxHeight;

/* 自动高度的方法，maxHeight：最大高度， textHeightDidChanged：高度改变的时候调用 */
- (void)tfy_autoHeightWithMaxHeight:(CGFloat)maxHeight textViewHeightDidChanged:(_Nullable textViewHeightDidChangedBlock)textViewHeightDidChanged;

/* 添加一张图片 image:要添加的图片 */
- (void)tfy_addImage:(UIImage *)image;

/* 添加一张图片 image:要添加的图片 size:图片大小 */
- (void)tfy_addImage:(UIImage *)image size:(CGSize)size;

/* 插入一张图片 image:要添加的图片 size:图片大小 index:插入的位置 */
- (void)tfy_insertImage:(UIImage *)image size:(CGSize)size index:(NSInteger)index;

/* 添加一张图片 image:要添加的图片 multiple:放大／缩小的倍数 */
- (void)tfy_addImage:(UIImage *)image multiple:(CGFloat)multiple;

/* 插入一张图片 image:要添加的图片 multiple:放大／缩小的倍数 index:插入的位置 */
- (void)tfy_insertImage:(UIImage *)image multiple:(CGFloat)multiple index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
