//
//  TFY_PopupMenu.m
//  TFY_ProgressHUD
//
//  Created by 田风有 on 2019/11/3.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "TFY_PopupMenu.h"
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define MainWindow  [UIApplication sharedApplication].keyWindow
#define TFY_SAFE_BLOCK(BlockName, ...) ({ !BlockName ? nil : BlockName(__VA_ARGS__); })

@implementation PopupMenuPath

+ (CAShapeLayer *)tfy_maskLayerWithRect:(CGRect)rect
                            rectCorner:(UIRectCorner)rectCorner
                          cornerRadius:(CGFloat)cornerRadius
                            arrowWidth:(CGFloat)arrowWidth
                           arrowHeight:(CGFloat)arrowHeight
                         arrowPosition:(CGFloat)arrowPosition
                        arrowDirection:(PopupMenuArrowDirection)arrowDirection
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [self tfy_bezierPathWithRect:rect rectCorner:rectCorner cornerRadius:cornerRadius borderWidth:0 borderColor:[UIColor clearColor] backgroundColor:[UIColor clearColor] arrowWidth:arrowWidth arrowHeight:arrowHeight arrowPosition:arrowPosition arrowDirection:arrowDirection].CGPath;
    return shapeLayer;
}


+ (UIBezierPath *)tfy_bezierPathWithRect:(CGRect)rect
                             rectCorner:(UIRectCorner)rectCorner
                           cornerRadius:(CGFloat)cornerRadius
                            borderWidth:(CGFloat)borderWidth
                            borderColor:(UIColor *)borderColor
                        backgroundColor:(UIColor *)backgroundColor
                             arrowWidth:(CGFloat)arrowWidth
                            arrowHeight:(CGFloat)arrowHeight
                          arrowPosition:(CGFloat)arrowPosition
                         arrowDirection:(PopupMenuArrowDirection)arrowDirection
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    if (borderColor) {
        [borderColor setStroke];
    }
    if (backgroundColor) {
        [backgroundColor setFill];
    }
    bezierPath.lineWidth = borderWidth;
    rect = CGRectMake(borderWidth / 2, borderWidth / 2, TFY_RectWidth(rect) - borderWidth, TFY_RectHeight(rect) - borderWidth);
    CGFloat topRightRadius = 0,topLeftRadius = 0,bottomRightRadius = 0,bottomLeftRadius = 0;
    CGPoint topRightArcCenter,topLeftArcCenter,bottomRightArcCenter,bottomLeftArcCenter;
    
    if (rectCorner & UIRectCornerTopLeft) {
        topLeftRadius = cornerRadius;
    }
    if (rectCorner & UIRectCornerTopRight) {
        topRightRadius = cornerRadius;
    }
    if (rectCorner & UIRectCornerBottomLeft) {
        bottomLeftRadius = cornerRadius;
    }
    if (rectCorner & UIRectCornerBottomRight) {
        bottomRightRadius = cornerRadius;
    }
    
    if (arrowDirection == PopupMenuArrowDirectionTop) {
        topLeftArcCenter = CGPointMake(topLeftRadius + TFY_RectX(rect), arrowHeight + topLeftRadius + TFY_RectX(rect));
        topRightArcCenter = CGPointMake(TFY_RectWidth(rect) - topRightRadius + TFY_RectX(rect), arrowHeight + topRightRadius + TFY_RectX(rect));
        bottomLeftArcCenter = CGPointMake(bottomLeftRadius + TFY_RectX(rect), TFY_RectHeight(rect) - bottomLeftRadius + TFY_RectX(rect));
        bottomRightArcCenter = CGPointMake(TFY_RectWidth(rect) - bottomRightRadius + TFY_RectX(rect), TFY_RectHeight(rect) - bottomRightRadius + TFY_RectX(rect));
        if (arrowPosition < topLeftRadius + arrowWidth / 2) {
            arrowPosition = topLeftRadius + arrowWidth / 2;
        }else if (arrowPosition > TFY_RectWidth(rect) - topRightRadius - arrowWidth / 2) {
            arrowPosition = TFY_RectWidth(rect) - topRightRadius - arrowWidth / 2;
        }
        [bezierPath moveToPoint:CGPointMake(arrowPosition - arrowWidth / 2, arrowHeight + TFY_RectX(rect))];
        [bezierPath addLineToPoint:CGPointMake(arrowPosition, TFY_RectTop(rect) + TFY_RectX(rect))];
        [bezierPath addLineToPoint:CGPointMake(arrowPosition + arrowWidth / 2, arrowHeight + TFY_RectX(rect))];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectWidth(rect) - topRightRadius, arrowHeight + TFY_RectX(rect))];
        [bezierPath addArcWithCenter:topRightArcCenter radius:topRightRadius startAngle:M_PI * 3 / 2 endAngle:2 * M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectWidth(rect) + TFY_RectX(rect), TFY_RectHeight(rect) - bottomRightRadius - TFY_RectX(rect))];
        [bezierPath addArcWithCenter:bottomRightArcCenter radius:bottomRightRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(bottomLeftRadius + TFY_RectX(rect), TFY_RectHeight(rect) + TFY_RectX(rect))];
        [bezierPath addArcWithCenter:bottomLeftArcCenter radius:bottomLeftRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectX(rect), arrowHeight + topLeftRadius + TFY_RectX(rect))];
        [bezierPath addArcWithCenter:topLeftArcCenter radius:topLeftRadius startAngle:M_PI endAngle:M_PI * 3 / 2 clockwise:YES];
        
    }else if (arrowDirection == PopupMenuArrowDirectionBottom) {
        topLeftArcCenter = CGPointMake(topLeftRadius + TFY_RectX(rect),topLeftRadius + TFY_RectX(rect));
        topRightArcCenter = CGPointMake(TFY_RectWidth(rect) - topRightRadius + TFY_RectX(rect), topRightRadius + TFY_RectX(rect));
        bottomLeftArcCenter = CGPointMake(bottomLeftRadius + TFY_RectX(rect), TFY_RectHeight(rect) - bottomLeftRadius + TFY_RectX(rect) - arrowHeight);
        bottomRightArcCenter = CGPointMake(TFY_RectWidth(rect) - bottomRightRadius + TFY_RectX(rect), TFY_RectHeight(rect) - bottomRightRadius + TFY_RectX(rect) - arrowHeight);
        if (arrowPosition < bottomLeftRadius + arrowWidth / 2) {
            arrowPosition = bottomLeftRadius + arrowWidth / 2;
        }else if (arrowPosition > TFY_RectWidth(rect) - bottomRightRadius - arrowWidth / 2) {
            arrowPosition = TFY_RectWidth(rect) - bottomRightRadius - arrowWidth / 2;
        }
        [bezierPath moveToPoint:CGPointMake(arrowPosition + arrowWidth / 2, TFY_RectHeight(rect) - arrowHeight + TFY_RectX(rect))];
        [bezierPath addLineToPoint:CGPointMake(arrowPosition, TFY_RectHeight(rect) + TFY_RectX(rect))];
        [bezierPath addLineToPoint:CGPointMake(arrowPosition - arrowWidth / 2, TFY_RectHeight(rect) - arrowHeight + TFY_RectX(rect))];
        [bezierPath addLineToPoint:CGPointMake(bottomLeftRadius + TFY_RectX(rect), TFY_RectHeight(rect) - arrowHeight + TFY_RectX(rect))];
        [bezierPath addArcWithCenter:bottomLeftArcCenter radius:bottomLeftRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectX(rect), topLeftRadius + TFY_RectX(rect))];
        [bezierPath addArcWithCenter:topLeftArcCenter radius:topLeftRadius startAngle:M_PI endAngle:M_PI * 3 / 2 clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectWidth(rect) - topRightRadius + TFY_RectX(rect), TFY_RectX(rect))];
        [bezierPath addArcWithCenter:topRightArcCenter radius:topRightRadius startAngle:M_PI * 3 / 2 endAngle:2 * M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectWidth(rect) + TFY_RectX(rect), TFY_RectHeight(rect) - bottomRightRadius - TFY_RectX(rect) - arrowHeight)];
        [bezierPath addArcWithCenter:bottomRightArcCenter radius:bottomRightRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        
    }else if (arrowDirection == PopupMenuArrowDirectionLeft) {
        topLeftArcCenter = CGPointMake(topLeftRadius + TFY_RectX(rect) + arrowHeight,topLeftRadius + TFY_RectX(rect));
        topRightArcCenter = CGPointMake(TFY_RectWidth(rect) - topRightRadius + TFY_RectX(rect), topRightRadius + TFY_RectX(rect));
        bottomLeftArcCenter = CGPointMake(bottomLeftRadius + TFY_RectX(rect) + arrowHeight, TFY_RectHeight(rect) - bottomLeftRadius + TFY_RectX(rect));
        bottomRightArcCenter = CGPointMake(TFY_RectWidth(rect) - bottomRightRadius + TFY_RectX(rect), TFY_RectHeight(rect) - bottomRightRadius + TFY_RectX(rect));
        if (arrowPosition < topLeftRadius + arrowWidth / 2) {
            arrowPosition = topLeftRadius + arrowWidth / 2;
        }else if (arrowPosition > TFY_RectHeight(rect) - bottomLeftRadius - arrowWidth / 2) {
            arrowPosition = TFY_RectHeight(rect) - bottomLeftRadius - arrowWidth / 2;
        }
        [bezierPath moveToPoint:CGPointMake(arrowHeight + TFY_RectX(rect), arrowPosition + arrowWidth / 2)];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectX(rect), arrowPosition)];
        [bezierPath addLineToPoint:CGPointMake(arrowHeight + TFY_RectX(rect), arrowPosition - arrowWidth / 2)];
        [bezierPath addLineToPoint:CGPointMake(arrowHeight + TFY_RectX(rect), topLeftRadius + TFY_RectX(rect))];
        [bezierPath addArcWithCenter:topLeftArcCenter radius:topLeftRadius startAngle:M_PI endAngle:M_PI * 3 / 2 clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectWidth(rect) - topRightRadius, TFY_RectX(rect))];
        [bezierPath addArcWithCenter:topRightArcCenter radius:topRightRadius startAngle:M_PI * 3 / 2 endAngle:2 * M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectWidth(rect) + TFY_RectX(rect), TFY_RectHeight(rect) - bottomRightRadius - TFY_RectX(rect))];
        [bezierPath addArcWithCenter:bottomRightArcCenter radius:bottomRightRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(arrowHeight + bottomLeftRadius + TFY_RectX(rect), TFY_RectHeight(rect) + TFY_RectX(rect))];
        [bezierPath addArcWithCenter:bottomLeftArcCenter radius:bottomLeftRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        
    }else if (arrowDirection == PopupMenuArrowDirectionRight) {
        topLeftArcCenter = CGPointMake(topLeftRadius + TFY_RectX(rect),topLeftRadius + TFY_RectX(rect));
        topRightArcCenter = CGPointMake(TFY_RectWidth(rect) - topRightRadius + TFY_RectX(rect) - arrowHeight, topRightRadius + TFY_RectX(rect));
        bottomLeftArcCenter = CGPointMake(bottomLeftRadius + TFY_RectX(rect), TFY_RectHeight(rect) - bottomLeftRadius + TFY_RectX(rect));
        bottomRightArcCenter = CGPointMake(TFY_RectWidth(rect) - bottomRightRadius + TFY_RectX(rect) - arrowHeight, TFY_RectHeight(rect) - bottomRightRadius + TFY_RectX(rect));
        if (arrowPosition < topRightRadius + arrowWidth / 2) {
            arrowPosition = topRightRadius + arrowWidth / 2;
        }else if (arrowPosition > TFY_RectHeight(rect) - bottomRightRadius - arrowWidth / 2) {
            arrowPosition = TFY_RectHeight(rect) - bottomRightRadius - arrowWidth / 2;
        }
        [bezierPath moveToPoint:CGPointMake(TFY_RectWidth(rect) - arrowHeight + TFY_RectX(rect), arrowPosition - arrowWidth / 2)];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectWidth(rect) + TFY_RectX(rect), arrowPosition)];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectWidth(rect) - arrowHeight + TFY_RectX(rect), arrowPosition + arrowWidth / 2)];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectWidth(rect) - arrowHeight + TFY_RectX(rect), TFY_RectHeight(rect) - bottomRightRadius - TFY_RectX(rect))];
        [bezierPath addArcWithCenter:bottomRightArcCenter radius:bottomRightRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(bottomLeftRadius + TFY_RectX(rect), TFY_RectHeight(rect) + TFY_RectX(rect))];
        [bezierPath addArcWithCenter:bottomLeftArcCenter radius:bottomLeftRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectX(rect), arrowHeight + topLeftRadius + TFY_RectX(rect))];
        [bezierPath addArcWithCenter:topLeftArcCenter radius:topLeftRadius startAngle:M_PI endAngle:M_PI * 3 / 2 clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectWidth(rect) - topRightRadius + TFY_RectX(rect) - arrowHeight, TFY_RectX(rect))];
        [bezierPath addArcWithCenter:topRightArcCenter radius:topRightRadius startAngle:M_PI * 3 / 2 endAngle:2 * M_PI clockwise:YES];
        
    }else if (arrowDirection == PopupMenuArrowDirectionNone) {
        topLeftArcCenter = CGPointMake(topLeftRadius + TFY_RectX(rect),  topLeftRadius + TFY_RectX(rect));
        topRightArcCenter = CGPointMake(TFY_RectWidth(rect) - topRightRadius + TFY_RectX(rect),  topRightRadius + TFY_RectX(rect));
        bottomLeftArcCenter = CGPointMake(bottomLeftRadius + TFY_RectX(rect), TFY_RectHeight(rect) - bottomLeftRadius + TFY_RectX(rect));
        bottomRightArcCenter = CGPointMake(TFY_RectWidth(rect) - bottomRightRadius + TFY_RectX(rect), TFY_RectHeight(rect) - bottomRightRadius + TFY_RectX(rect));
        [bezierPath moveToPoint:CGPointMake(topLeftRadius + TFY_RectX(rect), TFY_RectX(rect))];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectWidth(rect) - topRightRadius, TFY_RectX(rect))];
        [bezierPath addArcWithCenter:topRightArcCenter radius:topRightRadius startAngle:M_PI * 3 / 2 endAngle:2 * M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectWidth(rect) + TFY_RectX(rect), TFY_RectHeight(rect) - bottomRightRadius - TFY_RectX(rect))];
        [bezierPath addArcWithCenter:bottomRightArcCenter radius:bottomRightRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(bottomLeftRadius + TFY_RectX(rect), TFY_RectHeight(rect) + TFY_RectX(rect))];
        [bezierPath addArcWithCenter:bottomLeftArcCenter radius:bottomLeftRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(TFY_RectX(rect), arrowHeight + topLeftRadius + TFY_RectX(rect))];
        [bezierPath addArcWithCenter:topLeftArcCenter radius:topLeftRadius startAngle:M_PI endAngle:M_PI * 3 / 2 clockwise:YES];
    }
    
    [bezierPath closePath];
    return bezierPath;
}

