//
//  UITextView+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2020/9/3.
//  Copyright © 2020 田风有. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (TFY_Tools)
/**限制文字长度 默认 0 不显示*/
@property (nonatomic , assign)NSInteger tfy_limitNum;
/**占位文字*/
@property (nonatomic , copy) NSString * _Nonnull tfy_placeholder;
/**默认文字 这里可以按照需求更改颜色，字体，添加 富文本*/
@property (nonatomic , strong , readonly)UILabel *tfy_placeholderLabel;

@end

NS_ASSUME_NONNULL_END
