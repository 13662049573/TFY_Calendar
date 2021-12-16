//
//  TFY_CalendarCell.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "TFY_CalendarCell.h"
#import "TFY_Calendar.h"
#import "TFY_CalendarExtensions.h"
#import "TFY_CalendarDynamic.h"
#import "TFY_CalendarConstants.h"

@interface TFY_CalendarCell ()
@property (readonly, nonatomic) UIColor *colorForCellFill;
@property (readonly, nonatomic) UIColor *colorForTitleLabel;
@property (readonly, nonatomic) UIColor *colorForSubtitleLabel;
@property (readonly, nonatomic) UIColor *colorForSubToptitleLabel;
@property (readonly, nonatomic) UIColor *colorForCellBorder;
@property (readonly, nonatomic) NSArray<UIColor *> *colorsForEvents;
@property (readonly, nonatomic) CGFloat borderRadius;
@end

@implementation TFY_CalendarCell
#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UILabel *label;
    CAShapeLayer *shapeLayer;
    UIImageView *imageView;
    TFY_CalendarEventIndicator *eventIndicator;
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    [self.contentView addSubview:label];
    self.titleLabel = label;
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:label];
    self.subtitleLabel = label;
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:label];
    self.subToptitleLabel = label;
    
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    shapeLayer.borderWidth = 1.0;
    shapeLayer.lineWidth=2;
    shapeLayer.borderColor = [UIColor clearColor].CGColor;
    shapeLayer.opacity = 0;
    [self.contentView.layer insertSublayer:shapeLayer below:_titleLabel.layer];
    self.shapeLayer = shapeLayer;
    
    eventIndicator = [[TFY_CalendarEventIndicator alloc] initWithFrame:CGRectZero];
    eventIndicator.backgroundColor = [UIColor clearColor];
    eventIndicator.hidden = YES;
    [self.contentView addSubview:eventIndicator];
    self.eventIndicator = eventIndicator;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeBottom|UIViewContentModeCenter;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
    self.clipsToBounds = NO;
    self.contentView.clipsToBounds = NO;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_subtitle) {
        _subtitleLabel.text = _subtitle;
        if (_subtitleLabel.hidden) {
            _subtitleLabel.hidden = NO;
        }
    } else {
        if (!_subtitleLabel.hidden) {
            _subtitleLabel.hidden = YES;
        }
    }
    
    if (_subToptitle) {
        _subToptitleLabel.text = _subToptitle;
        if (_subToptitleLabel.hidden) {
            _subToptitleLabel.hidden = NO;
        }
    } else {
        if (!_subToptitleLabel.hidden) {
            _subToptitleLabel.hidden = YES;
        }
    }
    
    if (_subtitle && _subToptitle) {
        self.subtitleLabel.font = [UIFont systemFontOfSize:8];
        self.subToptitleLabel.font = [UIFont systemFontOfSize:8];
        
        CGFloat titleHeight = self.titleLabel.font.lineHeight;
        CGFloat subtitleHeight = self.subtitleLabel.font.lineHeight;
        CGFloat subToptitleHeight = self.subToptitleLabel.font.lineHeight;
        
        _subToptitleLabel.frame = CGRectMake(
                                             self.preferredSubToptitleOffset.x,
                                             self.preferredSubToptitleOffset.y,
                                          self.contentView.tfyCa_width,
                                             subToptitleHeight);
        
        
        _titleLabel.frame = CGRectMake(
                                       self.preferredTitleOffset.x,
                                       self.subToptitleLabel.tfyCa_height,
                                       self.contentView.tfyCa_width,
                                       titleHeight
                                       );
        
        _subtitleLabel.frame = CGRectMake(
                                          self.preferredSubtitleOffset.x,
                                          subToptitleHeight + titleHeight,
                                          self.contentView.tfyCa_width,
                                          subtitleHeight
                                          );
        
        
    } else {
       
        if (_subtitle) {
            CGFloat titleHeight = self.titleLabel.font.lineHeight;
            CGFloat subtitleHeight = self.subtitleLabel.font.lineHeight;
            
            CGFloat height = titleHeight + subtitleHeight;
            
            _titleLabel.frame = CGRectMake(
                                           self.preferredTitleOffset.x,
                                           (self.contentView.tfyCa_height*5.0/6.0-height)*0.5+self.preferredTitleOffset.y,
                                           self.contentView.tfyCa_width,
                                           titleHeight
                                           );
            _subtitleLabel.frame = CGRectMake(
                                              self.preferredSubtitleOffset.x,
                                              (_titleLabel.tfyCa_bottom-self.preferredTitleOffset.y) - (_titleLabel.tfyCa_height-_titleLabel.font.pointSize)+self.preferredSubtitleOffset.y,
                                              self.contentView.tfyCa_width,
                                              subtitleHeight
                                              );
        } else if (_subToptitle) {
            
            CGFloat titleHeight = self.titleLabel.font.lineHeight;
            CGFloat subToptitleHeight = self.subToptitleLabel.font.lineHeight;
            
            _subToptitleLabel.frame = CGRectMake(
                                                 self.preferredSubToptitleOffset.x,
                                                 self.preferredSubToptitleOffset.y,
                                                 self.contentView.tfyCa_width,
                                                 subToptitleHeight);
            
            
            _titleLabel.frame = CGRectMake(self.preferredTitleOffset.x,
                                           self.subToptitleLabel.tfyCa_height,
                                           self.contentView.tfyCa_width,
                                           titleHeight);
            
        }  else {
            
            _titleLabel.frame = CGRectMake(
                                           self.preferredTitleOffset.x,
                                           self.preferredTitleOffset.y,
                                           self.contentView.tfyCa_width,
                                           floor(self.contentView.tfyCa_height*5.0/6.0)
                                           );
        }
        
    }
    
    _imageView.frame = CGRectMake(self.preferredImageOffset.x, self.preferredImageOffset.y, self.contentView.tfyCa_width, self.contentView.tfyCa_height);
    
    CGFloat titleHeight = self.bounds.size.height*5.0/6.0;
    CGFloat diameter = MIN(self.bounds.size.height*5.0/6.0,self.bounds.size.width);
    if (_subtitle && _subToptitle) {
        titleHeight = self.bounds.size.height*5.0/5.0;
        diameter = MIN(self.bounds.size.height*5.0/5.0,self.bounds.size.width);
    }
    diameter = diameter > TFYCa_CalendarStandardCellDiameter ? (diameter - (diameter-TFYCa_CalendarStandardCellDiameter)*0.5) : diameter;
    _shapeLayer.frame = CGRectMake((self.bounds.size.width-diameter)/2,
                                   (titleHeight-diameter)/2,
                                   diameter,
                                   diameter);
    
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:_shapeLayer.bounds
                                                cornerRadius:CGRectGetWidth(_shapeLayer.bounds)*0.5*self.borderRadius].CGPath;
    if (!CGPathEqualToPath(_shapeLayer.path,path)) {
        _shapeLayer.path = path;
    }
    
    CGFloat eventSize = _shapeLayer.frame.size.height/6.0;
    if (_subtitle && _subToptitle) {
        eventSize = _shapeLayer.frame.size.height/5.0;
    }
    _eventIndicator.frame = CGRectMake(
                                       self.preferredEventOffset.x,
                                       CGRectGetMaxY(_shapeLayer.frame)+eventSize*0.17+self.preferredEventOffset.y,
                                       self.tfyCa_width,
                                       eventSize*0.83
                                      );
    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    if (self.window) { //避免以某种方式中断导航转换
        [CATransaction setDisableActions:YES]; // 避免形状层闪烁。
    }
    self.shapeLayer.opacity = 0;
    [self.contentView.layer removeAnimationForKey:@"opacity"];
}