@end

@interface PopupMenuCell : UITableViewCell
@property (nonatomic, assign) BOOL isShowSeparator;
@property (nonatomic, strong) UIColor * separatorColor;
@end

@implementation PopupMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _isShowSeparator = YES;
        _separatorColor = [UIColor lightGrayColor];
        [self setNeedsDisplay];
    }
    return self;
}

- (void)setIsShowSeparator:(BOOL)isShowSeparator
{
    _isShowSeparator = isShowSeparator;
    [self setNeedsDisplay];
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    _separatorColor = separatorColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (!_isShowSeparator) return;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, rect.size.height - 0.5, rect.size.width, 0.5)];
    [_separatorColor setFill];
    [bezierPath fillWithBlendMode:kCGBlendModeNormal alpha:1];
    [bezierPath closePath];
}

@end

@interface TFY_PopupMenu ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIView      * menuBackView;
@property (nonatomic) CGRect                relyRect;
@property (nonatomic, assign) CGFloat       itemWidth;
@property (nonatomic) CGPoint               point;
@property (nonatomic, assign) BOOL          isCornerChanged;
@property (nonatomic, strong) UIColor     * separatorColor;
@property (nonatomic, assign) BOOL          isChangeDirection;
@end

@implementation TFY_PopupMenu

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefaultSettings];
    }
    return self;
}

