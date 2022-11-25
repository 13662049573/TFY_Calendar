//
//  TFY_TextLabel.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2022/4/1.
//  Copyright © 2022 田风有. All rights reserved.
//

#import "TFY_TextLabel.h"
#import "TFY_AsyncLayer.h"
#import <pthread.h>
#import "NSMutableAttributedString+TFY_Tools.h"
#import "NSAttributedString+TFY_Tools.h"

#define AssertMainThread() NSAssert(0 != pthread_main_np(), @"This method must be called on the main thread!")

typedef NS_ENUM(NSUInteger, LabelTouchedState) {
    LabelTouchedStateNone,
    LabelTouchedStateTapped,
    LabelTouchedStateLongPressed,
};

#define kLongPressTimerInterval 0.5
#define kLongPressTimerMoveDistance 5

@interface TFY_TextLabel ()<AsyncLayerDelegate> {
    struct {
        unsigned int didTappedTextHighlight : 1;
        unsigned int didLongPressedTextHighlight : 1;
    }_delegateFlags;
}

@property (nonatomic, strong) NSTextStorage *textStorageOnRender;
@property (nonatomic, strong) TFY_TextRender *textRenderOnDisplay;

@property (nonatomic, strong) NSArray *attachments;

@property (nonatomic, assign) NSRange highlightRange;
@property (nonatomic, strong) TFY_TextHighlight *textHighlight;

@property (nonatomic, strong) NSTimer *longPressTimer;
@property (nonatomic, assign) NSUInteger longPressTimerCount;

@property (nonatomic, assign) LabelTouchedState touchState;
@property (nonatomic, assign) CGPoint beginTouchPiont;


@end

@implementation TFY_TextLabel

+ (Class)layerClass {
    return [TFY_AsyncLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureLabel];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureLabel];
    }
    return self;
}

#pragma mark - Configure

- (void)configureLabel {
    _longPressDuring = 2.0;
    _clearContentBeforeAsyncDisplay = YES;
    _ignoreAboveAtrributedRelatePropertys = YES;
    _ignoreAboveRenderRelatePropertys = YES;
    _numberOfLines = 0;
    _lineBreakMode = NSLineBreakByTruncatingTail;
    _verticalAlignment = TextVerticalAlignmentCenter;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.layer.contentsScale = tfy_text_screen_scale();
    ((TFY_AsyncLayer *)self.layer).asyncDelegate = self;
}

- (void)configureTextAttribute {
    if (_ignoreAboveAtrributedRelatePropertys && !_text) {
        return;
    }
    _textAlignment = [[[UIDevice currentDevice] systemVersion] floatValue] >= 9 ?NSTextAlignmentNatural : NSTextAlignmentLeft;
}

#pragma mark - Display

- (void)setDisplayNeedUpdate {
    AssertMainThread();
    [self clearTextRender];
    [self clearLayerContent];
    [self setDisplayNeedRedraw];
}

- (void)setDisplayNeedRedraw {
    [self.layer setNeedsDisplay];
}

- (void)displayRedrawIfNeed {
    [self clearLayerContent];
    [self setDisplayNeedRedraw];
}

- (void)immediatelyDisplayRedraw {
    [(TFY_AsyncLayer *)self.layer displayImmediately];
}

- (void)clearLayerContent {
    if (_clearContentBeforeAsyncDisplay && self.displaysAsynchronously) {
        self.layer.contents = nil;
    }
}

- (void)clearTextRender {
    _textRender = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self endLongPressTimer];
    }
}

#pragma mark - Getter && Setter

- (BOOL)displaysAsynchronously {
    return ((TFY_AsyncLayer *)self.layer).displaysAsynchronously;
}

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously {
    ((TFY_AsyncLayer *)self.layer).displaysAsynchronously = displaysAsynchronously;
}

- (void)setText:(NSString *)text {
    AssertMainThread();
    _text = text;
    _textStorageOnRender = [[NSTextStorage alloc]initWithString:text];
    _attributedText = nil;
    _textStorage = nil;
    [self configureTextAttribute];
    [self setDisplayNeedUpdate];
    [self invalidateIntrinsicContentSize];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    AssertMainThread();
    _attributedText = attributedText;
    _textStorageOnRender = [[NSTextStorage alloc]initWithAttributedString:attributedText];
    _text = nil;
    [self configureTextAttribute];
    [self setDisplayNeedUpdate];
    [self invalidateIntrinsicContentSize];
}