#pragma mark - Public

- (void)performSelecting
{
    _shapeLayer.opacity = 1;
        
    CAAnimationGroup *group = [CAAnimationGroup animation];
    CABasicAnimation *zoomOut = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomOut.fromValue = @0.3;
    zoomOut.toValue = @1.2;
    zoomOut.duration = TFYCa_CalendarDefaultBounceAnimationDuration/4*3;
    CABasicAnimation *zoomIn = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomIn.fromValue = @1.2;
    zoomIn.toValue = @1.0;
    zoomIn.beginTime = TFYCa_CalendarDefaultBounceAnimationDuration/4*3;
    zoomIn.duration = TFYCa_CalendarDefaultBounceAnimationDuration/4;
    group.duration = TFYCa_CalendarDefaultBounceAnimationDuration;
    group.animations = @[zoomOut, zoomIn];
    [_shapeLayer addAnimation:group forKey:@"bounce"];
    [self configureAppearance];
    
}

#pragma mark - Private

- (void)configureAppearance
{
    UIColor *textColor = self.colorForTitleLabel;
    if (![textColor isEqual:_titleLabel.textColor]) {
        _titleLabel.textColor = textColor;
    }
    UIFont *titleFont = self.calendar.appearance.titleFont;
    if (![titleFont isEqual:_titleLabel.font]) {
        _titleLabel.font = titleFont;
    }
    
    if (_subtitle) {
        textColor = self.colorForSubtitleLabel;
        if (![textColor isEqual:_subtitleLabel.textColor]) {
            _subtitleLabel.textColor = textColor;
        }
        titleFont = self.calendar.appearance.subtitleFont;
        if (![titleFont isEqual:_subtitleLabel.font]) {
            _subtitleLabel.font = titleFont;
        }
    }
    
    if (_subToptitle) {
        textColor = self.colorForSubToptitleLabel;
        if (![textColor isEqual:_subToptitleLabel.textColor]) {
            _subToptitleLabel.textColor = textColor;
        }
        titleFont = self.calendar.appearance.subToptitleFont;
        if (![titleFont isEqual:_subToptitleLabel.font]) {
            _subToptitleLabel.font = titleFont;
        }
    }
    
    UIColor *borderColor = self.colorForCellBorder;
    UIColor *fillColor = self.colorForCellFill;
    
    BOOL shouldHideShapeLayer = !self.selected && !self.dateIsToday && !borderColor && !fillColor;
    
    if (_shapeLayer.opacity == shouldHideShapeLayer) {
        _shapeLayer.opacity = !shouldHideShapeLayer;
    }
    if (!shouldHideShapeLayer) {
        
        CGColorRef cellFillColor = self.colorForCellFill.CGColor;
        if (!CGColorEqualToColor(_shapeLayer.fillColor, cellFillColor)) {
            _shapeLayer.fillColor = cellFillColor;
        }
        
        CGColorRef cellBorderColor = self.colorForCellBorder.CGColor;
        if (!CGColorEqualToColor(_shapeLayer.strokeColor, cellBorderColor)) {
            _shapeLayer.strokeColor = cellBorderColor;
        }
        
        CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:_shapeLayer.bounds
                                                    cornerRadius:CGRectGetWidth(_shapeLayer.bounds)*0.5*self.borderRadius].CGPath;
        if (!CGPathEqualToPath(_shapeLayer.path, path)) {
            _shapeLayer.path = path;
        }
        
    }
    
    if (![_image isEqual:_imageView.image]) {
        _imageView.image = _image;
        _imageView.hidden = !_image;
    }
    
    if (_eventIndicator.hidden == (_numberOfEvents > 0)) {
        _eventIndicator.hidden = !_numberOfEvents;
    }
    
    _eventIndicator.numberOfEvents = self.numberOfEvents;
    _eventIndicator.color = self.colorsForEvents;

}

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary
{
    if (self.isSelected) {
        if (self.dateIsToday) {
            return dictionary[@(TFYCa_CalendarCellStateSelected|TFYCa_CalendarCellStateToday)] ?: dictionary[@(TFYCa_CalendarCellStateSelected)];
        }
        return dictionary[@(TFYCa_CalendarCellStateSelected)];
    }
    if (self.dateIsToday && [[dictionary allKeys] containsObject:@(TFYCa_CalendarCellStateToday)]) {
        return dictionary[@(TFYCa_CalendarCellStateToday)];
    }
    if (self.placeholder && [[dictionary allKeys] containsObject:@(TFYCa_CalendarCellStatePlaceholder)]) {
        return dictionary[@(TFYCa_CalendarCellStatePlaceholder)];
    }
    if (self.weekend && [[dictionary allKeys] containsObject:@(TFYCa_CalendarCellStateWeekend)]) {
        return dictionary[@(TFYCa_CalendarCellStateWeekend)];
    }
    return dictionary[@(TFYCa_CalendarCellStateNormal)];
}