#pragma mark - publics
+ (TFY_PopupMenu *)showAtPoint:(CGPoint)point titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth delegate:(id<PopupMenuDelegate>)delegate
{
    TFY_PopupMenu *popupMenu = [[TFY_PopupMenu alloc] init];
    popupMenu.point = point;
    popupMenu.titles = titles;
    popupMenu.images = icons;
    popupMenu.itemWidth = itemWidth;
    popupMenu.delegate = delegate;
    [popupMenu show];
    return popupMenu;
}

+ (TFY_PopupMenu *)showRelyOnView:(UIView *)view titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth delegate:(id<PopupMenuDelegate>)delegate
{
    CGRect absoluteRect = [view convertRect:view.bounds toView:MainWindow];
    CGPoint relyPoint = CGPointMake(absoluteRect.origin.x + absoluteRect.size.width / 2, absoluteRect.origin.y + absoluteRect.size.height);
    TFY_PopupMenu *popupMenu = [[TFY_PopupMenu alloc] init];
    popupMenu.point = relyPoint;
    popupMenu.relyRect = absoluteRect;
    popupMenu.titles = titles;
    popupMenu.images = icons;
    popupMenu.itemWidth = itemWidth;
    popupMenu.delegate = delegate;
    [popupMenu show];
    return popupMenu;
}

