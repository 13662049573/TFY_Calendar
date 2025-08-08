//
//  TFY_TextTagContent.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/5/16.
//  Copyright © 2023 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_TextTagContent : NSObject<NSCopying>

/// 必须被子类重写
- (NSAttributedString *_Nonnull)getContentAttributedString;

/// 必须被子类重写
- (id _Nonnull)copyWithZone:(NSZone *_Nullable)zone;

@end

NS_ASSUME_NONNULL_END
