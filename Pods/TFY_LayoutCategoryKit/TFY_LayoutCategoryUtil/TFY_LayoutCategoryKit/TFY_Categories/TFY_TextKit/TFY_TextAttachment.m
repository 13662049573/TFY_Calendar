//
//  TFY_TextAttachment.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/4/1.
//  Copyright © 2022 田风有. All rights reserved.
//

#import "TFY_TextAttachment.h"
#import "NSMutableAttributedString+TFY_Tools.h"
#import "NSAttributedString+TFY_Tools.h"
#import <pthread.h>

#define AssertMainThread() NSAssert(0 != pthread_main_np(), @"This method must be called on the main thread!")

@interface TFY_TextAttachment ()
@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign) CGPoint position;
@end

@implementation TFY_TextAttachment
@dynamic image;

- (void)setSize:(CGSize)size {
    _size = size;
    self.bounds = CGRectMake(0, _baseline, _size.width, _size.height);
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    _size = bounds.size;
}

- (void)setBaseline:(CGFloat)baseline {
    _baseline = baseline;
    self.bounds = CGRectMake(0, _baseline, _size.width, _size.height);
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    if (_size.width == 0 && _size.height == 0 ) {
        self.size = image.size;
    }
}

- (void)setView:(UIView *)view {
    _view = view;
    if (_size.width == 0 && _size.height == 0 ) {
        self.size = view.frame.size;
    }
}

#pragma mark - NSTextAttachmentContainer

- (nullable UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(nullable NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    _position = CGPointMake(imageBounds.origin.x, imageBounds.origin.y - _size.height);
    return self.image;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    if (_verticalAlignment == AttachmentAlignmentBaseline || self.bounds.origin.y > 0) {
        return self.bounds;
    }
    CGFloat offset = 0;
    // TO DO: textStorage not thread safe
    UIFont *font = [textContainer.layoutManager.textStorage tfy_fontAtIndex:charIndex effectiveRange:nil];
    if (!font) {
        return self.bounds;
    }
    switch (_verticalAlignment) {
        case AttachmentAlignmentCenter:
            offset = (_size.height-font.capHeight)/2;
            break;
        case AttachmentAlignmentBottom:
            offset = _size.height-font.capHeight;
        default:
            break;
    }
    return CGRectMake(0, -offset, _size.width, _size.height);
}

@end

@implementation TFY_TextAttachment (Rendering)

- (void)setFrame:(CGRect)frame {
    _view.frame = frame;
    _layer.frame = frame;
}

- (void)addToSuperView:(UIView *)superView {
    AssertMainThread();
    if (_view) {
        [superView addSubview:_view];
    }else if (_layer) {
        [superView.layer addSublayer:_layer];
    }
}

- (void)removeFromSuperView:(UIView *)superView {
    AssertMainThread();
    if (_view.superview == superView) {
        [_view removeFromSuperview];
    }
    if (_layer.superlayer == superView.layer) {
        [_layer removeFromSuperlayer];
    }
}

@end

@implementation NSAttributedString (TextAttachment)

- (NSArray<TFY_TextAttachment *> *)attachmentViews {
    NSMutableArray *array = [NSMutableArray array];
    [self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length) options:kNilOptions usingBlock:^(TFY_TextAttachment *value, NSRange subRange, BOOL *stop) {
        if (value && [value isKindOfClass:[TFY_TextAttachment class]] && (value.view || value.layer)) {
            ((TFY_TextAttachment *)value).range = subRange;
            [array addObject:value];
        }
    }];
    return array.count > 0 ? [array copy] : nil;
}

@end
