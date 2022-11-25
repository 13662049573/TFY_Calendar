//
//  UIButton+TFY_Tools.m
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIButton+TFY_Tools.h"
#import <objc/message.h>
#import <time.h>

@interface UIButton ()
/**
 *  🐶nn    👇
 */
@property(nonatomic,strong)dispatch_source_t timer;
/**
 *  🐶记录外边的时间    👇
 */
@property(nonatomic,assign)NSInteger userTime;

@end

static NSInteger const TimeInterval = 60; // 默认时间
static NSString * const ButtonTitleFormat = @"剩余%ld秒";
static NSString * const RetainTitle = @"重试";
static const void *ButtonRuntimeLimitTasks         = &ButtonRuntimeLimitTasks;
static const void *ButtonRuntimeLimitTapBlock      = &ButtonRuntimeLimitTapBlock;
static const void *ButtonRuntimeLimitTapTimes      = &ButtonRuntimeLimitTapTimes;
static const void *ButtonRuntimeLimitTapLastTimes  = &ButtonRuntimeLimitTapLastTimes;
static const void *ButtonRuntimeLimitTapSpaceTimes = &ButtonRuntimeLimitTapSpaceTimes;
static const void *ButtonRuntimeLimitIsStop        = &ButtonRuntimeLimitIsStop;
static const void *DragEnableKey = &DragEnableKey;
static const void *AdsorbEnableKey = &AdsorbEnableKey;
static const void *PaddingGKey = &PaddingGKey;

static NSString *UI_swizzleButtonMethodName = @"_UI_swizzleButtonLimitTimeMethod";

CG_INLINE void UI_swizzleButtonIfNeed(Class swizzleClass){
    @synchronized (swizzleClass) {
        if (class_getMethodImplementation(swizzleClass, NSSelectorFromString(UI_swizzleButtonMethodName)) !=_objc_msgForward) return;
        class_addMethod(swizzleClass, NSSelectorFromString(UI_swizzleButtonMethodName), imp_implementationWithBlock(^(id object,SEL sel){}), "v@:");
        SEL buttonTapSelector = sel_registerName("_sendActionsForEvents:withEvent:");
        __block void (* oldImp) (__unsafe_unretained id, SEL,UIControlEvents,id) = NULL;
        id newImpBlock = ^ (__unsafe_unretained UIButton* self,UIControlEvents events, id a){
            if (events & UIControlEventTouchUpInside) {
                if (objc_getAssociatedObject(self, ButtonRuntimeLimitIsStop)) return;
                id spaceTime = objc_getAssociatedObject(self, ButtonRuntimeLimitTapSpaceTimes);
                if (spaceTime) {
                   NSTimeInterval spaceTimef = [spaceTime doubleValue];
                    id lastTime = objc_getAssociatedObject(self, ButtonRuntimeLimitTapLastTimes);
                    NSTimeInterval currentTime = time(NULL);
                    if (lastTime) {
                        if (currentTime - [lastTime doubleValue] < spaceTimef) return;
                    }
                    objc_setAssociatedObject(self, ButtonRuntimeLimitTapLastTimes, @(currentTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                }
                ButtonLimitTimesTapBlock block = objc_getAssociatedObject(self, ButtonRuntimeLimitTapBlock);
                if (block) {
                    NSUInteger tapTimes = [objc_getAssociatedObject(self, ButtonRuntimeLimitTapTimes) integerValue];
                    tapTimes ++;
                    objc_setAssociatedObject(self, ButtonRuntimeLimitTapTimes, @(tapTimes), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    BOOL stop = NO;
                    block(tapTimes,&stop,self);
                    if (stop) {
                        objc_setAssociatedObject(self, ButtonRuntimeLimitIsStop, @(stop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        return;
                    }
                }
            }
            if (oldImp == NULL) {
                struct objc_super supperInfo = {
                    .receiver = self,
                    .super_class = class_getSuperclass(swizzleClass)
                };
                ((void (*) (struct objc_super *, SEL,UIControlEvents,id))objc_msgSendSuper)(&supperInfo, buttonTapSelector,events,a);
            }else{
                oldImp(self,buttonTapSelector,events,a);
            }
        };
        Method buttonTapMethod = class_getInstanceMethod(swizzleClass, buttonTapSelector);
        IMP newImp = imp_implementationWithBlock(newImpBlock);
        if (!class_addMethod(swizzleClass, buttonTapSelector, newImp, method_getTypeEncoding(buttonTapMethod))) {
            oldImp = (__typeof__ (oldImp))method_setImplementation(buttonTapMethod, newImp);
        }
    }
}

@implementation UIButton (TFY_Tools)

- (void)tfy_imageDirection:(ButtonImageDirection)direction space:(CGFloat)space{
    CGFloat imageWidth, imageHeight, textWidth, textHeight, x, y;
    imageWidth = self.currentImage.size.width;
    imageHeight = self.currentImage.size.height;
    [self.titleLabel sizeToFit];
    textWidth = self.titleLabel.frame.size.width;
    textHeight = self.titleLabel.frame.size.height;
    space = space / 2;
    switch (direction) {
        case ButtonDirectionCenterImageTop:{
            x = textHeight / 2 + space;
            y = textWidth / 2;
            self.imageEdgeInsets = UIEdgeInsetsMake(-x, y, x, - y);
            x = imageHeight / 2 + space;
            y = imageWidth / 2;
            self.titleEdgeInsets = UIEdgeInsetsMake(x, - y, - x, y);
        }
            break;
        case ButtonDirectionCenterImageBottom:{
            x = textHeight / 2 + space;
            y = textWidth / 2;
            self.imageEdgeInsets = UIEdgeInsetsMake(x, y, -x, - y);
            x = imageHeight / 2 + space;
            y = imageWidth / 2;
            self.titleEdgeInsets = UIEdgeInsetsMake(-x, - y, x, y);
        }
            break;
        case ButtonDirectionCenterImageLeft:{
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -space,0, space);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, space , 0, - space);
        }
            break;
        case ButtonDirectionCenterImageRight:{
            self.imageEdgeInsets = UIEdgeInsetsMake(0, space + textWidth, 0, - (space + textWidth));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(space + imageWidth), 0, (space + imageWidth));
        }
            break;
        case ButtonDirectionLeftImageLeft:
        {
            self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, space, 0, 0);
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            break;
        }
        case ButtonDirectionLeftImageRight:
        {
            self.imageEdgeInsets = UIEdgeInsetsMake(0, textWidth + space, 0, 0);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, 0);
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            break;
        }
        case ButtonDirectionRightImageLeft:
        {
            self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, space);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            break;
        }
        case ButtonDirectionRightImageRight:
        {
            self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -textWidth);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, imageWidth + space);
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            break;
        }
        default:
            break;
    }
}

