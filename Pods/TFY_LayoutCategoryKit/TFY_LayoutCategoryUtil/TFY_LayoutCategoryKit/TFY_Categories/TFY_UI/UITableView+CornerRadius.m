//
//  UITableView+CornerRadius.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2021/3/2.
//  Copyright © 2021 田风有. All rights reserved.
//

#import "UITableView+CornerRadius.h"
#import <objc/runtime.h>

static void *TFY_tableViewEnableCornerRadiusCellKey = &TFY_tableViewEnableCornerRadiusCellKey;

static void *TFY_tableViewConerRadiusKey = &TFY_tableViewConerRadiusKey;

static void *TFY_tableViewConerRadiusStyleKey = &TFY_tableViewConerRadiusStyleKey;

static void *TFY_tableViewCornerRadiusMaskInserts = &TFY_tableViewCornerRadiusMaskInserts;

CG_INLINE void CornerRadiusMethod(Class _class, SEL _originSelector, SEL _newSelector) {
    Method oriMethod = class_getInstanceMethod(_class, _originSelector);
    Method newMethod = class_getInstanceMethod(_class, _newSelector);
    BOOL isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}

@interface TFY_cornerRadiusModel : NSObject

@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, assign) UIRectCorner corners;

@property (nonatomic, assign) UIEdgeInsets inserts;

@end

@implementation TFY_cornerRadiusModel

+ (instancetype)modelWithRadius:(CGFloat)radius corners:(UIRectCorner)corners insets:(UIEdgeInsets)inserts {
    TFY_cornerRadiusModel *model = [[TFY_cornerRadiusModel alloc] init];
    model.corners = corners;
    model.radius = radius;
    model.inserts = inserts;
    return model;
}

@end

static void *TFY_cornerRadiusMaskKey = &TFY_cornerRadiusMaskKey;

@implementation UITableView (CornerRadius)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CornerRadiusMethod([self class], NSSelectorFromString(@"_createPreparedCellForGlobalRow:withIndexPath:willDisplay:"), @selector(tfy_createPreparedCellForGlobalRow:withIndexPath:willDisplay:));
    });
}

