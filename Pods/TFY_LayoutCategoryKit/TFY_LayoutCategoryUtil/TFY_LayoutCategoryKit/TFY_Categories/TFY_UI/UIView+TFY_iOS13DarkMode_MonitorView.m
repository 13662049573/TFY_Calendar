//
//  UIView+TFY_iOS13DarkMode_MonitorView.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/2.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "UIView+TFY_iOS13DarkMode_MonitorView.h"
#import <objc/runtime.h>

@implementation UIView (TFY_iOS13DarkMode_MonitorView)
static const char * TFY_iOS13DarkMode_MonitorView_Key = "TFY_iOS13DarkMode_MonitorView_Key";

- (TFY_iOS13DarkMode_MonitorView *)tfy_iOS13DrakMove_MonitorView
{
    TFY_iOS13DarkMode_MonitorView *monitorView = objc_getAssociatedObject(self, TFY_iOS13DarkMode_MonitorView_Key);
    if (monitorView == nil) {
        monitorView = [TFY_iOS13DarkMode_MonitorView new];
        monitorView.hidden = YES;
        [self insertSubview:monitorView atIndex:0];
        objc_setAssociatedObject(self, TFY_iOS13DarkMode_MonitorView_Key, monitorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return monitorView;
}

- (void)setTfy_iOS13DrakMove_MonitorView:(TFY_iOS13DarkMode_MonitorView *)tfy_iOS13DrakMove_MonitorView
{
    TFY_iOS13DarkMode_MonitorView *old_monitorView = objc_getAssociatedObject(self, TFY_iOS13DarkMode_MonitorView_Key);
    if (tfy_iOS13DrakMove_MonitorView != old_monitorView) {
        [old_monitorView removeFromSuperview];
        tfy_iOS13DrakMove_MonitorView.hidden = YES;
        [self insertSubview:tfy_iOS13DrakMove_MonitorView atIndex:0];
        objc_setAssociatedObject(self, TFY_iOS13DarkMode_MonitorView_Key, tfy_iOS13DrakMove_MonitorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
@end
