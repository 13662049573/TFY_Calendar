//
//  TFY_ChainBaseModel.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#import "TFY_ChainDefine.h"

NS_ASSUME_NONNULL_BEGIN
//__covariant - 协变性，子类型可以强转到父类型（里氏替换原则）
//__contravariant - 逆变性，父类型可以强转到子类型

@interface TFY_ChainBaseModel<__covariant  ObjectType> : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

TFY_PROPERTY_STRONG_READONLY NSMutableArray *allOjects;

TFY_PROPERTY_STRONG_READONLY NSMutableArray * effectiveObjects;

//添加的数量，包括原来的创建对象的数量
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ multiple) (NSInteger count);
//第一个对象
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ part_first) (void);
//第二个对象
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ part_sencond) (void);
//第三个对象
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ part_third) (void);
//第四个对象
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ part_fourth) (void);
//第五个对象
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ part_fifth) (void);
//第六个对象
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ part_sixth) (void);
//第七个对象
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ part_seventh) (void);
//第八个对象
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ part_eighth) (void);
//第九个对象
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ part_ninth) (void);
//第十个对象
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ part_tenth) (void);
//输入第几个对象
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ part_sequence) (NSUInteger index);
//对象范围
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ part_range) (NSRange range);
//所有对象
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ part_all) (void);
//所操作对象回调
TFY_PROPERTY_CHAIN_READONLY ObjectType (^ assignToObjects)(void (^ objs) (NSArray * objs));
//遍历对象
- (void)enumerateObjectsUsingBlock:(void (^)(id _Nonnull))block;

@end

NS_ASSUME_NONNULL_END