#pragma mark - Properties

- (UIColor *)colorForCellFill
{
    if (self.selected) {
        return self.preferredFillSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.backgroundColors];
    }
    return self.preferredFillDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.backgroundColors];
}

- (UIColor *)colorForTitleLabel
{
    if (self.selected) {
        return self.preferredTitleSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.titleColors];
    }
    return self.preferredTitleDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.titleColors];
}

- (UIColor *)colorForSubtitleLabel
{
    if (self.selected) {
        return self.preferredSubtitleSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.subtitleColors];
    }
    return self.preferredSubtitleDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.subtitleColors];
}

- (UIColor *)colorForSubToptitleLabel {
    if (self.selected) {
        return self.preferredSubToptitleSelectionColor?: [self colorForCurrentStateInDictionary:_appearance.subToptitleColors];
    }
    return self.preferredSubToptitleDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.subToptitleColors];
}


- (UIColor *)colorForCellBorder
{
    if (self.selected) {
        return _preferredBorderSelectionColor ?: _appearance.borderSelectionColor;
    }
    return _preferredBorderDefaultColor ?: _appearance.borderDefaultColor;
}

- (NSArray<UIColor *> *)colorsForEvents
{
    if (self.selected) {
        return _preferredEventSelectionColors ?: @[_appearance.eventSelectionColor];
    }
    return _preferredEventDefaultColors ?: @[_appearance.eventDefaultColor];
}