- (void)setTextStorage:(NSTextStorage *)textStorage {
    AssertMainThread();
    _textStorage = textStorage;
    _textStorageOnRender = textStorage;
    _text = nil;
    [self configureTextAttribute];
    [self setDisplayNeedUpdate];
    [self invalidateIntrinsicContentSize];
}

- (void)setTextRender:(TFY_TextRender *)textRender {
    AssertMainThread();
    _textRender = textRender;
    _textStorageOnRender = textRender.textStorage;
    _text = nil;
    [self configureTextAttribute];
    [self clearLayerContent];
    [self setDisplayNeedRedraw];
    [self invalidateIntrinsicContentSize];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    if (_ignoreAboveAtrributedRelatePropertys && !_text) {
        return;
    }
    _textStorageOnRender.tfy_font = font;
    [self displayRedrawIfNeed];
    [self invalidateIntrinsicContentSize];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (_ignoreAboveAtrributedRelatePropertys && !_text) {
        return;
    }
    _textStorageOnRender.tfy_color = textColor;
    [self displayRedrawIfNeed];
}

- (void)setShadow:(NSShadow *)shadow {
    _shadow = shadow;
    if (_ignoreAboveAtrributedRelatePropertys && !_text) {
        return;
    }
    _textStorageOnRender.tfy_shadow = shadow;
    [self displayRedrawIfNeed];
}

- (void)setCharacterSpacing:(CGFloat)characterSpacing {
    _characterSpacing = characterSpacing;
    if (_ignoreAboveAtrributedRelatePropertys && !_text) {
        return;
    }
    _textStorageOnRender.tfy_characterSpacing = characterSpacing;
    [self displayRedrawIfNeed];
    [self invalidateIntrinsicContentSize];
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing;
    if (_ignoreAboveAtrributedRelatePropertys && !_text) {
        return;
    }
    _textStorageOnRender.tfy_lineSpacing = lineSpacing;
    [self displayRedrawIfNeed];
    [self invalidateIntrinsicContentSize];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    if (_ignoreAboveAtrributedRelatePropertys && !_text) {
        return;
    }
    _textStorageOnRender.tfy_alignment = textAlignment;
    [self displayRedrawIfNeed];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    _lineBreakMode = lineBreakMode;
    if (_ignoreAboveRenderRelatePropertys && _textRender) {
        return;
    }
    [self displayRedrawIfNeed];
    [self invalidateIntrinsicContentSize];
}

- (void)setTruncationToken:(NSAttributedString *)truncationToken {
    _truncationToken = truncationToken;
    if (_ignoreAboveRenderRelatePropertys && _textRender) {
        return;
    }
    [self displayRedrawIfNeed];
    [self invalidateIntrinsicContentSize];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    _numberOfLines = numberOfLines;
    if (_ignoreAboveRenderRelatePropertys && _textRender) {
        return;
    }
    [self displayRedrawIfNeed];
    [self invalidateIntrinsicContentSize];
}

- (void)setVerticalAlignment:(TextVerticalAlignment)verticalAlignment {
    _verticalAlignment = verticalAlignment;
    if (_ignoreAboveRenderRelatePropertys && _textRender) {
        return;
    }
    [self displayRedrawIfNeed];
}

- (void)setFrame:(CGRect)frame {
    AssertMainThread();
    CGSize oldSize = self.frame.size;
    [super setFrame:frame];
    if (!CGSizeEqualToSize(self.frame.size, oldSize)) {
        [self clearLayerContent];
        [self setDisplayNeedRedraw];
    }
}

- (void)setBounds:(CGRect)bounds {
    AssertMainThread();
    CGSize oldSize = self.bounds.size;
    [super setBounds:bounds];
    if (!CGSizeEqualToSize(self.bounds.size, oldSize)) {
        [self clearLayerContent];
        [self setDisplayNeedRedraw];
    }
}

- (void)setDelegate:(id<LabelDelegate>)delegate {
    AssertMainThread();
    _delegate = delegate;
    _delegateFlags.didTappedTextHighlight = [delegate respondsToSelector:@selector(label:didTappedTextHighlight:)];
    _delegateFlags.didLongPressedTextHighlight = [delegate respondsToSelector:@selector(label:didLongPressedTextHighlight:)];
}

#pragma mark - Layout Size

- (CGSize)sizeThatFits:(CGSize)size {
    return [self contentSizeWithWidth:size.width];
}

