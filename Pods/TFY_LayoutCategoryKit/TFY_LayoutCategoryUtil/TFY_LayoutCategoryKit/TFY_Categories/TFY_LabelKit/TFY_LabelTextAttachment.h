//
//  TFY_LabelTextAttachment.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/10/23.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_LabelTextAttachment : NSTextAttachment

@property (readonly, nonatomic, assign) CGFloat width;
@property (readonly, nonatomic, assign) CGFloat height;

/**
 *  优先级比上面的高，以lineHeight为根据来决定高度
 *  宽度根据imageAspectRatio来定
 */
@property (readonly, nonatomic, assign) CGFloat lineHeightMultiple;

/**
 *  image.size.width/image.size.height
 */
@property (readonly, nonatomic, assign) CGFloat imageAspectRatio;

+ (instancetype)textAttachmentWithWidth:(CGFloat)width height:(CGFloat)height imageBlock:(UIImage * (^)(CGRect imageBounds,NSTextContainer *textContainer,NSUInteger charIndex,TFY_LabelTextAttachment *textAttachment))imageBlock;

+ (instancetype)textAttachmentWithLineHeightMultiple:(CGFloat)lineHeightMultiple imageBlock:(UIImage * (^)(CGRect imageBounds,NSTextContainer *textContainer,NSUInteger charIndex,TFY_LabelTextAttachment *textAttachment))imageBlock
                                    imageAspectRatio:(CGFloat)imageAspectRatio;

@end

NS_ASSUME_NONNULL_END
