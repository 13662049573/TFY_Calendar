//
//  TFY_ModelSqlite.h
//  TFY_Model
//
//  Created by 田风有 on 2019/5/30.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

#pragma ******************************************  数据库模型处理类   ******************************************


@protocol TFY_ModelSqlite <NSObject>
@optional
/**
 自定义数据存储路径
 自定义数据库路径(目录即可)
 */
+ (NSString *)tfy_SqlitePath;

/// 自定义模型类数据库版本号
/** 注意：
 ***该返回值在改变数据模型属性类型/增加/删除属性时需要更改否则无法自动更新原来模型数据表字段以及类型***
 */
+ (NSString *)tfy_SqliteVersion;

/// 自定义数据库加密密码
/** 注意：
 ***该加密功能需要引用SQLCipher三方库才支持***
 /// 引入方式有:
 *** 手动引入 ***
 *** pod 'TFY_ModelSqliteKit/SQLCipher' ***
 */
+ (NSString *)tfy_SqlitePasswordKey;

/// 自定义数据表主键名称
/**
 *** 返回自定义主键名称默认主键:_id ***
 */
+ (NSString *)tfy_SqliteMainkey;


/**
 忽略属性集合

  返回忽略属性集合
 */
+ (NSArray *)tfy_IgnorePropertys;


/**
 引入使用其他方式创建的数据库存储路径比如:FMDB
 来使用TFY_Sqlite进行操作其他方式创建的数据库

 存储路径
 */
+ (NSString *)tfy_OtherSqlitePath;


/**
 指定自定义表名

 在指定引入其他方式创建的数据库时，这个时候如果表名不是模型类名需要实现该方法指定表名称
 
  表名
 */
+ (NSString *)tfy_TableName;

@end


@interface TFY_ModelSqlite : NSObject
/**
 * 说明: 存储模型数组到本地(事务方式)
 *  model_array 模型数组对象(model_array 里对象类型要一致)
 */

+ (BOOL)inserts:(NSArray *)model_array;

/**
 * 说明: 存储模型到本地
 *  model_object 模型对象
 */

+ (BOOL)insert:(id)model_object;


/**
 * 说明: 获取模型类表总条数
 *  model_class 模型类
 *  总条数
 */
+ (NSUInteger)count:(Class)model_class;

/**
 * 说明: 查询本地模型对象
 *  model_class 模型类
 *  查询模型对象数组
 */

+ (NSArray *)query:(Class)model_class;

/**
 * 说明: 查询本地模型对象
 *  model_class 模型类
 *  where 查询条件(查询语法和SQL where 查询语法一样，where为空则查询所有)
 *  查询模型对象数组
 */

+ (NSArray *)query:(Class)model_class where:(NSString *_Nullable)where;

/**
 * 说明: 查询本地模型对象
 *  model_class 模型类
 *  order 排序条件(排序语法和SQL order 查询语法一样，order为空则不排序)
 *  查询模型对象数组
 */

/// example: [TFY_ModelSqlite query:[Person class] order:@"by age desc/asc"];
/// 对person数据表查询并且根据age自动降序或者升序排序

+ (NSArray *)query:(Class)model_class order:(NSString *)order;

/**
 * 说明: 查询本地模型对象
 *  model_class 模型类
 *  limit 限制条件(限制语法和SQL limit 查询语法一样，limit为空则不限制查询)
 *  查询模型对象数组
 */

/// example: [TFY_ModelSqlite query:[Person class] limit:@"8"];
/// 对person数据表查询并且并且限制查询数量为8
/// example: [TFY_ModelSqlite query:[Person class] limit:@"8 offset 8"];
/// 对person数据表查询并且对查询列表偏移8并且限制查询数量为8

+ (NSArray *)query:(Class)model_class limit:(NSString *)limit;

/**
 * 说明: 查询本地模型对象
 *  model_class 模型类
 *  where 查询条件(查询语法和SQL where 查询语法一样，where为空则查询所有)
 *  order 排序条件(排序语法和SQL order 查询语法一样，order为空则不排序)
 *  查询模型对象数组
 */

/// example: [TFY_ModelSqlite query:[Person class] where:@"age < 30" order:@"by age desc/asc"];
/// 对person数据表查询age小于30岁并且根据age自动降序或者升序排序

+ (NSArray *)query:(Class)model_class where:(NSString *)where order:(NSString *)order;