#pragma mark getter&setter
- (void)setTfy_cornerRadius:(CGFloat)tfy_cornerRadius {
    objc_setAssociatedObject(self, TFY_tableViewConerRadiusKey, @(tfy_cornerRadius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)tfy_cornerRadius {
    return [objc_getAssociatedObject(self, TFY_tableViewConerRadiusKey) floatValue];
}

- (void)setTfy_cornerRadiusStyle:(TFY_TableViewCornerRadiusStyle)tfy_cornerRadiusStyle {
    objc_setAssociatedObject(self, TFY_tableViewConerRadiusStyleKey, @(tfy_cornerRadiusStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TFY_TableViewCornerRadiusStyle)tfy_cornerRadiusStyle {
    return [objc_getAssociatedObject(self, TFY_tableViewConerRadiusStyleKey) integerValue];
}

- (void)setTfy_enableCornerRadiusCell:(BOOL)tfy_enableCornerRadiusCell {
    objc_setAssociatedObject(self, TFY_tableViewEnableCornerRadiusCellKey, @(tfy_enableCornerRadiusCell), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tfy_enableCornerRadiusCell {
    return [objc_getAssociatedObject(self, TFY_tableViewEnableCornerRadiusCellKey) boolValue];
}

- (void)setTfy_cornerRadiusMaskInsets:(UIEdgeInsets)tfy_cornerRadiusMaskInsets {
    objc_setAssociatedObject(self, TFY_tableViewCornerRadiusMaskInserts, [NSValue valueWithUIEdgeInsets:tfy_cornerRadiusMaskInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)tfy_cornerRadiusMaskInsets {
    return [objc_getAssociatedObject(self, TFY_tableViewCornerRadiusMaskInserts) UIEdgeInsetsValue];
}

// iOS 8 or later
- (id)tfy_createPreparedCellForGlobalRow:(int)globalRow withIndexPath:(id)indexPath willDisplay:(BOOL)p {
    id cell = [self tfy_createPreparedCellForGlobalRow:globalRow withIndexPath:indexPath willDisplay:p];
    // 获得需要被做圆角化的视图
    if ([self tfy_enableCornerRadiusCell] && [cell isKindOfClass:[UIView class]]) {
        [[cell tfy_viewForMakeCornerRadius] tfy_addRectCorner:[self tfy_cornersToRadiusForIndexPath:indexPath] radius:self.tfy_cornerRadius insets:self.tfy_cornerRadiusMaskInsets];
        // important
        [[cell tfy_viewForMakeCornerRadius] setNeedsLayout];
    }
    return cell;
}

#pragma mark private method

- (UIRectCorner)tfy_cornersToRadiusForIndexPath:(NSIndexPath *)indexPath {
    UIRectCorner corner = 0;
    switch ([self tfy_cornerRadiusStyle]) {
        case TableViewCornerRadiusStyleEveryCell:
            corner = UIRectCornerAllCorners;
            break;
        case TableViewCornerRadiusStyleSectionTopAndBottom: {
            NSUInteger countInSection = [self.dataSource tableView:self numberOfRowsInSection:indexPath.section];
            if (countInSection == 1 && indexPath.row == 0) {
                corner = UIRectCornerAllCorners;
            }
            else if (countInSection > 1) {
                
                if (indexPath.row == 0) {
                    corner = UIRectCornerTopLeft|UIRectCornerTopRight;
                }
                else if (indexPath.row == countInSection - 1) {
                    corner = UIRectCornerBottomLeft|UIRectCornerBottomRight;
                }
            }
        }
            break;
        default:
            break;
    }
    return corner;
}


@end


@implementation UIView (Radius)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CornerRadiusMethod([self class], @selector(layoutSubviews), @selector(tfy_layoutSubviews));
    });
}

- (void)tfy_addRectCorner:(UIRectCorner)corners radius:(CGFloat)radius {
    [self tfy_addRectCorner:corners radius:radius insets:UIEdgeInsetsZero];
}


- (void)tfy_addRectCorner:(UIRectCorner)corners radius:(CGFloat)radius insets:(UIEdgeInsets)inserts {
    // 如果是这两个情况则直接移除圆角化
    if ((corners == 0 || radius <= 0) && UIEdgeInsetsEqualToEdgeInsets(inserts, UIEdgeInsetsZero)) {
        [self tfy_removeCornerRadius];
        return;
    }
    
    TFY_cornerRadiusModel *oldModel = [self tfy_cornerRadius];
    
    // 判断是否跟旧的圆角化数据一样
    if (oldModel.corners == corners && oldModel.radius == radius && UIEdgeInsetsEqualToEdgeInsets(oldModel.inserts, inserts)) return;
    
    TFY_cornerRadiusModel *model = [TFY_cornerRadiusModel modelWithRadius:radius corners:corners insets:inserts];
    
    objc_setAssociatedObject(self, TFY_cornerRadiusMaskKey, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self tfy_updateCornerMaskLayer];
}

- (void)tfy_removeCornerRadius {
    [self tfy_viewForMakeCornerRadius].layer.mask = nil;
    
    objc_setAssociatedObject(self, TFY_cornerRadiusMaskKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self tfy_updateCornerMaskLayer];
}

- (TFY_cornerRadiusModel *)tfy_cornerRadius {
    return objc_getAssociatedObject(self, TFY_cornerRadiusMaskKey);
}

- (void)tfy_layoutSubviews {
    [self tfy_layoutSubviews];
    
    TFY_cornerRadiusModel *cornerModel = [self tfy_cornerRadius];
    if (cornerModel != nil) {
        [self tfy_updateCornerMaskLayer];
    }
}

- (CAShapeLayer *)maskLayerForModel:(TFY_cornerRadiusModel *)model {
    if (model == nil) return nil;
    
    CGRect bounds = self.bounds;
    
    bounds.size.width -= model.inserts.left + model.inserts.right;
    bounds.size.height -= model.inserts.top + model.inserts.bottom;
    
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:model.corners cornerRadii:CGSizeMake(model.radius, model.radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(model.inserts.left, model.inserts.top, bounds.size.width, bounds.size.height);
    maskLayer.path = maskPath.CGPath;
    return maskLayer;
}

- (void)tfy_updateCornerMaskLayer {
    self.layer.mask = [self maskLayerForModel:[self tfy_cornerRadius]];
}

- (UIView *)tfy_viewForMakeCornerRadius {
    return self;
}

@end
