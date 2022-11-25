//
//  TFY_TextAttachment.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/4/1.
//  Copyright © 2022 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AttachmentAlignment) {
    AttachmentAlignmentBaseline,
    AttachmentAlignmentCenter,
    AttachmentAlignmentBottom
};

NS_ASSUME_NONNULL_BEGIN

@interface TFY_TextAttachment : NSTextAttachment

@property (nonatomic, strong, nullable) UIView *view;
@property (nonatomic, strong, nullable) CALayer *layer;

@property (nonatomic,assign) CGSize size;

/**
 文本附件基线偏移量
 */
@property (nonatomic,assign) CGFloat baseline;

/**
 附件垂直对齐
 */
@property (nonatomic,assign) AttachmentAlignment verticalAlignment;

@end

@interface TFY_TextAttachment (Rendering)

// 范围在属性，渲染后将有值
@property (nonatomic, assign, readonly) NSRange range;
// 附加渲染位置，渲染后将有值
@property (nonatomic, assign, readonly) CGPoint position;

/**
 如果有视图或层，设置框架
 */
- (void)setFrame:(CGRect)frame;
- (void)addToSuperView:(UIView *)superView;
- (void)removeFromSuperView:(UIView *)superView;

@end


@interface NSAttributedString (TextAttachment)

- (NSArray<TFY_TextAttachment *> *__nullable)attachmentViews;

@end

NS_ASSUME_NONNULL_END