+ (TFY_PopupMenu *)showAtPoint:(CGPoint)point titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth otherSettings:(void (^) (TFY_PopupMenu * popupMenu))otherSetting
{
    TFY_PopupMenu *popupMenu = [[TFY_PopupMenu alloc] init];
    popupMenu.point = point;
    popupMenu.titles = titles;
    popupMenu.images = icons;
    popupMenu.itemWidth = itemWidth;
    TFY_SAFE_BLOCK(otherSetting,popupMenu);
    [popupMenu show];
    return popupMenu;
}

+ (TFY_PopupMenu *)showRelyOnView:(UIView *)view titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth otherSettings:(void (^) (TFY_PopupMenu * popupMenu))otherSetting
{
    CGRect absoluteRect = [view convertRect:view.bounds toView:MainWindow];
    CGPoint relyPoint = CGPointMake(absoluteRect.origin.x + absoluteRect.size.width / 2, absoluteRect.origin.y + absoluteRect.size.height);
    TFY_PopupMenu *popupMenu = [[TFY_PopupMenu alloc] init];
    popupMenu.point = relyPoint;
    popupMenu.relyRect = absoluteRect;
    popupMenu.titles = titles;
    popupMenu.images = icons;
    popupMenu.itemWidth = itemWidth;
    TFY_SAFE_BLOCK(otherSetting,popupMenu);
    [popupMenu show];
    return popupMenu;
}

- (void)dismiss
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tfy_PopupMenuBeganDismiss)]) {
        [self.delegate tfy_PopupMenuBeganDismiss];
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
        self.alpha = 0;
        self.menuBackView.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tfy_PopupMenuDidDismiss)]) {
            [self.delegate tfy_PopupMenuDidDismiss];
        }
        self.delegate = nil;
        [self removeFromSuperview];
        [self.menuBackView removeFromSuperview];
    }];
}