- (CGSize)intrinsicContentSize {
    CGFloat width = _preferredMaxLayoutWidth > 0 ? _preferredMaxLayoutWidth : CGRectGetWidth(self.frame);
    return [self contentSizeWithWidth:width>0?width:10000];
}

// get content size
- (CGSize)contentSizeWithWidth:(CGFloat)width {
    if (_textRender) {
        if (ABS(_textRender.size.width - width)>0.01 || _textRender.size.height == 0 || _textRender.size.width == 0) {
            return [_textRender textSizeWithRenderWidth:width];
        }
        return _textRender.size;
    }
    BOOL ignoreAboveRenderRelatePropertys = _ignoreAboveRenderRelatePropertys && _textRender;
    TFY_TextRender *textRender = [[TFY_TextRender alloc]initWithTextStorage:_textStorageOnRender];
    if (!ignoreAboveRenderRelatePropertys) {
        textRender.verticalAlignment = _verticalAlignment;
        textRender.maximumNumberOfLines = _numberOfLines;
        textRender.lineBreakMode = _lineBreakMode;
        textRender.truncationToken = _truncationToken;
    }
    return [textRender textSizeWithRenderWidth:width];
}

#pragma mark - Private

- (TFY_TextHighlight *)textHighlightForPoint:(CGPoint)point effectiveRange:(NSRangePointer)range {
    NSInteger index = [_textRenderOnDisplay characterIndexForPoint:point];
    if (index < 0) {
        return nil;
    }
    return [_textRenderOnDisplay textHighlightAtIndex:index effectiveRange:range];
}

#pragma mark - LongPress timer

- (void)startLongPressTimer {
    [self endLongPressTimer];
    _longPressTimer = [NSTimer timerWithTimeInterval:kLongPressTimerInterval
                                              target:self selector:@selector(longPressTimerTick)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_longPressTimer forMode:NSRunLoopCommonModes];
}

- (void)endLongPressTimer {
    if (_longPressTimer && [_longPressTimer isValid]) {
        [_longPressTimer invalidate];
        _longPressTimer = nil;
    }
    _longPressTimerCount = 0;
}

- (void)longPressTimerTick {
    ++_longPressTimerCount;
    if (!_textHighlight || _touchState == LabelTouchedStateNone || !_delegateFlags.didLongPressedTextHighlight) {
        [self endLongPressTimer];
        return;
    }
    if (_longPressTimerCount*kLongPressTimerInterval >= _longPressDuring) {
        _touchState = LabelTouchedStateLongPressed;
        [_delegate label:self didLongPressedTextHighlight:_textHighlight];
        [self endTouch];
    }
}

#pragma mark - Touch Event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touchState = LabelTouchedStateNone;
    _beginTouchPiont = CGPointZero;
    if (!_textRenderOnDisplay) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSRange range = NSMakeRange(0, 0);
    _textHighlight = [self textHighlightForPoint:point effectiveRange:&range];
    _highlightRange = range;
    if (!_textHighlight) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    _beginTouchPiont = point;
    _touchState = LabelTouchedStateTapped;
    if (_delegateFlags.didLongPressedTextHighlight) {
        [self startLongPressTimer];
    }
    [self immediatelyDisplayRedraw];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_textRenderOnDisplay || !_textHighlight) {
        [super touchesMoved:touches withEvent:event];
        return;
    }
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSRange range = NSMakeRange(0, 0);
    TFY_TextHighlight *textHighlight = [self textHighlightForPoint:point effectiveRange:&range];
    if (textHighlight == _textHighlight) {
        if (fabs(point.x - _beginTouchPiont.x) > kLongPressTimerMoveDistance || fabs(point.y - _beginTouchPiont.y) > kLongPressTimerMoveDistance) {
            [self endLongPressTimer];
        }
        if (_highlightRange.length == 0) {
            _highlightRange = range;
            [self immediatelyDisplayRedraw];
        }
        return;
    }
    [self endLongPressTimer];
    if (_highlightRange.length > 0) {
        _highlightRange = NSMakeRange(0, 0);
        [self immediatelyDisplayRedraw];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_textRenderOnDisplay || !_textHighlight) {
        [self endLongPressTimer];
        [super touchesEnded:touches withEvent:event];
        return;
    }
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSRange range = NSMakeRange(0, 0);
    if (_delegateFlags.didTappedTextHighlight && _touchState == LabelTouchedStateTapped) {
        TFY_TextHighlight *textHighlight = [self textHighlightForPoint:point effectiveRange:&range];
        if (textHighlight == _textHighlight && NSEqualRanges(range, _highlightRange) ) {
            [_delegate label:self didTappedTextHighlight:_textHighlight];
        }
    }
    [self endTouch];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_textRenderOnDisplay || !_textHighlight) {
        [self endLongPressTimer];
        [super touchesCancelled:touches withEvent:event];
        return;
    }
    [self endTouch];
}