- (UIButton * _Nonnull (^)(ButtonLimitTimesTapBlock _Nonnull))tfy_buttonTapTime{
    return ^(ButtonLimitTimesTapBlock block){
        if (block != nil) {
            UI_swizzleButtonIfNeed(object_getClass(self));
        }
        objc_setAssociatedObject(self, ButtonRuntimeLimitTapBlock, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
        return self;
    };
}

- (UIButton * _Nonnull (^)(NSTimeInterval))tfy_tapSpaceTime{
    return ^(NSTimeInterval time){
        UI_swizzleButtonIfNeed(object_getClass(self));
        objc_setAssociatedObject(self, ButtonRuntimeLimitTapSpaceTimes, @(time), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return self;
    };
}

-(void)setTfy_dragEnable:(BOOL)tfy_dragEnable {
    objc_setAssociatedObject(self, DragEnableKey,@(tfy_dragEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)tfy_dragEnable {
    return [objc_getAssociatedObject(self, DragEnableKey) boolValue];
}

-(void)setTfy_adsorbEnable:(BOOL)tfy_adsorbEnable {
    objc_setAssociatedObject(self, AdsorbEnableKey,@(tfy_adsorbEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)tfy_adsorbEnable {
    return [objc_getAssociatedObject(self, AdsorbEnableKey) boolValue];
}

- (void)setTfy_padding:(CGFloat)tfy_padding {
    objc_setAssociatedObject(self, PaddingGKey,@(tfy_padding), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)tfy_padding {
    return [objc_getAssociatedObject(self, PaddingGKey) floatValue];
}

- (void)tfy_cancelRecordTime{
    if (!objc_getAssociatedObject(self, ButtonRuntimeLimitTapLastTimes)) return;
    objc_setAssociatedObject(self, ButtonRuntimeLimitTapLastTimes, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTfy_time:(NSInteger)tfy_time{
    objc_setAssociatedObject(self, @selector(tfy_time), @(tfy_time), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)tfy_time {
    return  [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setTfy_format:(NSString *)tfy_format {
    objc_setAssociatedObject(self, @selector(tfy_format), tfy_format, OBJC_ASSOCIATION_COPY);
}

- (NSString *)tfy_format {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setUserTime:(NSInteger)userTime {
    objc_setAssociatedObject(self, @selector(userTime), @(userTime), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)userTime {
    return  [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setTimer:(dispatch_source_t)timer {
    objc_setAssociatedObject(self, @selector(timer), timer, OBJC_ASSOCIATION_RETAIN);
}

- (dispatch_source_t)timer {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCompleteBlock:(void (^)(void))CompleteBlock {
    objc_setAssociatedObject(self, @selector(CompleteBlock), CompleteBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(void (^)(void))CompleteBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)tfy_startTimer {
    if (!self.tfy_time) {
        self.tfy_time = TimeInterval;
    }
    if (!self.tfy_format) {
        self.tfy_format = ButtonTitleFormat;
    }
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, globalQueue);
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        if (self.tfy_time <= 1) {
            dispatch_source_cancel(self.timer);
        }else
        {
            self.tfy_time --;
            dispatch_async(mainQueue, ^{
                self.enabled = NO;
                [self setTitle:[NSString stringWithFormat:self.tfy_format,self.tfy_time] forState:UIControlStateNormal];
            });
        }
    });
    dispatch_source_set_cancel_handler(self.timer, ^{
        dispatch_async(mainQueue, ^{
            self.enabled = YES;
            [self setTitle:RetainTitle forState:UIControlStateNormal];
            if (self.CompleteBlock) {
                self.CompleteBlock();
            }
            if (self.userTime) {
                self.tfy_time = self.userTime;
            }else
            {
                self.tfy_time = TimeInterval;
            }
        });
    });
    dispatch_resume(self.timer);
}

- (void)tfy_endTimer{
    if (self.timer) {
        dispatch_source_cancel(self.timer);
    }
}

CGPoint begincenter;
CGPoint beginPoint;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.highlighted = YES;
    if (![objc_getAssociatedObject(self, DragEnableKey) boolValue]) {
        return;
    }
    begincenter=self.superview.center;
    UITouch *touch = [touches anyObject];
    beginPoint = [touch locationInView:self.superview];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
    [super touchesMoved:touches withEvent:event];
    if (![objc_getAssociatedObject(self, DragEnableKey) boolValue]) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint nowPoint = [touch locationInView:self];
    
    float offsetX = nowPoint.x - beginPoint.x;
    float offsetY = nowPoint.y - beginPoint.y;
    
    self.superview.center = CGPointMake(self.superview.center.x + offsetX, self.superview.center.y + offsetY);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.superview && [objc_getAssociatedObject(self,AdsorbEnableKey) boolValue] ) {
        if (self.highlighted) {
            [self sendActionsForControlEvents:UIControlEventTouchDown];
            self.highlighted = NO;
        }
        CGPoint nowPoint = self.superview.center;
        float offsetX = nowPoint.x - begincenter.x;
        float offsetY = nowPoint.y - begincenter.y;

        if (fabsf(offsetX)<5 && fabsf(offsetY)<5) {
            [super touchesEnded:touches withEvent:event];
        }
        float marginLeft = self.superview.frame.origin.x;
        float marginRight = self.superview.superview.frame.size.width - self.superview.frame.origin.x - self.superview.frame.size.width;
        float marginTop = self.superview.frame.origin.y;
        float marginBottom = self.superview.superview.frame.size.height - self.superview.frame.origin.y - self.superview.frame.size.height;
        
        [UIView animateWithDuration:0.125 animations:^(void){
            if (marginTop<60) {
                self.superview.frame = CGRectMake(marginLeft<marginRight?marginLeft<self.tfy_padding?self.tfy_padding:self.superview.frame.origin.x:marginRight<self.tfy_padding?self.superview.superview.frame.size.width -self.superview.frame.size.width-self.tfy_padding:self.superview.frame.origin.x,
                                                  self.tfy_padding,
                                        self.superview.frame.size.width,
                                        self.superview.frame.size.height);
            }
            else if (marginBottom<60) {
                self.superview.frame = CGRectMake(marginLeft<marginRight?marginLeft<self.tfy_padding?self.tfy_padding:self.superview.frame.origin.x:marginRight<self.tfy_padding?self.superview.superview.frame.size.width -self.superview.frame.size.width-self.tfy_padding:self.superview.frame.origin.x,
                                        self.superview.superview.frame.size.height - self.superview.frame.size.height-self.tfy_padding,
                                        self.superview.frame.size.width,
                                        self.superview.frame.size.height);
                
            } else {
                self.superview.frame = CGRectMake(marginLeft<marginRight?self.tfy_padding:self.superview.superview.frame.size.width - self.superview.frame.size.width-self.tfy_padding,
                                        self.superview.frame.origin.y,
                                        self.superview.frame.size.width,
                                        self.superview.frame.size.height);
            }
        }];
    }else{
        [super touchesEnded:touches withEvent:event];
        
    }
}


@end