#pragma mark tableViewDelegate & dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * tableViewCell = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tfy_PopupMenu:cellForRowAtIndex:)]) {
        tableViewCell = [self.delegate tfy_PopupMenu:self cellForRowAtIndex:indexPath.row];
    }
    if (tableViewCell) {
        return tableViewCell;
    }
    NSString * identifier = [NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row];
    PopupMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PopupMenuCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.textLabel.numberOfLines = 0;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = self.textColor;
    cell.textLabel.font = [UIFont systemFontOfSize:self.fontSize];
    if ([self.titles[indexPath.row] isKindOfClass:[NSAttributedString class]]) {
        cell.textLabel.attributedText = self.titles[indexPath.row];
    }else if ([self.titles[indexPath.row] isKindOfClass:[NSString class]]) {
        cell.textLabel.text = self.titles[indexPath.row];
    }else {
        cell.textLabel.text = nil;
    }
    cell.separatorColor = self.separatorColor;
    if (self.images.count >= indexPath.row + 1) {
        if ([self.images[indexPath.row] isKindOfClass:[NSString class]]) {
            cell.imageView.image = [UIImage imageNamed:self.images[indexPath.row]];
        }else if ([self.images[indexPath.row] isKindOfClass:[UIImage class]]){
            cell.imageView.image = self.images[indexPath.row];
        }else {
            cell.imageView.image = nil;
        }
    }else {
        cell.imageView.image = nil;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.itemHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.dismissOnSelected) [self dismiss];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tfy_PopupMenu:didSelectedAtIndex:)]) {
        [self.delegate tfy_PopupMenu:self didSelectedAtIndex:indexPath.row];
    }
}

#pragma mark - scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([[self getLastVisibleCell] isKindOfClass:[PopupMenuCell class]]) {
        PopupMenuCell *cell = [self getLastVisibleCell];
        cell.isShowSeparator = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([[self getLastVisibleCell] isKindOfClass:[PopupMenuCell class]]) {
        PopupMenuCell *cell = [self getLastVisibleCell];
        cell.isShowSeparator = NO;
    }
}

- (PopupMenuCell *)getLastVisibleCell
{
    NSArray <NSIndexPath *>*indexPaths = [self.tableView indexPathsForVisibleRows];
    indexPaths = [indexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *  _Nonnull obj1, NSIndexPath *  _Nonnull obj2) {
        return obj1.row < obj2.row;
    }];
    NSIndexPath *indexPath = indexPaths.firstObject;
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - privates
- (void)show
{
    [[self lastWindow] addSubview:self.menuBackView];
    [[self lastWindow] addSubview:self];
    if ([[self getLastVisibleCell] isKindOfClass:[PopupMenuCell class]]) {
        PopupMenuCell *cell = [self getLastVisibleCell];
        cell.isShowSeparator = NO;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(tfy_PopupMenuBeganShow)]) {
        [self.delegate tfy_PopupMenuBeganShow];
    }
    self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration: 0.25 animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(1.0, 1.0);
        self.alpha = 1;
        self.menuBackView.alpha = 1;
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tfy_PopupMenuDidShow)]) {
            [self.delegate tfy_PopupMenuDidShow];
        }
    }];
}

- (UIWindow*)lastWindow {
    NSEnumerator  *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;

        BOOL windowIsVisible = !window.hidden&& window.alpha>0;

        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= UIWindowLevelNormal);

        BOOL windowKeyWindow = window.isKeyWindow;
        
        if (windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow) {
            return window;
        }
    }
    return [UIApplication sharedApplication].keyWindow;
}


- (void)setDefaultSettings {
    self.cornerRadius = 5.0;
    self.rectCorner = UIRectCornerAllCorners;
    self.isShowShadow = YES;
    self.dismissOnSelected = YES;
    self.dismissOnTouchOutside = YES;
    self.fontSize = 15;
    self.textColor = [UIColor blackColor];
    self.offset = 0.0;
    self.relyRect = CGRectZero;
    self.point = CGPointZero;
    self.borderWidth = 0.0;
    self.borderColor = [UIColor lightGrayColor];
    self.arrowWidth = 15.0;
    self.arrowHeight = 10.0;
    self.backColor = [UIColor whiteColor];
    self.type = PopupMenuTypeDefault;
    self.arrowDirection = PopupMenuArrowDirectionTop;
    self.priorityDirection = PopupMenuPriorityDirectionTop;
    self.minSpace = 10.0;
    self.maxVisibleCount = 5;
    self.itemHeight = 44;
    self.isCornerChanged = NO;
    self.showMaskView = YES;
    self.menuBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.menuBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    self.menuBackView.alpha = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(touchOutSide)];
    [self.menuBackView addGestureRecognizer: tap];
    self.alpha = 0;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.tableView];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedSectionFooterHeight = 0.01;
        _tableView.estimatedSectionHeaderHeight = 0.01;
        _tableView.sectionHeaderHeight = 0.01;
        _tableView.sectionFooterHeight = 0.01;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.01)];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.01)];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 13.0, *)) {
            _tableView.automaticallyAdjustsScrollIndicatorInsets = NO;
        }
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
    }
    return _tableView;
}

- (void)touchOutSide
{
    if (_dismissOnTouchOutside) {
        [self dismiss];
    }
}