/**
 * 说明: 查询本地模型对象
 *  model_class 模型类
 *  where 查询条件(查询语法和SQL where 查询语法一样，where为空则查询所有)
 *  limit 限制条件(限制语法和SQL limit 查询语法一样，limit为空则不限制查询)
 *  查询模型对象数组
 */

/// example: [TFY_ModelSqlite query:[Person class] where:@"age <= 30" limit:@"8"];
/// 对person数据表查询age小于30岁并且限制查询数量为8
/// example: [TFY_ModelSqlite query:[Person class] where:@"age <= 30" limit:@"8 offset 8"];
/// 对person数据表查询age小于30岁并且对查询列表偏移8并且限制查询数量为8

+ (NSArray *)query:(Class)model_class where:(NSString *)where limit:(NSString *)limit;

/**
 * 说明: 查询本地模型对象
 *  model_class 模型类
 *  order 排序条件(排序语法和SQL order 查询语法一样，order为空则不排序)
 *  limit 限制条件(限制语法和SQL limit 查询语法一样，limit为空则不限制查询)
 *  查询模型对象数组
 */

/// example: [TFY_ModelSqlite query:[Person class] order:@"by age desc/asc" limit:@"8"];
/// 对person数据表查询并且根据age自动降序或者升序排序并且限制查询的数量为8
/// example: [TFY_ModelSqlite query:[Person class] order:@"by age desc/asc" limit:@"8 offset 8"];
/// 对person数据表查询并且根据age自动降序或者升序排序并且限制查询的数量为8偏移为8

+ (NSArray *)query:(Class)model_class order:(NSString *)order limit:(NSString *)limit;

/**
 * 说明: 查询本地模型对象
 *  model_class 模型类
 *  where 查询条件(查询语法和SQL where 查询语法一样，where为空则查询所有)
 *  order 排序条件(排序语法和SQL order 查询语法一样，order为空则不排序)
 *  limit 限制条件(限制语法和SQL limit 查询语法一样，limit为空则不限制查询)
 *  查询模型对象数组
 */

/// example: [TFY_ModelSqlite query:[Person class] where:@"age <= 30" order:@"by age desc/asc" limit:@"8"];
/// 对person数据表查询age小于30岁并且根据age自动降序或者升序排序并且限制查询的数量为8
/// example: [TFY_ModelSqlite query:[Person class] where:@"age <= 30" order:@"by age desc/asc" limit:@"8 offset 8"];
/// 对person数据表查询age小于30岁并且根据age自动降序或者升序排序并且限制查询的数量为8偏移为8

+ (NSArray *)query:(Class)model_class where:(NSString *)where order:(NSString *)order limit:(NSString *)limit;


/**
 说明: 自定义sql查询

  model_class 接收model类
  sql sql语句
  查询模型对象数组
 
 example: [TFY_ModelSqlite query:Model.self sql:@"select cc.* from ( select tt.*,(select count(*)+1 from Chapter where chapter_id = tt.chapter_id and updateTime< tt.updateTime ) as group_id from Chapter tt) cc where cc.group_id<=7 order by updateTime desc"];
 */
+ (NSArray *)query:(Class)model_class sql:(NSString *)sql;

/**
 * 说明: 利用sqlite 函数进行查询
 
 *  model_class 要查询模型类
 *  func sqlite函数例如：（MAX(age),MIN(age),COUNT(*)....）
 *  返回查询结果(如果结果条数 > 1返回Array , = 1返回单个值 , = 0返回nil)
 * /// example: [TFY_ModelSqlite query:[Person class] sqliteFunc:@"max(age)"];  /// 获取Person表的最大age值
 * /// example: [TFY_ModelSqlite query:[Person class] sqliteFunc:@"count(*)"];  /// 获取Person表的总记录条数
 */
+ (id)query:(Class)model_class func:(NSString *)func;

/**
 * 说明: 利用sqlite 函数进行查询
 
 *  model_class 要查询模型类
 *  func sqlite函数例如：（MAX(age),MIN(age),COUNT(*)....）
 *  condition 其他查询条件例如：(where age > 20 order by age desc ....)
 *  返回查询结果(如果结果条数 > 1返回Array , = 1返回单个值 , = 0返回nil)
 * /// example: [TFY_ModelSqlite query:[Person class] sqliteFunc:@"max(age)" condition:@"where name = '北京'"];  /// 获取Person表name=北京集合中的的最大age值
 * /// example: [TFY_ModelSqlite query:[Person class] sqliteFunc:@"count(*)" condition:@"where name = '北京'"];  /// 获取Person表name=北京集合中的总记录条数
 */
