//
//  TFY_ChainDefine.h
//  TFY_LayoutCategoryUtil
//
//  Created by tiandengyou on 2020/3/30.
//  Copyright © 2020 田风有. All rights reserved.
//

#ifndef TFY_ChainDefine_h
#define TFY_ChainDefine_h

#import <UIKit/UIKit.h>
#import <objc/message.h>
////动画处理
#define TFY_TansactionDisableActions(...)\
        [CATransaction begin];\
        [CATransaction setDisableActions:YES];\
        __VA_ARGS__\
        [CATransaction commit];

#pragma mark-------------------------------------------属性对象---------------------------------------------

#define TFY_PROPERTY_CHAIN_READONLY          @property (nonatomic , copy , readonly)
#define TFY_PROPERTY_STRONG_READONLY         @property (nonatomic , strong , readonly)
#define TFY_PROPERTY_ASSIGN_READONLY         @property (nonatomic , assign , readonly)

#pragma mark -------------------------------------------属性快速声明-------------------------------------------

#define TFY_PROPERTY_CHAIN                    @property (nonatomic , copy)
#define TFY_PROPERTY_STRONG                   @property (nonatomic , strong)
#define TFY_PROPERTY_ASSIGN                   @property (nonatomic , assign)
#define TFY_PROPERTY_WEAK                     @property (nonatomic , weak)
#define TFY_PROPERTY_CHAIN_BLOCK(name,...)    @property (nonatomic , copy, nullable) void (^name)(__VA_ARGS__)

#define TFY_PROPERTY_BOOL(name)                TFY_PROPERTY_ASSIGN BOOL                  name
#define TFY_PROPERTY_NSString(name)            TFY_PROPERTY_CHAIN  NSString            * name
#define TFY_PROPERTY_NSUInteger(name)          TFY_PROPERTY_ASSIGN NSUInteger            name
#define TFY_PROPERTY_NSInteger(name)           TFY_PROPERTY_ASSIGN NSInteger             name
#define TFY_PROPERTY_Float(name)               TFY_PROPERTY_ASSIGN float                 name
#define TFY_PROPERTY_LongLong(name)            TFY_PROPERTY_ASSIGN long long             name
#define TFY_PROPERTY_NSDictionary(name)        TFY_PROPERTY_STRONG NSDictionary        * name
#define TFY_PROPERTY_NSArray(name)             TFY_PROPERTY_CHAIN  NSArray * name
#define TFY_PROPERTY_NSMutableArray(name)      TFY_PROPERTY_STRONG NSMutableArray      * name
#define TFY_PROPERTY_NSData(name)              TFY_PROPERTY_STRONG NSData * name
#define TFY_PROPERTY_NSMutableDictionary(name) TFY_PROPERTY_STRONG NSMutableDictionary * name

/**快捷创建对象属性 如 (Label) (name)*/
#define TFY_PROPERTY_OBJECT_STRONG(object,name)  TFY_PROPERTY_STRONG object  * name
#define TFY_PROPERTY_OBJECT_CHAIN(object,name)   TFY_PROPERTY_CHAIN  object  * name
#define TFY_PROPERTY_OBJECT_ASSIGN(object,name)  TFY_PROPERTY_ASSIGN object    name
#define TFY_PROPERTY_OBJECT_WEAK(object,name)    TFY_PROPERTY_WEAK   object    name

/**点语法*/
#pragma mark-------------------------------------------点语法链式编程---------------------------------------------

#define TFY_CATEGORY_CHAIN_IMPLEMENTATION(TFY_Method,TFY_ParaType, TFY_ModelType, TFY_PropertyClass)\
- (TFY_ModelType  _Nonnull (^)(TFY_ParaType))TFY_Method {\
          return ^ (TFY_ParaType TFY_Method){\
                NSArray *array = self.effectiveObjects.copy;\
                for (TFY_PropertyClass * obj in array) {\
                        obj.TFY_Method = TFY_Method;\
                }\
         return self;\
    };\
}

#define TFY_CATEGORY_EXINTERFACE(TFY_Class, ModelType)\
CG_INLINE TFY_Class *TFY_Class##Set(void){\
       return [TFY_Class new];\
}\
CG_INLINE ModelType *TFY_Class##ModelSet(void){\
       return ((id (*)(id, SEL))objc_msgSend)([TFY_Class new],sel_registerName("makeChain"));\
}\
CG_INLINE ModelType *TFY_Class##NameSet(NSString *className){\
      Class clas = NSClassFromString(className);\
      if ([clas isKindOfClass:[TFY_Class class]]) {\
      return [clas new];\
      }\
    return nil;\
}\
CG_INLINE ModelType *TFY_Class##NameModelSet(NSString *className){\
      return ((id (*)(id, SEL))objc_msgSend)( TFY_Class##NameSet(className),sel_registerName("makeChain"));\
}\
TFY_CATEGORY_EXINTERFACE_(TFY_Class, ModelType)\
CG_INLINE ModelType * TFY_Class##ModelWithArray(NSArray <TFY_Class *>*objects)\
{\
    return ((id (*)(id, SEL,id,id))objc_msgSend)([ModelType alloc],sel_registerName("initWithModelObjects:modelClass:"),objects,[TFY_Class class]);\
}

#define TFY_CATEGORY_EXINTERFACE_(TFY_Class, ModelType)\
@interface TFY_Class(EXT)\
TFY_PROPERTY_CHAIN_READONLY ModelType * makeChain;\
@end


#endif /* TFY_ChainDefine_h */