- (CGFloat)borderRadius
{
    return _preferredBorderRadius >= 0 ? _preferredBorderRadius : _appearance.borderRadius;
}

#define OFFSET_PROPERTY(NAME,CAPITAL,ALTERNATIVE) \
\
@synthesize NAME = _##NAME; \
\
- (void)set##CAPITAL:(CGPoint)NAME \
{ \
    BOOL diff = !CGPointEqualToPoint(NAME, self.NAME); \
    _##NAME = NAME; \
    if (diff) { \
        [self setNeedsLayout]; \
    } \
} \
\
- (CGPoint)NAME \
{ \
    return CGPointEqualToPoint(_##NAME, CGPointInfinity) ? ALTERNATIVE : _##NAME; \
}

OFFSET_PROPERTY(preferredTitleOffset, PreferredTitleOffset, _appearance.titleOffset);
OFFSET_PROPERTY(preferredSubtitleOffset, PreferredSubtitleOffset, _appearance.subtitleOffset);
OFFSET_PROPERTY(preferredSubToptitleOffset, preferredSubToptitleOffset, _appearance.subToptitleOffset);
OFFSET_PROPERTY(preferredImageOffset, PreferredImageOffset, _appearance.imageOffset);
OFFSET_PROPERTY(preferredEventOffset, PreferredEventOffset, _appearance.eventOffset);

#undef OFFSET_PROPERTY

- (void)setCalendar:(TFY_Calendar *)calendar
{
    if (![_calendar isEqual:calendar]) {
        _calendar = calendar;
        _appearance = calendar.appearance;
        [self configureAppearance];
    }
}

- (void)setSubtitle:(NSString *)subtitle
{
    if (![_subtitle isEqualToString:subtitle]) {
        BOOL diff = (subtitle.length && !_subtitle.length) || (_subtitle.length && !subtitle.length);
        _subtitle = subtitle;
        if (diff) {
            [self setNeedsLayout];
        }
    }
}

- (void)setSubToptitle:(NSString *)subToptitle {
    
    if (![_subToptitle isEqualToString:subToptitle]) {
        BOOL diff = (subToptitle.length && !_subToptitle.length) || (_subToptitle.length && !subToptitle.length);
        _subToptitle = subToptitle;
        if (diff) {
            [self setNeedsLayout];
        }
    }
}

@end


@interface TFY_CalendarEventIndicator ()

@property (weak, nonatomic) UIView *contentView;

@property (strong, nonatomic) NSPointerArray *eventLayers;

@end

@implementation TFY_CalendarEventIndicator

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:view];
        self.contentView = view;
        
        self.eventLayers = [NSPointerArray weakObjectsPointerArray];
        for (int i = 0; i < TFYCa_CalendarMaximumNumberOfEvents; i++) {
            CALayer *layer = [CALayer layer];
            layer.backgroundColor = [UIColor clearColor].CGColor;
            [self.contentView.layer addSublayer:layer];
            [self.eventLayers addPointer:(__bridge void * _Nullable)(layer)];
        }
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat diameter = MIN(MIN(self.tfyCa_width, self.tfyCa_height),TFYCa_CalendarMaximumEventDotDiameter);
    self.contentView.tfyCa_height = self.tfyCa_height;
    self.contentView.tfyCa_width = (self.numberOfEvents*2-1)*diameter;
    self.contentView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    if (layer == self.layer) {
        
        CGFloat diameter = MIN(MIN(self.tfyCa_width, self.tfyCa_height),TFYCa_CalendarMaximumEventDotDiameter);
        for (int i = 0; i < self.eventLayers.count; i++) {
            CALayer *eventLayer = [self.eventLayers pointerAtIndex:i];
            eventLayer.hidden = i >= self.numberOfEvents;
            if (!eventLayer.hidden) {
                eventLayer.frame = CGRectMake(2*i*diameter, (self.tfyCa_height-diameter)*0.5, diameter, diameter);
                if (eventLayer.cornerRadius != diameter/2) {
                    eventLayer.cornerRadius = diameter/2;
                }
            }
        }
    }
}

- (void)setColor:(id)color
{
    if (![_color isEqual:color]) {
        _color = color;
        
        if ([_color isKindOfClass:[UIColor class]]) {
            for (NSInteger i = 0; i < self.eventLayers.count; i++) {
                CALayer *layer = [self.eventLayers pointerAtIndex:i];
                layer.backgroundColor = [_color CGColor];
            }
        } else if ([_color isKindOfClass:[NSArray class]]) {
            NSArray<UIColor *> *colors = (NSArray *)_color;
            for (int i = 0; i < self.eventLayers.count; i++) {
                CALayer *eventLayer = [self.eventLayers pointerAtIndex:i];
                eventLayer.backgroundColor = colors[MIN(i,colors.count-1)].CGColor;
            }
        }
        
    }
}

- (void)setNumberOfEvents:(NSInteger)numberOfEvents
{
    if (_numberOfEvents != numberOfEvents) {
        _numberOfEvents = MIN(MAX(numberOfEvents,0),TFYCa_CalendarMaximumNumberOfEvents);
        [self setNeedsLayout];
    }
}

@end


@implementation TFY_CalendarBlankCell

- (void)configureAppearance {}

@end