+ (id)query:(Class)model_class func:(NSString *)func condition:(NSString *_Nullable)condition;

/**
 * 说明: 更新本地模型对象
 *  model_object 模型对象
 *  where 查询条件(查询语法和SQL where 查询语法一样，where为空则更新所有)
 */

+ (BOOL)update:(id)model_object where:(NSString *)where;


/**
 说明: 更新数据表字段

  model_class 模型类
  value 更新的值
  where 更新条件
  是否成功
 /// 更新Person表在age字段大于25岁是的name值为whc，age为100岁
 /// example: [TFY_ModelSqlite update:Person.self value:@"name = 'whc', age = 100" where:@"age > 25"];
 */
+ (BOOL)update:(Class)model_class value:(NSString *)value where:(NSString *)where;

/**
 * 说明: 清空本地模型对象
 *  model_class 模型类
 */

+ (BOOL)clear:(Class)model_class;


/**
 * 说明: 删除本地模型对象
 *  model_class 模型类
 *  where 查询条件(查询语法和SQL where 查询语法一样，where为空则删除所有)
 */

+ (BOOL)deletes:(Class)model_class where:(NSString *_Nullable)where;

/**
 * 说明: 清空所有本地模型数据库
 */

+ (void)removeAllModel;

/**
 * 说明: 清空指定本地模型数据库
 *  model_class 模型类
 */

+ (void)removeModel:(Class)model_class;

/**
 * 说明: 返回本地模型数据库路径
 *  model_class 模型类
 *  路径
 */

+ (NSString *)localPathWithModel:(Class)model_class;

/**
 * 说明: 返回本地模型数据库版本号
 *  model_class 模型类
 *  版本号
 */
+ (NSString *)versionWithModel:(Class)model_class;

@end


/**当存储NSArray/NSDictionary属性并且里面是自定义模型对象时，模型对象必须实现NSSecureCoding协议，可以使用TFY_SqliteModel库一行代码实现NSSecureCoding相关代码**/

///模型对象归档解归档实现
#define TFY_SqliteCodingImplementation \
- (instancetype)initWithCoder:(NSCoder *)coder\
{\
    self = [super init];\
    if (self) {\
        [self tfy_SqliteDecode:coder];\
    }\
    return self;\
}\
- (void)encodeWithCoder:(NSCoder *)coder\
{\
    [self tfy_SqliteEncode:coder];\
}\
+ (BOOL)supportsSecureCoding {\
    return YES;\
}\
- (id)copyWithZone:(NSZone *)zone { return [self tfy_SqliteCopy]; }

@protocol TFY_SqliteModelKeyValue <NSObject>
@optional
/// 模型类可自定义属性名称<json key名, 替换实际属性名>
+ (NSDictionary <NSString *, NSString *> *)tfy_SqliteModelReplacePropertyMapper;
/// 模型数组/字典元素对象可自定义类<替换实际属性名,实际类>
+ (NSDictionary <NSString *, Class> *)tfy_SqliteModelReplaceContainerElementClassMapper;
/// 模型类可自定义属性类型<替换实际属性名,实际类>
+ (NSDictionary <NSString *, Class> *)tfy_SqliteModelReplacePropertyClassMapper;

@end

@interface NSObject (TFY_SqliteModel)<TFY_SqliteModelKeyValue>
#pragma mark - json转模型对象 Api -

/** 说明:把json解析为模型对象
 * json :json数据对象
 * 模型对象
 */
+ (id)tfy_SqliteModelWithJson:(id)json;

/** 说明:把json解析为模型对象
 * json :json数据对象
 * keyPath :json key的路径
 * 模型对象
 */

+ (id)tfy_SqliteModelWithJson:(id)json keyPath:(NSString *)keyPath;


#pragma mark - 模型对象转json Api -

/** 说明:把模型对象转换为字典
 *@return 字典对象
 */

- (NSDictionary *)tfy_SqliteDictionary;

/** 说明:把模型对象转换为json字符串
 *@return json字符串
 */

- (NSString *)tfy_SqliteJson;

#pragma mark - 模型对象序列化 Api -

/// 复制模型对象
- (id)tfy_SqliteCopy;

/// 序列化模型对象
- (void)tfy_SqliteEncode:(NSCoder *)aCoder;

/// 反序列化模型对象
- (void)tfy_SqliteDecode:(NSCoder *)aDecoder;
@end

NS_ASSUME_NONNULL_END
