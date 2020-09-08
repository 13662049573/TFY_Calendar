//
//  TFY_ChainBaseModel+TFY_Tools.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ChainBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_ChainBaseModel (TFY_Tools)
//初始一个对象
- (instancetype)initWithModelObject:(id)object modelClass:(Class)modelClass;
//初始对象属性数组
- (instancetype)initWithModelObjects:(NSArray *)objects modelClass:(Class)modelClass;

@end

NS_ASSUME_NONNULL_END