- (void)setIsShowShadow:(BOOL)isShowShadow {
    _isShowShadow = isShowShadow;
    self.layer.shadowOpacity = isShowShadow ? 0.5 : 0;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = isShowShadow ? 2.0 : 0;
}

- (void)setShowMaskView:(BOOL)showMaskView {
    _showMaskView = showMaskView;
    _menuBackView.backgroundColor = showMaskView ? [[UIColor blackColor] colorWithAlphaComponent:0.1] : [UIColor clearColor];
}

- (void)setType:(PopupMenuType)type {
    _type = type;
    switch (type) {
        case PopupMenuTypeDark:
        {
            _textColor = [UIColor whiteColor];
            _backColor = [UIColor colorWithRed:0.25 green:0.27 blue:0.29 alpha:1];
            _separatorColor = [UIColor lightGrayColor];
        }
            break;
            
        default:
        {
            _textColor = [UIColor blackColor];
            _backColor = [UIColor whiteColor];
            _separatorColor = [UIColor lightGrayColor];
        }
            break;
    }
    [self updateUI];
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    [self.tableView reloadData];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self.tableView reloadData];
}

- (void)setPoint:(CGPoint)point {
    _point = point;
    [self updateUI];
}

- (void)setItemWidth:(CGFloat)itemWidth {
    _itemWidth = itemWidth;
    [self updateUI];
}

- (void)setItemHeight:(CGFloat)itemHeight {
    _itemHeight = itemHeight;
    [self updateUI];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self updateUI];
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    [self updateUI];
}

- (void)setArrowPosition:(CGFloat)arrowPosition {
    _arrowPosition = arrowPosition;
    [self updateUI];
}

- (void)setArrowWidth:(CGFloat)arrowWidth {
    _arrowWidth = arrowWidth;
    [self updateUI];
}

- (void)setArrowHeight:(CGFloat)arrowHeight {
    _arrowHeight = arrowHeight;
    [self updateUI];
}

- (void)setArrowDirection:(PopupMenuArrowDirection)arrowDirection {
    _arrowDirection = arrowDirection;
    [self updateUI];
}

- (void)setMaxVisibleCount:(NSInteger)maxVisibleCount {
    _maxVisibleCount = maxVisibleCount;
    [self updateUI];
}

- (void)setBackColor:(UIColor *)backColor {
    _backColor = backColor;
    [self updateUI];
}

- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    [self updateUI];
}

- (void)setImages:(NSArray *)images {
    _images = images;
    [self updateUI];
}

- (void)setPriorityDirection:(PopupMenuPriorityDirection)priorityDirection {
    _priorityDirection = priorityDirection;
    [self updateUI];
}

- (void)setRectCorner:(UIRectCorner)rectCorner {
    _rectCorner = rectCorner;
    [self updateUI];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self updateUI];
}

- (void)setOffset:(CGFloat)offset {
    _offset = offset;
    [self updateUI];
}

