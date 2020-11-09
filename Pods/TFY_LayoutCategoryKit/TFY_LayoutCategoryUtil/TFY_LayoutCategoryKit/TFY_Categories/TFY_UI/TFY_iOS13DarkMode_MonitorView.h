//
//  TFY_iOS13DarkMode_MonitorView.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/11/2.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TFY_iOS13DarkMode_MonitorView_TraitCollectionCallback)(UIView *view);

@interface TFY_iOS13DarkMode_MonitorView : UIView

- (void)tfy_setTraitCollectionChange:(TFY_iOS13DarkMode_MonitorView_TraitCollectionCallback __nullable)callback forKey:(NSString *)key forObject:(id)object;

@end

NS_ASSUME_NONNULL_END