- (void)endTouch {
    _textHighlight = nil;
    _highlightRange = NSMakeRange(0, 0);
    [self immediatelyDisplayRedraw];
    _touchState = LabelTouchedStateNone;
    _beginTouchPiont = CGPointZero;
}

#pragma mark - TYAsyncLayerDelegate

- (TFY_AsyncLayerDisplayTask *)newAsyncDisplayTask {
    __block TFY_TextRender *textRender = _textRender;
    __block NSTextStorage *textStorage = _textStorageOnRender;
    NSArray *attachments = _attachments;
    NSRange highlightRange  = _highlightRange;
    TFY_TextHighlight *textHighlight = _textHighlight;
    
    BOOL ignoreAboveRenderRelatePropertys = _ignoreAboveRenderRelatePropertys && textRender;
    TextVerticalAlignment verticalAlignment = _verticalAlignment;
    NSInteger numberOfLines = _numberOfLines;
    NSLineBreakMode lineBreakMode = _lineBreakMode;
    NSAttributedString *truncationToken = _truncationToken;
    
    TFY_AsyncLayerDisplayTask *task = [[TFY_AsyncLayerDisplayTask alloc]init];
    // will display
    task.willDisplay = ^(CALayer * _Nonnull layer) {
        if (attachments) {
            NSSet *attachmentSet = textRender.attachmentViewSet;
            for (TFY_TextAttachment *attachment in attachments) {
                if (!attachmentSet || ![attachmentSet containsObject:attachment]) {
                    [attachment removeFromSuperView:self];
                }
            }
        }
        self->_attachments = nil;
        self->_textRenderOnDisplay = nil;
    };
    task.displaying = ^(CGContextRef  _Nonnull context, CGSize size, BOOL isAsynchronously, BOOL (^ _Nonnull isCancelled)(void)) {
        if (!textRender) {
            textRender = [[TFY_TextRender alloc]initWithTextStorage:textStorage];
            if (isCancelled()) return;
        }
        if (!textStorage) {
            return;
        }
        if (!ignoreAboveRenderRelatePropertys) {
            textRender.verticalAlignment = verticalAlignment;
            textRender.maximumNumberOfLines = numberOfLines;
            textRender.lineBreakMode = lineBreakMode;
            textRender.truncationToken = truncationToken;
        }
        textRender.size = size;
        if (isCancelled()) return;
        [textRender setTextStorageTruncationToken];
        [textRender setTextHighlight:textHighlight range:highlightRange];
        [textRender drawTextAtPoint:CGPointZero isCanceled:isCancelled];
    };
    task.didDisplay = ^(CALayer * _Nonnull layer, BOOL finished) {
        self->_textRenderOnDisplay = textRender;
        NSArray *attachments = textRender.attachmentViews;
        if (!finished || !attachments) {
            if (attachments) {
                for (TFY_TextAttachment *attachment in attachments) {
                    [attachment removeFromSuperView:self];
                }
            }
            return ;
        }
        NSRange visibleRange = textRender.visibleCharacterRangeOnRender;
        NSRange truncatedRange = textRender.truncatedCharacterRangeOnRender;
        for (TFY_TextAttachment *attachment in attachments) {
            if (NSLocationInRange(attachment.range.location, visibleRange) && (truncatedRange.length == 0 || !NSLocationInRange(attachment.range.location, truncatedRange))) {
                if (textRender.maximumNumberOfLines > 0 && attachment.range.location != 0 && CGPointEqualToPoint(attachment.position, CGPointZero)) {
                    [attachment removeFromSuperView:self];
                }else {
                    CGRect rect = {attachment.position,attachment.size};
                    if (NSMaxRange(attachment.range) == NSMaxRange(visibleRange) && CGRectGetMaxX(rect) - CGRectGetWidth(self.frame) > 1) {
                        [attachment removeFromSuperView:self];
                    }else {
                        [attachment addToSuperView:self];
                        attachment.frame = rect;
                    }
                }
            }else {
                [attachment removeFromSuperView:self];
            }
        }
        self->_attachments = attachments;
    };
    return task;
}

- (void)dealloc {
    _textRender = nil;
}


@end