- (void)updateUI {
    CGFloat height;
    if (_titles.count > _maxVisibleCount) {
        height = _itemHeight * _maxVisibleCount + _borderWidth * 2;
        self.tableView.bounces = YES;
    }else {
        height = _itemHeight * _titles.count + _borderWidth * 2;
        self.tableView.bounces = NO;
    }
     _isChangeDirection = NO;
    if (_priorityDirection == PopupMenuPriorityDirectionTop) {
        if (_point.y + height + _arrowHeight > ScreenHeight - _minSpace) {
            _arrowDirection = PopupMenuArrowDirectionBottom;
            _isChangeDirection = YES;
        }else {
            _arrowDirection = PopupMenuArrowDirectionTop;
            _isChangeDirection = NO;
        }
    }else if (_priorityDirection == PopupMenuPriorityDirectionBottom) {
        if (_point.y - height - _arrowHeight < _minSpace) {
            _arrowDirection = PopupMenuArrowDirectionTop;
            _isChangeDirection = YES;
        }else {
            _arrowDirection = PopupMenuArrowDirectionBottom;
            _isChangeDirection = NO;
        }
    }else if (_priorityDirection == PopupMenuPriorityDirectionLeft) {
        if (_point.x + _itemWidth + _arrowHeight > ScreenWidth - _minSpace) {
            _arrowDirection = PopupMenuArrowDirectionRight;
            _isChangeDirection = YES;
        }else {
            _arrowDirection = PopupMenuArrowDirectionLeft;
            _isChangeDirection = NO;
        }
    }else if (_priorityDirection == PopupMenuPriorityDirectionRight) {
        if (_point.x - _itemWidth - _arrowHeight < _minSpace) {
            _arrowDirection = PopupMenuArrowDirectionLeft;
            _isChangeDirection = YES;
        }else {
            _arrowDirection = PopupMenuArrowDirectionRight;
            _isChangeDirection = NO;
        }
    }
    [self setArrowPosition];
    [self setRelyRect];
    if (_arrowDirection == PopupMenuArrowDirectionTop) {
        CGFloat y = _isChangeDirection ? _point.y  : _point.y;
        if (_arrowPosition > _itemWidth / 2) {
            self.frame = CGRectMake(ScreenWidth - _minSpace - _itemWidth, y, _itemWidth, height + _arrowHeight);
        }else if (_arrowPosition < _itemWidth / 2) {
            self.frame = CGRectMake(_minSpace, y, _itemWidth, height + _arrowHeight);
        }else {
            self.frame = CGRectMake(_point.x - _itemWidth / 2, y, _itemWidth, height + _arrowHeight);
        }
    }else if (_arrowDirection == PopupMenuArrowDirectionBottom) {
        CGFloat y = _isChangeDirection ? _point.y - _arrowHeight - height : _point.y - _arrowHeight - height;
        if (_arrowPosition > _itemWidth / 2) {
            self.frame = CGRectMake(ScreenWidth - _minSpace - _itemWidth, y, _itemWidth, height + _arrowHeight);
        }else if (_arrowPosition < _itemWidth / 2) {
            self.frame = CGRectMake(_minSpace, y, _itemWidth, height + _arrowHeight);
        }else {
            self.frame = CGRectMake(_point.x - _itemWidth / 2, y, _itemWidth, height + _arrowHeight);
        }
    }else if (_arrowDirection == PopupMenuArrowDirectionLeft) {
        CGFloat x = _isChangeDirection ? _point.x : _point.x;
        if (_arrowPosition < _itemHeight / 2) {
            self.frame = CGRectMake(x, _point.y - _arrowPosition, _itemWidth + _arrowHeight, height);
        }else if (_arrowPosition > _itemHeight / 2) {
            self.frame = CGRectMake(x, _point.y - _arrowPosition, _itemWidth + _arrowHeight, height);
        }else {
            self.frame = CGRectMake(x, _point.y - _arrowPosition, _itemWidth + _arrowHeight, height);
        }
    }else if (_arrowDirection == PopupMenuArrowDirectionRight) {
        CGFloat x = _isChangeDirection ? _point.x - _itemWidth - _arrowHeight : _point.x - _itemWidth - _arrowHeight;
        if (_arrowPosition < _itemHeight / 2) {
            self.frame = CGRectMake(x, _point.y - _arrowPosition, _itemWidth + _arrowHeight, height);
        }else if (_arrowPosition > _itemHeight / 2) {
            self.frame = CGRectMake(x, _point.y - _arrowPosition, _itemWidth + _arrowHeight, height);
        }else {
            self.frame = CGRectMake(x, _point.y - _arrowPosition, _itemWidth + _arrowHeight, height);
        }
    }else if (_arrowDirection == PopupMenuArrowDirectionNone) {
        
    }
    
    if (_isChangeDirection) {
        [self changeRectCorner];
    }
    [self setAnchorPoint];
    [self setOffset];
    [self.tableView reloadData];
    [self setNeedsDisplay];
}

- (void)setRelyRect
{
    if (CGRectEqualToRect(_relyRect, CGRectZero)) {
        return;
    }
    if (_arrowDirection == PopupMenuArrowDirectionTop) {
        _point.y = _relyRect.size.height + _relyRect.origin.y;
    }else if (_arrowDirection == PopupMenuArrowDirectionBottom) {
        _point.y = _relyRect.origin.y;
    }else if (_arrowDirection == PopupMenuArrowDirectionLeft) {
        _point = CGPointMake(_relyRect.origin.x + _relyRect.size.width, _relyRect.origin.y + _relyRect.size.height / 2);
    }else {
        _point = CGPointMake(_relyRect.origin.x, _relyRect.origin.y + _relyRect.size.height / 2);
    }
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_arrowDirection == PopupMenuArrowDirectionTop) {
        self.tableView.frame = CGRectMake(_borderWidth, _borderWidth + _arrowHeight, frame.size.width - _borderWidth * 2, frame.size.height - _arrowHeight);
    }else if (_arrowDirection == PopupMenuArrowDirectionBottom) {
        self.tableView.frame = CGRectMake(_borderWidth, _borderWidth, frame.size.width - _borderWidth * 2, frame.size.height - _arrowHeight);
    }else if (_arrowDirection == PopupMenuArrowDirectionLeft) {
        self.tableView.frame = CGRectMake(_borderWidth + _arrowHeight, _borderWidth , frame.size.width - _borderWidth * 2 - _arrowHeight, frame.size.height);
    }else if (_arrowDirection == PopupMenuArrowDirectionRight) {
        self.tableView.frame = CGRectMake(_borderWidth , _borderWidth , frame.size.width - _borderWidth * 2 - _arrowHeight, frame.size.height);
    }
}

