//
//  TFY_WebViewPrintPageRenderer.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/4/12.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_WebViewPrintPageRenderer : UIPrintPageRenderer

- (instancetype)initFormatter:(UIPrintFormatter *)formatter contentSize:(CGSize)contentSize;

- (UIImage * _Nullable)printContentToImage;

@end

NS_ASSUME_NONNULL_END