- (void)changeRectCorner
{
    if (_isCornerChanged || _rectCorner == UIRectCornerAllCorners) {
        return;
    }
    BOOL haveTopLeftCorner = NO, haveTopRightCorner = NO, haveBottomLeftCorner = NO, haveBottomRightCorner = NO;
    if (_rectCorner & UIRectCornerTopLeft) {
        haveTopLeftCorner = YES;
    }
    if (_rectCorner & UIRectCornerTopRight) {
        haveTopRightCorner = YES;
    }
    if (_rectCorner & UIRectCornerBottomLeft) {
        haveBottomLeftCorner = YES;
    }
    if (_rectCorner & UIRectCornerBottomRight) {
        haveBottomRightCorner = YES;
    }
    
    if (_arrowDirection == PopupMenuArrowDirectionTop || _arrowDirection == PopupMenuArrowDirectionBottom) {
        
        if (haveTopLeftCorner) {
            _rectCorner = _rectCorner | UIRectCornerBottomLeft;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerBottomLeft);
        }
        if (haveTopRightCorner) {
            _rectCorner = _rectCorner | UIRectCornerBottomRight;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerBottomRight);
        }
        if (haveBottomLeftCorner) {
            _rectCorner = _rectCorner | UIRectCornerTopLeft;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerTopLeft);
        }
        if (haveBottomRightCorner) {
            _rectCorner = _rectCorner | UIRectCornerTopRight;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerTopRight);
        }
        
    }else if (_arrowDirection == PopupMenuArrowDirectionLeft || _arrowDirection == PopupMenuArrowDirectionRight) {
        if (haveTopLeftCorner) {
            _rectCorner = _rectCorner | UIRectCornerTopRight;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerTopRight);
        }
        if (haveTopRightCorner) {
            _rectCorner = _rectCorner | UIRectCornerTopLeft;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerTopLeft);
        }
        if (haveBottomLeftCorner) {
            _rectCorner = _rectCorner | UIRectCornerBottomRight;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerBottomRight);
        }
        if (haveBottomRightCorner) {
            _rectCorner = _rectCorner | UIRectCornerBottomLeft;
        }else {
            _rectCorner = _rectCorner & (~UIRectCornerBottomLeft);
        }
    }
    
    _isCornerChanged = YES;
}

- (void)setOffset
{
    if (_itemWidth == 0) return;
    
    CGRect originRect = self.frame;
    
    if (_arrowDirection == PopupMenuArrowDirectionTop) {
        originRect.origin.y += _offset;
    }else if (_arrowDirection == PopupMenuArrowDirectionBottom) {
        originRect.origin.y -= _offset;
    }else if (_arrowDirection == PopupMenuArrowDirectionLeft) {
        originRect.origin.x += _offset;
    }else if (_arrowDirection == PopupMenuArrowDirectionRight) {
        originRect.origin.x -= _offset;
    }
    self.frame = originRect;
}

- (void)setAnchorPoint
{
    if (_itemWidth == 0) return;
    
    CGPoint point = CGPointMake(0.5, 0.5);
    if (_arrowDirection == PopupMenuArrowDirectionTop) {
        point = CGPointMake(_arrowPosition / _itemWidth, 0);
    }else if (_arrowDirection == PopupMenuArrowDirectionBottom) {
        point = CGPointMake(_arrowPosition / _itemWidth, 1);
    }else if (_arrowDirection == PopupMenuArrowDirectionLeft) {
        point = CGPointMake(0, (_itemHeight - _arrowPosition) / _itemHeight);
    }else if (_arrowDirection == PopupMenuArrowDirectionRight) {
        point = CGPointMake(1, (_itemHeight - _arrowPosition) / _itemHeight);
    }
    CGRect originRect = self.frame;
    self.layer.anchorPoint = point;
    self.frame = originRect;
}

- (void)setArrowPosition
{
    if (_priorityDirection == PopupMenuPriorityDirectionNone) {
        return;
    }
    if (_arrowDirection == PopupMenuArrowDirectionTop || _arrowDirection == PopupMenuArrowDirectionBottom) {
        if (_point.x + _itemWidth / 2 > ScreenWidth - _minSpace) {
            _arrowPosition = _itemWidth - (ScreenWidth - _minSpace - _point.x);
        }else if (_point.x < _itemWidth / 2 + _minSpace) {
            _arrowPosition = _point.x - _minSpace;
        }else {
            _arrowPosition = _itemWidth / 2;
        }
        
    }else if (_arrowDirection == PopupMenuArrowDirectionLeft || _arrowDirection == PopupMenuArrowDirectionRight) {
//        if (_point.y + _itemHeight / 2 > YBScreenHeight - _minSpace) {
//            _arrowPosition = _itemHeight - (YBScreenHeight - _minSpace - _point.y);
//        }else if (_point.y < _itemHeight / 2 + _minSpace) {
//            _arrowPosition = _point.y - _minSpace;
//        }else {
//            _arrowPosition = _itemHeight / 2;
//        }
    }
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *bezierPath = [PopupMenuPath tfy_bezierPathWithRect:rect rectCorner:_rectCorner cornerRadius:_cornerRadius borderWidth:_borderWidth borderColor:_borderColor backgroundColor:_backColor arrowWidth:_arrowWidth arrowHeight:_arrowHeight arrowPosition:_arrowPosition arrowDirection:_arrowDirection];
    [bezierPath fill];
    [bezierPath stroke];
}


@end
