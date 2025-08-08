//
//  TFY_ModelSqlite.m
//  TFY_Model
//
//  Created by 田风有 on 2019/5/30.
//  Copyright © 2019 恋机科技. All rights reserved.
//

#import "TFY_ModelSqlite.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import <CommonCrypto/CommonDigest.h>
#ifdef SQLITE_HAS_CODEC
#import "sqlite3.h"
#else
#import <sqlite3.h>
#endif

#pragma ******************************************  数据库模型处理类   ******************************************

static const NSString * TFY_String            = @"TEXT";
static const NSString * TFY_Int               = @"INTERGER";
static const NSString * TFY_Boolean           = @"INTERGER";
static const NSString * TFY_Double            = @"DOUBLE";
static const NSString * TFY_Float             = @"DOUBLE";
static const NSString * TFY_Char              = @"NVARCHAR";
static const NSString * TFY_Data              = @"BLOB";
static const NSString * TFY_Array             = @"BLOB";
static const NSString * TFY_Dictionary        = @"BLOB";
static const NSString * TFY_MutableArray      = @"BLOB";
static const NSString * TFY_MutableDictionary = @"BLOB";
static const NSString * TFY_Date              = @"DOUBLE";

typedef NS_OPTIONS(NSUInteger, TFY_FieldType) {
    _String,
    _Int,
    _Boolean,
    _Double,
    _Float,
    _Char,
    _Number,
    _Data,
    _Date,
    _Array,
    _Dictionary,
    _MutableArray,
    _MutableDictionary,
};

typedef NS_OPTIONS(NSUInteger, TFY_QueryType) {
    _Where,
    _Order,
    _Limit,
    _WhereOrder,
    _WhereLimit,
    _OrderLimit,
    _WhereOrderLimit
};


static sqlite3 * _tfy_database;

@interface TFY_PropertyInfo : NSObject

@property (nonatomic, assign, readonly) TFY_FieldType type;
@property (nonatomic, copy, readonly) NSString * name;
@property (nonatomic, assign, readonly) SEL setter;
@property (nonatomic, assign, readonly) SEL getter;
@end

@implementation TFY_PropertyInfo

- (TFY_PropertyInfo *)initWithType:(TFY_FieldType)type propertyName:(NSString *)property_name name:(NSString *)name{
    if (self = [super init]) {
        _name = name.mutableCopy;
        _type = type;
        if (property_name.length > 1) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[property_name substringToIndex:1].uppercaseString,[property_name substringFromIndex:1]]);
        }else {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@:",property_name.uppercaseString]);
        }
        _getter = NSSelectorFromString(property_name);
    }
    return self;
}

@end

@interface TFY_ModelSqlite ()
@property (nonatomic, strong) dispatch_semaphore_t dsema;
@property (nonatomic, assign) BOOL check_update;
@end

@implementation TFY_ModelSqlite

- (TFY_ModelSqlite *)init {
    if (self = [super init]) {
        self.dsema = dispatch_semaphore_create(1);
        self.check_update = YES;
    }
    return self;
}

+ (TFY_ModelSqlite *)shareInstance {
    static TFY_ModelSqlite * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TFY_ModelSqlite new];
    });
    return instance;
}

+ (NSString *)databaseCacheDirectory:(Class)model_class {
    if (model_class) {
        NSString * custom_path = [self exceSelector:@selector(tfy_SqlitePath) modelClass:model_class];
        if (custom_path != nil && custom_path.length > 0) {
            return custom_path;
        }
    }
    return [NSString stringWithFormat:@"%@/Library/Caches/TFYSqlite/",NSHomeDirectory()];
}

+ (TFY_FieldType)parserFieldTypeWithAttr:(NSString *)attr {
    NSArray * sub_attrs = [attr componentsSeparatedByString:@","];
    NSString * first_sub_attr = sub_attrs.firstObject;
    first_sub_attr = [first_sub_attr substringFromIndex:1];
    TFY_FieldType field_type = _String;
    const char type = *[first_sub_attr UTF8String];
    switch (type) {
        case 'B':
            field_type = _Boolean;
            break;
        case 'c':
        case 'C':
            field_type = _Char;
            break;
        case 's':
        case 'S':
        case 'i':
        case 'I':
        case 'l':
        case 'L':
        case 'q':
        case 'Q':
            field_type = _Int;
            break;
        case 'f':
            field_type = _Float;
            break;
        case 'd':
        case 'D':
            field_type = _Double;
            break;
        default:
            break;
    }
    return field_type;
}

+ (const NSString *)databaseFieldTypeWithType:(TFY_FieldType)type {
    switch (type) {
        case _String:
            return TFY_String;
        case _Int:
            return TFY_Int;
        case _Number:
            return TFY_Double;
        case _Double:
            return TFY_Double;
        case _Float:
            return TFY_Float;
        case _Char:
            return TFY_Char;
        case _Boolean:
            return TFY_Boolean;
        case _Data:
            return TFY_Data;
        case _Date:
            return TFY_Date;
        case _Array:
            return TFY_Array;
        case _Dictionary:
            return TFY_Dictionary;
        case _MutableArray:
            return TFY_MutableArray;
        case _MutableDictionary:
            return TFY_MutableDictionary;
        default:
            break;
    }
    return TFY_String;
}

+ (NSDictionary *)parserModelObjectFieldsWithModelClass:(Class)model_class {
    return [self parserSubModelObjectFieldsWithModelClass:model_class propertyName:nil complete:nil];
}

+ (NSDictionary *)parserSubModelObjectFieldsWithModelClass:(Class)model_class propertyName:(NSString *)main_property_name complete:(void(^)(NSString * key, TFY_PropertyInfo * property_object))complete {
    BOOL need_dictionary_save = !main_property_name && !complete;
    NSMutableDictionary * fields = need_dictionary_save ? [NSMutableDictionary dictionary] : nil;
    Class super_class = class_getSuperclass(model_class);
    if (super_class != nil &&
        super_class != [NSObject class]) {
        NSDictionary * super_fields = [self parserSubModelObjectFieldsWithModelClass:super_class propertyName:main_property_name complete:complete];
        if (need_dictionary_save) [fields setValuesForKeysWithDictionary:super_fields];
    }
    SEL selector = @selector(tfy_IgnorePropertys);
    NSArray * ignore_propertys;
    if ([model_class respondsToSelector:selector]) {
        IMP sqlite_info_func = [model_class methodForSelector:selector];
        NSArray * (*func)(id, SEL) = (void *)sqlite_info_func;
        ignore_propertys = func(model_class, selector);
    }
    unsigned int property_count = 0;
    objc_property_t * propertys = class_copyPropertyList(model_class, &property_count);
    for (int i = 0; i < property_count; i++) {
        objc_property_t property = propertys[i];
        const char * property_name = property_getName(property);
        const char * property_attributes = property_getAttributes(property);
        NSString * property_name_string = [NSString stringWithUTF8String:property_name];
        if ((ignore_propertys && [ignore_propertys containsObject:property_name_string]) || [property_name_string isEqualToString:@"TFYId"] ||
            [property_name_string isEqualToString:[self getMainKeyWithClass:model_class]]) {
            continue;
        }
        NSString * property_attributes_string = [NSString stringWithUTF8String:property_attributes];
        NSArray * property_attributes_list = [property_attributes_string componentsSeparatedByString:@"\""];
        NSString * name = property_name_string;
        
        if (property_name_string.length > 1) {
            if (![model_class instancesRespondToSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[property_name_string substringToIndex:1].uppercaseString,[property_name_string substringFromIndex:1]])]) {
                continue;
            }
        }else {
            if (![model_class instancesRespondToSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@:",property_name_string.uppercaseString])]) {
                continue;
            }
        }
        if (!need_dictionary_save) {
            name = [NSString stringWithFormat:@"%@$%@",main_property_name,property_name_string];
        }
        TFY_PropertyInfo * property_info = nil;
        if (property_attributes_list.count == 1) {
            // base type
            TFY_FieldType type = [self parserFieldTypeWithAttr:property_attributes_list[0]];
            property_info = [[TFY_PropertyInfo alloc] initWithType:type propertyName:property_name_string name:name];
        }else {
            // refernece type
            Class class_type = NSClassFromString(property_attributes_list[1]);
            if (class_type == [NSNumber class]) {
                property_info = [[TFY_PropertyInfo alloc] initWithType:_Number propertyName:property_name_string name:name];
            }else if (class_type == [NSString class]) {
                property_info = [[TFY_PropertyInfo alloc] initWithType:_String propertyName:property_name_string name:name];
            }else if (class_type == [NSData class]) {
                property_info = [[TFY_PropertyInfo alloc] initWithType:_Data propertyName:property_name_string name:name];
            }else if (class_type == [NSArray class]) {
                property_info = [[TFY_PropertyInfo alloc] initWithType:_Array propertyName:property_name_string name:name];
            }else if (class_type == [NSDictionary class]) {
                property_info = [[TFY_PropertyInfo alloc] initWithType:_Dictionary propertyName:property_name_string name:name];
            }else if (class_type == [NSDate class]) {
                property_info = [[TFY_PropertyInfo alloc] initWithType:_Date propertyName:property_name_string name:name];
            }else if (class_type == [NSMutableArray class]){
                property_info = [[TFY_PropertyInfo alloc] initWithType:_MutableArray propertyName:property_name_string name:name];
            }else if (class_type == [NSMutableDictionary class]){
                property_info = [[TFY_PropertyInfo alloc] initWithType:_MutableDictionary propertyName:property_name_string name:name];
            }else if (class_type == [NSSet class] ||
                      class_type == [NSValue class] ||
                      class_type == [NSError class] ||
                      class_type == [NSURL class] ||
                      class_type == [NSStream class] ||
                      class_type == [NSScanner class] ||
                      class_type == [NSException class] ||
                      class_type == [NSBundle class]) {
                [self log:@"检查模型类异常数据类型"];
            }else {
                if (need_dictionary_save) {
                    [self parserSubModelObjectFieldsWithModelClass:class_type propertyName:name complete:^(NSString * key, TFY_PropertyInfo *property_object) {
                        [fields setObject:property_object forKey:key];
                    }];
                }else {
                    [self parserSubModelObjectFieldsWithModelClass:class_type propertyName:name complete:complete];
                }
            }
        }
        if (need_dictionary_save && property_info) [fields setObject:property_info forKey:name];
        if (property_info && complete) {
            complete(name,property_info);
        }
    }
    free(propertys);
    return fields;
}

+ (BOOL)isSubModelWithClass:(Class)model_class {
    return (model_class != [NSString class] &&
            model_class != [NSNumber class] &&
            model_class != [NSArray class] &&
            model_class != [NSSet class] &&
            model_class != [NSData class] &&
            model_class != [NSDate class] &&
            model_class != [NSDictionary class] &&
            model_class != [NSValue class] &&
            model_class != [NSError class] &&
            model_class != [NSURL class] &&
            model_class != [NSStream class] &&
            model_class != [NSURLRequest class] &&
            model_class != [NSURLResponse class] &&
            model_class != [NSBundle class] &&
            model_class != [NSScanner class] &&
            model_class != [NSException class]);
}

+ (NSDictionary *)scanCommonSubModel:(id)model isClass:(BOOL)is_class {
    Class model_class = is_class ? model : [model class];
    NSMutableDictionary * sub_model_info = [NSMutableDictionary dictionary];
    Class super_class = class_getSuperclass(model_class);
    if (super_class != nil &&
        super_class != [NSObject class]) {
        [sub_model_info setValuesForKeysWithDictionary:[self scanCommonSubModel:is_class ? super_class : super_class.new isClass:is_class]];
    }
    unsigned int property_count = 0;
    objc_property_t * propertys = class_copyPropertyList(model_class, &property_count);
    for (int i = 0; i < property_count; i++) {
        objc_property_t property = propertys[i];
        const char * property_name = property_getName(property);
        const char * property_attributes = property_getAttributes(property);
        NSString * property_name_string = [NSString stringWithUTF8String:property_name];
        NSString * property_attributes_string = [NSString stringWithUTF8String:property_attributes];
        NSArray * property_attributes_list = [property_attributes_string componentsSeparatedByString:@"\""];
        if (property_attributes_list.count > 1) {
            Class class_type = NSClassFromString(property_attributes_list[1]);
            if ([self isSubModelWithClass:class_type]) {
                if (is_class) {
                    [sub_model_info setObject:property_attributes_list[1] forKey:property_name_string];
                }else {
                    id sub_model = [model valueForKey:property_name_string];
                    if (sub_model) {
                        [sub_model_info setObject:sub_model forKey:property_name_string];
                    }
                }
            }
        }
    }
    free(propertys);
    return sub_model_info;
}

+ (NSDictionary * )scanSubModelClass:(Class)model_class {
    return [self scanCommonSubModel:model_class isClass:YES];
}

+ (NSDictionary * )scanSubModelObject:(NSObject *)model_object {
    return [self scanCommonSubModel:model_object isClass:NO];
}

+ (sqlite_int64)getModelMaxIdWithClass:(Class)model_class {
    sqlite_int64 max_id = 0;
    if (_tfy_database) {
        NSString * select_sql = [NSString stringWithFormat:@"SELECT MAX(%@) AS MAXVALUE FROM %@",[self getMainKeyWithClass:model_class],[self getTableName:model_class]];
        sqlite3_stmt * pp_stmt = nil;
        if (sqlite3_prepare_v2(_tfy_database, [select_sql UTF8String], -1, &pp_stmt, nil) == SQLITE_OK) {
            while (sqlite3_step(pp_stmt) == SQLITE_ROW) {
                max_id = sqlite3_column_int64(pp_stmt, 0);
            }
        }
        sqlite3_finalize(pp_stmt);
    }
    return max_id;
}

+ (NSArray *)getModelFieldNameWithClass:(Class)model_class {
    NSMutableArray * field_name_array = [NSMutableArray array];
    if (_tfy_database) {
        NSString *sql = [NSString stringWithFormat:@"pragma table_info ('%@')",[self getTableName:model_class]];
        sqlite3_stmt *pp_stmt;
        if(sqlite3_prepare_v2(_tfy_database, [sql UTF8String], -1, &pp_stmt, NULL) == SQLITE_OK){
            while(sqlite3_step(pp_stmt) == SQLITE_ROW) {
                int cols = sqlite3_column_count(pp_stmt);
                if (cols > 1) {
                    NSString *name = [NSString stringWithCString:(const char *)sqlite3_column_text(pp_stmt, 1) encoding:NSUTF8StringEncoding];
                    [field_name_array addObject:name];
                }
            }
            sqlite3_finalize(pp_stmt);
        }
    }
    return field_name_array;
}

+ (void)updateTableFieldWithModel:(Class)model_class newVersion:(NSString *)newVersion localModelName:(NSString *)local_model_name {
    @autoreleasepool {
        NSString * table_name = [self getTableName:model_class];
        NSString * cache_directory = [self databaseCacheDirectory: model_class];
        NSString * database_cache_path = [NSString stringWithFormat:@"%@%@",cache_directory,local_model_name];
        if (sqlite3_open([database_cache_path UTF8String], &_tfy_database) == SQLITE_OK) {
            [self decryptionSqlite:model_class];
            NSArray * old_model_field_name_array = [self getModelFieldNameWithClass:model_class];
            NSDictionary * new_model_info = [self parserModelObjectFieldsWithModelClass:model_class];
            NSMutableString * delete_field_names = [NSMutableString string];
            NSMutableString * add_field_names = [NSMutableString string];
            [old_model_field_name_array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (new_model_info[obj] == nil) {
                    [delete_field_names appendString:obj];
                    [delete_field_names appendString:@","];
                }
            }];
            [new_model_info enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, TFY_PropertyInfo * obj, BOOL * _Nonnull stop) {
                if (![old_model_field_name_array containsObject:key]) {
                    [add_field_names appendFormat:@"%@ %@,",key,[self databaseFieldTypeWithType:obj.type]];
                }
            }];
            if (add_field_names.length > 0) {
                NSArray * add_field_name_array = [add_field_names componentsSeparatedByString:@","];
                [add_field_name_array enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.length > 0) {
                        NSString * add_field_name_sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@",table_name,obj];
                        [self execSql:add_field_name_sql];
                    }
                }];
            }
            if (delete_field_names.length > 0) {
                [delete_field_names deleteCharactersInRange:NSMakeRange(delete_field_names.length - 1, 1)];
                NSString * default_key = [self getMainKeyWithClass:model_class];
                if (![default_key isEqualToString:delete_field_names]) {
                    [self shareInstance].check_update = NO;
                    NSArray * old_model_data_array = [self commonQuery:model_class conditions:@[@""] queryType:_Where];
                    [self close];
                    NSFileManager * file_manager = [NSFileManager defaultManager];
                    NSString * file_path = [self localPathWithModel:model_class];
                    if (file_path) {
                        [file_manager removeItemAtPath:file_path error:nil];
                    }
                    
                    if ([self openTable:model_class]) {
                        [self execSql:@"BEGIN TRANSACTION"];
                        [old_model_data_array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [self commonInsert:obj];
                        }];
                        [self execSql:@"COMMIT"];
                        [self close];
                        return;
                    }
                }
            }
            [self close];
            NSString * new_database_cache_path = [NSString stringWithFormat:@"%@%@_v%@.sqlite",cache_directory,table_name,newVersion];
            NSFileManager * file_manager = [NSFileManager defaultManager];
            [file_manager moveItemAtPath:database_cache_path toPath:new_database_cache_path error:nil];
        }
    }
}

+ (BOOL)setKey:(NSString*)key {
    NSData *keyData = [NSData dataWithBytes:[key UTF8String] length:(NSUInteger)strlen([key UTF8String])];
    
    return [self setKeyWithData:keyData];
}

+ (BOOL)setKeyWithData:(NSData *)keyData {
#ifdef SQLITE_HAS_CODEC
    if (!keyData) {
        return NO;
    }
    
    int rc = sqlite3_key(_tfy_database, [keyData bytes], (int)[keyData length]);
    
    return (rc == SQLITE_OK);
#else
    return NO;
#endif
}

+ (BOOL)rekey:(NSString*)key {
    NSData *keyData = [NSData dataWithBytes:(void *)[key UTF8String] length:(NSUInteger)strlen([key UTF8String])];
    
    return [self rekeyWithData:keyData];
}

+ (BOOL)rekeyWithData:(NSData *)keyData {
#ifdef SQLITE_HAS_CODEC
    if (!keyData) {
        return NO;
    }
    
    int rc = sqlite3_rekey(_tfy_database, [keyData bytes], (int)[keyData length]);
    
    return (rc == SQLITE_OK);
#else
    return NO;
#endif
}

+ (NSString *)exceSelector:(SEL)selector modelClass:(Class)model_class {
    if ([model_class respondsToSelector:selector]) {
        IMP sqlite_info_func = [model_class methodForSelector:selector];
        NSString * (*func)(id, SEL) = (void *)sqlite_info_func;
        return func(model_class, selector);
    }
    return nil;
}

+ (NSString *)getMainKeyWithClass:(Class)model_class {
    NSString * main_key = [self exceSelector:@selector(tfy_SqliteMainkey) modelClass:model_class];
    if (!main_key || main_key.length == 0) {
        main_key = @"_id";
    }
    return main_key;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (NSString *)md5:(NSString *)psw {
    if (psw && psw.length > 0) {
        NSMutableString * encrypt = [NSMutableString string];
        const char * cStr = psw.UTF8String;
        unsigned char buffer[CC_MD5_DIGEST_LENGTH];
        memset(buffer, 0x00, CC_MD5_DIGEST_LENGTH);
        CC_MD5(cStr, (CC_LONG)(strlen(cStr)), buffer);
        for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            [encrypt appendFormat:@"%02x",buffer[i]];
        }
        return encrypt;
    }
    return psw;
}
#pragma clang diagnostic pop

+ (NSString *)pswWithModel:(Class)model {
    NSString * psw = nil;
    if (model) {
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        NSString * model_name = NSStringFromClass(model);
        NSData * psw_data = [ud objectForKey:[self md5:model_name]];
        if (psw_data) {
            psw = [[NSString alloc] initWithData:psw_data encoding:NSUTF8StringEncoding];
        }
    }
    return psw;
}

+ (void)saveModel:(Class)model psw:(NSString *)psw {
    if (model && psw && psw.length > 0) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
            NSString * model_name = NSStringFromClass(model);
            NSData * psw_data = [psw dataUsingEncoding:NSUTF8StringEncoding];
            [ud setObject:psw_data forKey:[self md5:model_name]];
            [ud synchronize];
        });
    }
}

+ (void)decryptionSqlite:(Class)model_class {
#ifdef SQLITE_HAS_CODEC
    NSString * psw_key = [self exceSelector:@selector(tfy_SqlitePasswordKey) modelClass:model_class];
    if (psw_key && psw_key.length > 0) {
        NSString * old_psw = [self pswWithModel:model_class];
        BOOL is_update_psw = (old_psw && ![old_psw isEqualToString:psw_key]);
        if (![self setKey:is_update_psw ? old_psw : psw_key]) {
            [self log:@"给数据库加密失败, 请引入SQLCipher库并配置SQLITE_HAS_CODEC或者pod 'TFY_ModelSqliteKit/SQLCipher'"];
        }else {
            if (is_update_psw) [self rekey:psw_key];
            [self saveModel:model_class psw:psw_key];
        }
    }
#endif
}

+ (NSString *)getTableName:(Class)model_class {
    SEL selector = @selector(tfy_TableName);
    if ([model_class respondsToSelector:selector]) {
        NSString * table_name = [self exceSelector:selector modelClass:model_class];
        if (table_name && table_name.length > 0) {
            return table_name;
        }
    }
    return NSStringFromClass(model_class);
}

+ (void)createFloder:(NSString *)path {
    BOOL is_directory = YES;
    NSFileManager * file_manager = [NSFileManager defaultManager];
    if (![file_manager fileExistsAtPath:path isDirectory:&is_directory]) {
        [file_manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (NSString *)getSqlitePath:(Class)model_class {
    SEL selector = @selector(tfy_OtherSqlitePath);
    if ([model_class respondsToSelector:selector]) {
        NSString * sqlite_path = [self exceSelector:selector modelClass:model_class];
        if (sqlite_path && sqlite_path.length > 0) {
            return sqlite_path;
        }
    }
    return nil;
}

+ (NSString *)autoHandleOldSqlite:(Class)model_class {
    NSString * cache_directory = [self databaseCacheDirectory: model_class];
    [self createFloder:cache_directory];
    NSString * sqlite_path = [self getSqlitePath:model_class];
    if (sqlite_path && sqlite_path.length > 0) {
        BOOL is_directory = NO;
        NSString * version = [self exceSelector:@selector(tfy_SqliteVersion) modelClass:model_class];
        if (!version || version.length == 0) {version = @"1.0";}
        NSString * tfy_sqlite_path = [NSString stringWithFormat:@"%@%@_v%@.sqlite",cache_directory,NSStringFromClass(model_class),version];
        NSFileManager * file_manager = [NSFileManager defaultManager];
        if ([file_manager fileExistsAtPath:sqlite_path isDirectory:&is_directory] &&
            ![file_manager fileExistsAtPath:tfy_sqlite_path isDirectory:&is_directory]) {
            [file_manager copyItemAtPath:sqlite_path toPath:tfy_sqlite_path error:nil];
        }
    }
    return cache_directory;
}

+ (BOOL)openTable:(Class)model_class {
    NSString * cache_directory = [self autoHandleOldSqlite:model_class];
    SEL VERSION = @selector(tfy_SqliteVersion);
    NSString * version = @"1.0";
    if ([model_class respondsToSelector:VERSION]) {
        version = [self exceSelector:VERSION modelClass:model_class];
        if (!version || version.length == 0) {version = @"1.0";}
        if ([self shareInstance].check_update) {
            NSString * local_model_name = [self localNameWithModel:model_class];
            if (local_model_name != nil &&
                [local_model_name rangeOfString:version].location == NSNotFound) {
                [self updateTableFieldWithModel:model_class newVersion:version localModelName:local_model_name];
            }
        }
        [self shareInstance].check_update = YES;
    }
    NSString * database_cache_path = [NSString stringWithFormat:@"%@%@_v%@.sqlite",cache_directory,NSStringFromClass(model_class),version];
    if (sqlite3_open([database_cache_path UTF8String], &_tfy_database) == SQLITE_OK) {
        [self decryptionSqlite:model_class];
        return [self createTable:model_class];
    }
    return NO;
}

+ (BOOL)createTable:(Class)model_class {
    NSString * table_name = [self getTableName:model_class];
    NSDictionary * field_dictionary = [self parserModelObjectFieldsWithModelClass:model_class];
    if (field_dictionary.count > 0) {
        NSString * main_key = [self getMainKeyWithClass:model_class];
        __block NSString * create_table_sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,",table_name,main_key];
        [field_dictionary enumerateKeysAndObjectsUsingBlock:^(NSString * field, TFY_PropertyInfo * property_info, BOOL * _Nonnull stop) {
            create_table_sql = [create_table_sql stringByAppendingFormat:@"%@ %@ DEFAULT ",field, [self databaseFieldTypeWithType:property_info.type]];
            switch (property_info.type) {
                case _Data:
                case _String:
                case _Char:
                case _Dictionary:
                case _Array:
                case _MutableArray:
                case _MutableDictionary:
                    create_table_sql = [create_table_sql stringByAppendingString:@"NULL,"];
                    break;
                case _Boolean:
                case _Int:
                    create_table_sql = [create_table_sql stringByAppendingString:@"0,"];
                    break;
                case _Float:
                case _Double:
                case _Number:
                case _Date:
                    create_table_sql = [create_table_sql stringByAppendingString:@"0.0,"];
                    break;
                default:
                    break;
            }
        }];
        create_table_sql = [create_table_sql substringWithRange:NSMakeRange(0, create_table_sql.length - 1)];
        create_table_sql = [create_table_sql stringByAppendingString:@")"];
        return [self execSql:create_table_sql];
    }
    return NO;
}

+ (BOOL)execSql:(NSString *)sql {
    BOOL result = sqlite3_exec(_tfy_database, [sql UTF8String], nil, nil, nil) == SQLITE_OK;
    if (!result) {
        [self log:[NSString stringWithFormat:@"执行失败->%@", sql]];
    }
    return result;
}

+ (BOOL)commonInsert:(id)model_object {
    sqlite3_stmt * pp_stmt = nil;
    NSDictionary * field_dictionary = [self parserModelObjectFieldsWithModelClass:[model_object class]];
    NSString * table_name = [self getTableName:[model_object class]];
    __block NSString * insert_sql = [NSString stringWithFormat:@"INSERT INTO %@ (",table_name];
    NSArray * field_array = field_dictionary.allKeys;
    NSMutableArray * value_array = [NSMutableArray array];
    NSMutableArray * insert_field_array = [NSMutableArray array];
    [field_array enumerateObjectsUsingBlock:^(NSString * field, NSUInteger idx, BOOL * _Nonnull stop) {
        TFY_PropertyInfo * property_info = field_dictionary[field];
        [insert_field_array addObject:field];
        insert_sql = [insert_sql stringByAppendingFormat:@"%@,",field];
        id value = nil;
        if ([field rangeOfString:@"$"].location == NSNotFound) {
            value = [model_object valueForKey:field];
        }else {
            value = [model_object valueForKeyPath:[field stringByReplacingOccurrencesOfString:@"$" withString:@"."]];
            if (!value) {
                switch (property_info.type) {
                    case _MutableDictionary:
                        value = [NSMutableDictionary dictionary];
                        break;
                    case _MutableArray:
                        value = [NSMutableArray array];
                        break;
                    case _Dictionary:
                        value = [NSDictionary dictionary];
                        break;
                    case _Array:
                        value = [NSArray array];
                        break;
                    case _Int:
                    case _Float:
                    case _Double:
                    case _Number:
                    case _Char:
                        value = @(0);
                        break;
                    case _Data:
                        value = [NSData data];
                        break;
                    case _Date:
                        value = [NSDate date];
                        break;
                    case _String:
                        value = @"";
                        break;
                    case _Boolean:
                        value = @(NO);
                        break;
                    default:
                        [self log:@"子模型类数据类型异常并且不能为nil"];
                        return;
                }
            }
        }
        if (value) {
            [value_array addObject:value];
        }else {
            switch (property_info.type) {
                case _MutableArray: {
                    NSData * array_value = [NSKeyedArchiver archivedDataWithRootObject:[NSMutableArray array] requiringSecureCoding:YES error:nil];
                    [value_array addObject:array_value];
                }
                    break;
                case _MutableDictionary: {
                    NSData * dictionary_value = [NSKeyedArchiver archivedDataWithRootObject:[NSMutableDictionary dictionary] requiringSecureCoding:YES error:nil];
                    [value_array addObject:dictionary_value];
                }
                    break;
                case _Array: {
                    NSData * array_value = [NSKeyedArchiver archivedDataWithRootObject:[NSArray array] requiringSecureCoding:YES error:nil];
                    [value_array addObject:array_value];
                }
                    break;
                case _Dictionary: {
                    NSData * dictionary_value = [NSKeyedArchiver archivedDataWithRootObject:[NSDictionary dictionary] requiringSecureCoding:YES error:nil];
                    [value_array addObject:dictionary_value];
                }
                    break;
                case _Data: {
                    [value_array addObject:[NSData data]];
                }
                    break;
                case _String: {
                    [value_array addObject:@""];
                }
                    break;
                case _Date:
                case _Number: {
                    [value_array addObject:@(0.0)];
                }
                    break;
                case _Int: {
                    NSNumber * value = @(((int64_t (*)(id, SEL))(void *) objc_msgSend)((id)model_object, property_info.getter));
                    [value_array addObject:value];
                }
                    break;
                case _Boolean: {
                    NSNumber * value = @(((Boolean (*)(id, SEL))(void *) objc_msgSend)((id)model_object, property_info.getter));
                    [value_array addObject:value];
                }
                    break;
                case _Char: {
                    NSNumber * value = @(((int8_t (*)(id, SEL))(void *) objc_msgSend)((id)model_object, property_info.getter));
                    [value_array addObject:value];
                }
                    break;
                case _Double: {
                    NSNumber * value = @(((double (*)(id, SEL))(void *) objc_msgSend)((id)model_object, property_info.getter));
                    [value_array addObject:value];
                }
                    break;
                case _Float: {
                    NSNumber * value = @(((float (*)(id, SEL))(void *) objc_msgSend)((id)model_object, property_info.getter));
                    [value_array addObject:value];
                }
                    break;
                default:
                    break;
            }
        }
    }];
    
    insert_sql = [insert_sql substringWithRange:NSMakeRange(0, insert_sql.length - 1)];
    insert_sql = [insert_sql stringByAppendingString:@") VALUES ("];
    
    [field_array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        insert_sql = [insert_sql stringByAppendingString:@"?,"];
    }];
    insert_sql = [insert_sql substringWithRange:NSMakeRange(0, insert_sql.length - 1)];
    insert_sql = [insert_sql stringByAppendingString:@")"];
    
    if (sqlite3_prepare_v2(_tfy_database, [insert_sql UTF8String], -1, &pp_stmt, nil) == SQLITE_OK) {
        [field_array enumerateObjectsUsingBlock:^(NSString *  _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
            TFY_PropertyInfo * property_info = field_dictionary[field];
            id value = value_array[idx];
            int index = (int)[insert_field_array indexOfObject:field] + 1;
            switch (property_info.type) {
                case _MutableDictionary:
                case _MutableArray:
                case _Dictionary:
                case _Array: {
                    @try {
                        if ([value isKindOfClass:[NSArray class]] ||
                            [value isKindOfClass:[NSDictionary class]]) {
                            NSError *error = nil;
                            NSData * data = [NSKeyedArchiver archivedDataWithRootObject:value requiringSecureCoding:YES error:nil];
                            if (error) {
                                NSLog(@"Error unarchiving data: %@", error.description);
                            }
                            sqlite3_bind_blob(pp_stmt, index, [data bytes], (int)[data length], SQLITE_TRANSIENT);
                        }else {
                            sqlite3_bind_blob(pp_stmt, index, [value bytes], (int)[value length], SQLITE_TRANSIENT);
                        }
                    } @catch (NSException *exception) {
                        [self log:[NSString stringWithFormat:@"insert 异常 Array/Dictionary类型元素未实现NSSecureCoding协议归档失败"]];
                    }
                }
                    break;
                case _Data:
                    sqlite3_bind_blob(pp_stmt, index, [value bytes], (int)[value length], SQLITE_TRANSIENT);
                    break;
                case _String:
                    if ([value respondsToSelector:@selector(UTF8String)]) {
                        sqlite3_bind_text(pp_stmt, index, [value UTF8String], -1, SQLITE_TRANSIENT);
                    }else {
                        sqlite3_bind_text(pp_stmt, index, [[NSString stringWithFormat:@"%@",value] UTF8String], -1, SQLITE_TRANSIENT);
                    }
                    break;
                case _Number:
                    sqlite3_bind_double(pp_stmt, index, [value doubleValue]);
                    break;
                case _Int:
                    sqlite3_bind_int64(pp_stmt, index, (sqlite3_int64)[value longLongValue]);
                    break;
                case _Boolean:
                    sqlite3_bind_int(pp_stmt, index, [value boolValue]);
                    break;
                case _Char:
                    sqlite3_bind_int(pp_stmt, index, [value intValue]);
                    break;
                case _Float:
                    sqlite3_bind_double(pp_stmt, index, [value floatValue]);
                    break;
                case _Double:
                    sqlite3_bind_double(pp_stmt, index, [value doubleValue]);
                    break;
                case _Date: {
                    if ([value isKindOfClass:[NSDate class]]) {
                        sqlite3_bind_double(pp_stmt, index, [(NSDate *)value timeIntervalSince1970]);
                    }else {
                        sqlite3_bind_double(pp_stmt, index, [value doubleValue]);
                    }
                }
                    break;
                default:
                    break;
            }
        }];
        sqlite3_step(pp_stmt);
        sqlite3_finalize(pp_stmt);
    }else {
        [self log:@"Sorry存储数据失败,建议检查模型类属性类型是否符合规范"];
        return NO;
    }
    return YES;
}

+ (BOOL)inserts:(NSArray *)model_array {
    __block BOOL result = YES;
    dispatch_semaphore_wait([self shareInstance].dsema, DISPATCH_TIME_FOREVER);
    @autoreleasepool {
        if (model_array != nil && model_array.count > 0) {
            if ([self openTable:[model_array.firstObject class]]) {
                [self execSql:@"BEGIN TRANSACTION"];
                [model_array enumerateObjectsUsingBlock:^(id model, NSUInteger idx, BOOL * _Nonnull stop) {
                    result = [self commonInsert:model];
                    if (!result) {*stop = YES;}
                }];
                [self execSql:@"COMMIT"];
                [self close];
            }
        }
    }
    dispatch_semaphore_signal([self shareInstance].dsema);
    return result;
}


+ (BOOL)insert:(id)model_object {
    if (model_object) {
        return [self inserts:@[model_object]];
    }
    return NO;
}

+ (id)autoNewSubmodelWithClass:(Class)model_class {
    if (model_class) {
        id model = model_class.new;
        unsigned int property_count = 0;
        objc_property_t * propertys = class_copyPropertyList(model_class, &property_count);
        for (int i = 0; i < property_count; i++) {
            objc_property_t property = propertys[i];
            const char * property_attributes = property_getAttributes(property);
            NSString * property_attributes_string = [NSString stringWithUTF8String:property_attributes];
            NSArray * property_attributes_list = [property_attributes_string componentsSeparatedByString:@"\""];
            if (property_attributes_list.count > 1) {
                // refernece type
                Class class_type = NSClassFromString(property_attributes_list[1]);
                if ([self isSubModelWithClass:class_type]) {
                    const char * property_name = property_getName(property);
                    NSString * property_name_string = [NSString stringWithUTF8String:property_name];
                    [model setValue:[self autoNewSubmodelWithClass:class_type] forKey:property_name_string];
                }
            }
        }
        free(propertys);
        return model;
    }
    return nil;
}

+ (BOOL)isNumber:(NSString *)cahr {
    int value;
    NSScanner *scan = [NSScanner scannerWithString:cahr];
    return [scan scanInt:&value] && [scan isAtEnd];
}

+ (NSString *)handleWhere:(NSString *)where {
    NSString * where_string = @"";
    if (where && where.length > 0) {
        NSArray * where_list = [where componentsSeparatedByString:@" "];
        NSMutableString * handle_where = [NSMutableString string];
        [where_list enumerateObjectsUsingBlock:^(NSString * sub_where, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange dot_range = [sub_where rangeOfString:@"."];
            if (dot_range.location != NSNotFound &&
                ![sub_where hasPrefix:@"'"] &&
                ![sub_where hasSuffix:@"'"]) {
                
                __block BOOL has_number = NO;
                NSArray * dot_sub_list = [sub_where componentsSeparatedByString:@"."];
                [dot_sub_list enumerateObjectsUsingBlock:^(NSString * dot_string, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString * before_char = nil;
                    if (dot_string.length > 0) {
                        before_char = [dot_string substringToIndex:1];
                        if ([self isNumber:before_char]) {
                            has_number = YES;
                            *stop = YES;
                        }
                    }
                }];
                if (!has_number) {
                    [handle_where appendFormat:@"%@ ",[sub_where stringByReplacingOccurrencesOfString:@"." withString:@"$"]];
                }else {
                    [handle_where appendFormat:@"%@ ",sub_where];
                }
            }else {
                [handle_where appendFormat:@"%@ ",sub_where];
            }
        }];
        if ([handle_where hasSuffix:@" "]) {
            [handle_where deleteCharactersInRange:NSMakeRange(handle_where.length - 1, 1)];
        }
        return handle_where;
    }
    return where_string;
}

+ (NSArray *)commonQuery:(Class)model_class conditions:(NSArray *)conditions queryType:(TFY_QueryType)query_type {
    NSString * table_name = [self getTableName:model_class];
    NSString * select_sql = [NSString stringWithFormat:@"SELECT * FROM %@",table_name];
    NSString * where = nil;
    NSString * order = nil;
    NSString * limit = nil;
    if (conditions != nil && conditions.count > 0) {
        switch (query_type) {
            case _Where: {
                where = [self handleWhere:conditions.firstObject];
                if (where.length > 0) {
                    select_sql = [select_sql stringByAppendingFormat:@" WHERE %@",where];
                }
            }
                break;
            case _Order: {
                order = [conditions.firstObject stringByReplacingOccurrencesOfString:@"." withString:@"$"];
                if (order.length > 0) {
                    select_sql = [select_sql stringByAppendingFormat:@" ORDER %@",order];
                }
            }
                break;
            case _Limit:
                limit = [conditions.firstObject stringByReplacingOccurrencesOfString:@"." withString:@"$"];
                if (limit.length > 0) {
                    select_sql = [select_sql stringByAppendingFormat:@" LIMIT %@",limit];
                }
                break;
            case _WhereOrder: {
                if (conditions.count > 0) {
                    where = [self handleWhere:conditions.firstObject];
                    if (where.length > 0) {
                        select_sql = [select_sql stringByAppendingFormat:@" WHERE %@",where];
                    }
                }
                if (conditions.count > 1) {
                    order = [conditions.lastObject stringByReplacingOccurrencesOfString:@"." withString:@"$"];
                    if (order.length > 0) {
                        select_sql = [select_sql stringByAppendingFormat:@" ORDER %@",order];
                    }
                }
            }
                break;
            case _WhereLimit: {
                if (conditions.count > 0) {
                    where = [self handleWhere:conditions.firstObject];
                    if (where.length > 0) {
                        select_sql = [select_sql stringByAppendingFormat:@" WHERE %@",where];
                    }
                }
                if (conditions.count > 1) {
                    limit = [conditions.lastObject stringByReplacingOccurrencesOfString:@"." withString:@"$"];
                    if (limit.length > 0) {
                        select_sql = [select_sql stringByAppendingFormat:@" LIMIT %@",limit];
                    }
                }
            }
                break;
            case _OrderLimit: {
                if (conditions.count > 0) {
                    order = [conditions.firstObject stringByReplacingOccurrencesOfString:@"." withString:@"$"];
                    if (order.length > 0) {
                        select_sql = [select_sql stringByAppendingFormat:@" ORDER %@",order];
                    }
                }
                if (conditions.count > 1) {
                    limit = [conditions.lastObject stringByReplacingOccurrencesOfString:@"." withString:@"$"];
                    if (limit.length > 0) {
                        select_sql = [select_sql stringByAppendingFormat:@" LIMIT %@",limit];
                    }
                }
            }
                break;
            case _WhereOrderLimit: {
                if (conditions.count > 0) {
                    where = [self handleWhere:conditions.firstObject];
                    if (where.length > 0) {
                        select_sql = [select_sql stringByAppendingFormat:@" WHERE %@",where];
                    }
                }
                if (conditions.count > 1) {
                    order = [conditions[1] stringByReplacingOccurrencesOfString:@"." withString:@"$"];
                    if (order.length > 0) {
                        select_sql = [select_sql stringByAppendingFormat:@" ORDER %@",order];
                    }
                }
                if (conditions.count > 2) {
                    limit = [conditions.lastObject stringByReplacingOccurrencesOfString:@"." withString:@"$"];
                    if (limit.length > 0) {
                        select_sql = [select_sql stringByAppendingFormat:@" LIMIT %@",limit];
                    }
                }
            }
                break;
            default:
                break;
        }
    }
    return [self startSqlQuery:model_class sql:select_sql];
}

+ (NSArray *)startSqlQuery:(Class)model_class sql:(NSString *)sql {
    NSDictionary * field_dictionary = [self parserModelObjectFieldsWithModelClass:model_class];
    NSMutableArray * model_object_array = [NSMutableArray array];
    sqlite3_stmt * pp_stmt = nil;
    if (sqlite3_prepare_v2(_tfy_database, [sql UTF8String], -1, &pp_stmt, nil) == SQLITE_OK) {
        int colum_count = sqlite3_column_count(pp_stmt);
        while (sqlite3_step(pp_stmt) == SQLITE_ROW) {
            id model_object = [self autoNewSubmodelWithClass:model_class];
            if (!model_object) {break;}
            SEL tfy_id_sel = NSSelectorFromString(@"setTfyId:");
            SEL custom_id_sel = nil;
            NSString * custom_id_key = [self getMainKeyWithClass:model_class];
            if (custom_id_key && custom_id_key.length > 0) {
                if (custom_id_key.length > 1) {
                    custom_id_sel = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[custom_id_key substringToIndex:1].uppercaseString,[custom_id_key substringFromIndex:1]]);
                }else {
                    custom_id_sel = NSSelectorFromString([NSString stringWithFormat:@"set%@:",custom_id_key.uppercaseString]);
                }
            }
            if (custom_id_sel && [model_object respondsToSelector:custom_id_sel]) {
                sqlite3_int64 value = sqlite3_column_int64(pp_stmt, 0);
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model_object, custom_id_sel, value);
            }
            if ([model_object respondsToSelector:tfy_id_sel]) {
                sqlite3_int64 value = sqlite3_column_int64(pp_stmt, 0);
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model_object, tfy_id_sel, value);
            }
            for (int column = 1; column < colum_count; column++) {
                NSString * field_name = [NSString stringWithCString:sqlite3_column_name(pp_stmt, column) encoding:NSUTF8StringEncoding];
                TFY_PropertyInfo * property_info = field_dictionary[field_name];
                if (property_info == nil) continue;
                id current_model_object = model_object;
                if ([field_name rangeOfString:@"$"].location != NSNotFound) {
                    NSString * handle_field_name = [field_name stringByReplacingOccurrencesOfString:@"$" withString:@"."];
                    NSRange backwards_range = [handle_field_name rangeOfString:@"." options:NSBackwardsSearch];
                    NSString * key_path = [handle_field_name substringWithRange:NSMakeRange(0, backwards_range.location)];
                    current_model_object = [model_object valueForKeyPath:key_path];
                    field_name = [handle_field_name substringFromIndex:backwards_range.length + backwards_range.location];
                    if (!current_model_object) continue;
                }
                switch (property_info.type) {
                    case _MutableArray:
                    case _MutableDictionary:
                    case _Dictionary:
                    case _Array: {
                        int length = sqlite3_column_bytes(pp_stmt, column);
                        const void * blob = sqlite3_column_blob(pp_stmt, column);
                        if (blob != NULL) {
                            NSData * value = [NSData dataWithBytes:blob length:length];
                            @try {
                                NSSet<Class> *classes = [NSSet setWithArray:@[NSObject.class]];
                                NSError *error = nil;
                                id set_value = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:value error:&error];
                                if (error) {
                                    NSLog(@"Error unarchiving data: %@", error.description);
                                }
                                if (set_value) {
                                    switch (property_info.type) {
                                        case _MutableArray:
                                            if ([set_value isKindOfClass:[NSArray class]]) {
                                                set_value = [NSMutableArray arrayWithArray:set_value];
                                            }
                                            break;
                                        case _MutableDictionary:
                                            if ([set_value isKindOfClass:[NSDictionary class]]) {
                                                set_value = [NSMutableDictionary dictionaryWithDictionary:set_value];
                                            }
                                            break;
                                        default:
                                            break;
                                    }
                                    [current_model_object setValue:set_value forKey:field_name];
                                }
                            } @catch (NSException *exception) {
                                [self log:@"query 查询异常 Array/Dictionary 元素没实现NSSecureCoding协议解归档失败"];
                            }
                        }
                    }
                        break;
                    case _Date: {
                        double value = sqlite3_column_double(pp_stmt, column);
                        if (value > 0) {
                            NSDate * date_value = [NSDate dateWithTimeIntervalSince1970:value];
                            if (date_value) {
                                [current_model_object setValue:date_value forKey:field_name];
                            }
                        }
                    }
                        break;
                    case _Data: {
                        int length = sqlite3_column_bytes(pp_stmt, column);
                        const void * blob = sqlite3_column_blob(pp_stmt, column);
                        if (blob != NULL) {
                            NSData * value = [NSData dataWithBytes:blob length:length];
                            [current_model_object setValue:value forKey:field_name];
                        }
                    }
                        break;
                    case _String: {
                        const unsigned char * text = sqlite3_column_text(pp_stmt, column);
                        if (text != NULL) {
                            NSString * value = [NSString stringWithCString:(const char *)text encoding:NSUTF8StringEncoding];
                            [current_model_object setValue:value forKey:field_name];
                        }
                    }
                        break;
                    case _Number: {
                        double value = sqlite3_column_double(pp_stmt, column);
                        [current_model_object setValue:@(value) forKey:field_name];
                    }
                        break;
                    case _Int: {
                        sqlite3_int64 value = sqlite3_column_int64(pp_stmt, column);
                        ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)current_model_object, property_info.setter, value);
                    }
                        break;
                    case _Float: {
                        double value = sqlite3_column_double(pp_stmt, column);
                        ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)current_model_object, property_info.setter, value);
                    }
                        break;
                    case _Double: {
                        double value = sqlite3_column_double(pp_stmt, column);
                        ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)current_model_object, property_info.setter, value);
                    }
                        break;
                    case _Char: {
                        int value = sqlite3_column_int(pp_stmt, column);
                        ((void (*)(id, SEL, int))(void *) objc_msgSend)((id)current_model_object, property_info.setter, value);
                    }
                        break;
                    case _Boolean: {
                        int value = sqlite3_column_int(pp_stmt, column);
                        ((void (*)(id, SEL, int))(void *) objc_msgSend)((id)current_model_object, property_info.setter, value);
                    }
                        break;
                    default:
                        break;
                }
            }
            [model_object_array addObject:model_object];
        }
    }else {
        [self log:@"Sorry查询语句异常,建议检查查询条件Sql语句语法是否正确"];
    }
    sqlite3_finalize(pp_stmt);
    return model_object_array;
}


+ (NSArray *)startQuery:(Class)model_class conditions:(NSArray *)conditions queryType:(TFY_QueryType)query_type {
    if (![self openTable:model_class]) return @[];
    NSArray * model_object_array = [self commonQuery:model_class conditions:conditions queryType:query_type];
    [self close];
    return model_object_array;
}

+ (NSArray *)queryModel:(Class)model_class conditions:(NSArray *)conditions queryType:(TFY_QueryType)query_type {
    if (![self localNameWithModel:model_class]) {return @[];}
    dispatch_semaphore_wait([self shareInstance].dsema, DISPATCH_TIME_FOREVER);
    NSArray * model_array = [self startQuery:model_class conditions:conditions queryType:query_type];
    dispatch_semaphore_signal([self shareInstance].dsema);
    return model_array;
}

+ (NSArray *)query:(Class)model_class {
    return [self query:model_class where:nil];
}

+ (NSArray *)query:(Class)model_class where:(NSString *_Nullable)where {
    return [self queryModel:model_class conditions:@[where == nil ? @"" : where] queryType:_Where];
}

+ (NSArray *)query:(Class)model_class order:(NSString *)order {
    return [self queryModel:model_class conditions:@[order == nil ? @"" : order] queryType:_Order];
}


+ (NSArray *)query:(Class)model_class limit:(NSString *)limit {
    return [self queryModel:model_class conditions:@[limit == nil ? @"" : limit] queryType:_Limit];
}

+ (NSArray *)query:(Class)model_class where:(NSString *)where order:(NSString *)order {
    return [self queryModel:model_class conditions:@[where == nil ? @"" : where,
                                                     order == nil ? @"" : order] queryType:_WhereOrder];
}

+ (NSArray *)query:(Class)model_class where:(NSString *)where limit:(NSString *)limit {
    return [self queryModel:model_class conditions:@[where == nil ? @"" : where,
                                                     limit == nil ? @"" : limit] queryType:_WhereLimit];
}

+ (NSArray *)query:(Class)model_class order:(NSString *)order limit:(NSString *)limit {
    return [self queryModel:model_class conditions:@[order == nil ? @"" : order,
                                                     limit == nil ? @"" : limit] queryType:_OrderLimit];
}

+ (NSArray *)query:(Class)model_class where:(NSString *)where order:(NSString *)order limit:(NSString *)limit {
    return [self queryModel:model_class conditions:@[where == nil ? @"" : where,
                                                     order == nil ? @"" : order,
                                                     limit == nil ? @"" : limit] queryType:_WhereOrderLimit];
}

+ (NSArray *)query:(Class)model_class sql:(NSString *)sql {
    if (sql && sql.length > 0) {
        if (![self localNameWithModel:model_class]) {return @[];}
        dispatch_semaphore_wait([self shareInstance].dsema, DISPATCH_TIME_FOREVER);
        if (![self openTable:model_class]) return @[];
        NSArray * model_object_array = [self startSqlQuery:model_class sql:sql];
        [self close];
        dispatch_semaphore_signal([self shareInstance].dsema);
        return model_object_array;
    }
    [self log:@"sql 查询语句不能为空"];
    return @[];
}

+ (NSUInteger)count:(Class)model_class {
    NSNumber * count = [self query:model_class func:@"count(*)"];
    return count ? count.unsignedIntegerValue : 0;
}

+ (id)query:(Class)model_class func:(NSString *)func {
    return [self query:model_class func:func condition:nil];
}

+ (id)query:(Class)model_class func:(NSString *)func condition:(NSString * _Nullable)condition {
    if (![self localNameWithModel:model_class]) {return nil;}
    dispatch_semaphore_wait([self shareInstance].dsema, DISPATCH_TIME_FOREVER);
    if (![self openTable:model_class]) return @[];
    NSMutableArray * result_array = [NSMutableArray array];
    @autoreleasepool {
        NSString * table_name = [self getTableName:model_class];
        if (func == nil || func.length == 0) {
            [self log:@"发现错误 Sqlite Func 不能为空"];
            return nil;
        }
        if (condition == nil) {
            condition = @"";
        }else {
            condition = [self handleWhere:condition];
        }
        NSString * select_sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ %@",func,table_name,condition];
        sqlite3_stmt * pp_stmt = nil;
        if (sqlite3_prepare_v2(_tfy_database, [select_sql UTF8String], -1, &pp_stmt, nil) == SQLITE_OK) {
            int colum_count = sqlite3_column_count(pp_stmt);
            while (sqlite3_step(pp_stmt) == SQLITE_ROW) {
                NSMutableArray * row_result_array = [NSMutableArray array];
                for (int column = 0; column < colum_count; column++) {
                    int column_type = sqlite3_column_type(pp_stmt, column);
                    switch (column_type) {
                        case SQLITE_INTEGER: {
                            sqlite3_int64 value = sqlite3_column_int64(pp_stmt, column);
                            [row_result_array addObject:@(value)];
                        }
                            break;
                        case SQLITE_FLOAT: {
                            double value = sqlite3_column_double(pp_stmt, column);
                            [row_result_array addObject:@(value)];
                        }
                            break;
                        case SQLITE_TEXT: {
                            const unsigned char * text = sqlite3_column_text(pp_stmt, column);
                            if (text != NULL) {
                                NSString * value = [NSString stringWithCString:(const char *)text encoding:NSUTF8StringEncoding];
                                [row_result_array addObject:value];
                            }
                        }
                            break;
                        case SQLITE_BLOB: {
                            int length = sqlite3_column_bytes(pp_stmt, column);
                            const void * blob = sqlite3_column_blob(pp_stmt, column);
                            if (blob != NULL) {
                                NSData * value = [NSData dataWithBytes:blob length:length];
                                [row_result_array addObject:value];
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }
                if (row_result_array.count > 0) {
                    [result_array addObject:row_result_array];
                }
            }
            sqlite3_finalize(pp_stmt);
        }else {
            [self log:@"Sorry 查询失败, 建议检查sqlite 函数书写格式是否正确！"];
        }
        [self close];
        if (result_array.count > 0) {
            NSMutableDictionary * handle_result_dict = [NSMutableDictionary dictionary];
            [result_array enumerateObjectsUsingBlock:^(NSArray * row_result_array, NSUInteger idx, BOOL * _Nonnull stop) {
                [row_result_array enumerateObjectsUsingBlock:^(id _Nonnull column_value, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString * column_array_key = @(idx).stringValue;
                    NSMutableArray * column_value_array = handle_result_dict[column_array_key];
                    if (!column_value_array) {
                        column_value_array = [NSMutableArray array];
                        handle_result_dict[column_array_key] = column_value_array;
                    }
                    [column_value_array addObject:column_value];
                }];
            }];
            NSArray * all_keys = handle_result_dict.allKeys;
            NSArray * handle_column_array_key = [all_keys sortedArrayUsingComparator:^NSComparisonResult(NSString * key1, NSString * key2) {
                NSComparisonResult result = [key1 compare:key2];
                return result == NSOrderedDescending ? NSOrderedAscending : result;
            }];
            [result_array removeAllObjects];
            if (handle_column_array_key) {
                [handle_column_array_key enumerateObjectsUsingBlock:^(NSString * key, NSUInteger idx, BOOL * _Nonnull stop) {
                    [result_array addObject:handle_result_dict[key]];
                }];
            }
        }
    }
    dispatch_semaphore_signal([self shareInstance].dsema);
    if (result_array.count == 1) {
        NSArray * element = result_array.firstObject;
        if (element.count > 1){
            return element;
        }
        return element.firstObject;
    }else if (result_array.count > 1) {
        return result_array;
    }
    return nil;
}

+ (BOOL)updateModel:(id)model_object where:(NSString *)where {
    if (model_object == nil) return NO;
    Class model_class = [model_object class];
    if (![self openTable:model_class]) return NO;
    sqlite3_stmt * pp_stmt = nil;
    NSDictionary * field_dictionary = [self parserModelObjectFieldsWithModelClass:model_class];
    NSString * table_name = [self getTableName:model_class];
    __block NSString * update_sql = [NSString stringWithFormat:@"UPDATE %@ SET ",table_name];
    
    NSArray * field_array = field_dictionary.allKeys;
    NSMutableArray * update_field_array = [NSMutableArray array];
    [field_array enumerateObjectsUsingBlock:^(id  _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
        update_sql = [update_sql stringByAppendingFormat:@"%@ = ?,",field];
        [update_field_array addObject:field];
    }];
    update_sql = [update_sql substringWithRange:NSMakeRange(0, update_sql.length - 1)];
    if (where != nil && where.length > 0) {
        update_sql = [update_sql stringByAppendingFormat:@" WHERE %@", [self handleWhere:where]];
    }
    if (sqlite3_prepare_v2(_tfy_database, [update_sql UTF8String], -1, &pp_stmt, nil) == SQLITE_OK) {
        [field_array enumerateObjectsUsingBlock:^(id  _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
            TFY_PropertyInfo * property_info = field_dictionary[field];
            id current_model_object = model_object;
            NSString * actual_field = field;
            if ([field rangeOfString:@"$"].location != NSNotFound) {
                NSString * handle_field_name = [field stringByReplacingOccurrencesOfString:@"$" withString:@"."];
                NSRange backwards_range = [handle_field_name rangeOfString:@"." options:NSBackwardsSearch];
                NSString * key_path = [handle_field_name substringWithRange:NSMakeRange(0, backwards_range.location)];
                current_model_object = [model_object valueForKeyPath:key_path];
                actual_field = [handle_field_name substringFromIndex:backwards_range.location + backwards_range.length];
                if (!current_model_object) {*stop = YES;}
            }
            int index = (int)[update_field_array indexOfObject:field] + 1;
            switch (property_info.type) {
                case _MutableDictionary:
                case _MutableArray: {
                    id value = [current_model_object valueForKey:actual_field];
                    if (value == nil) {
                        value = property_info.type == _MutableDictionary ? [NSMutableDictionary dictionary] : [NSMutableArray array];
                    }
                    @try {
                        NSData * set_value = [NSKeyedArchiver archivedDataWithRootObject:value requiringSecureCoding:YES error:nil];
                        sqlite3_bind_blob(pp_stmt, index, [set_value bytes], (int)[set_value length], SQLITE_TRANSIENT);
                    } @catch (NSException *exception) {
                        [self log:@"update 操作异常 Array/Dictionary 元素没实现NSSecureCoding协议归档失败"];
                    }
                }
                    break;
                case _Dictionary:
                case _Array: {
                    id value = [current_model_object valueForKey:actual_field];
                    if (value == nil) {
                        value = property_info.type == _Dictionary ? [NSDictionary dictionary] : [NSArray array];
                    }
                    @try {
                        NSError *error = nil;
                        NSData * set_value = [NSKeyedArchiver archivedDataWithRootObject:value requiringSecureCoding:YES error:nil];
                        if (error) {
                            NSLog(@"Error unarchiving data: %@", error.description);
                        }
                        sqlite3_bind_blob(pp_stmt, index, [set_value bytes], (int)[set_value length], SQLITE_TRANSIENT);
                    } @catch (NSException *exception) {
                        [self log:@"update 操作异常 Array/Dictionary 元素没实现NSSecureCoding协议归档失败"];
                    }
                }
                    break;
                case _Date: {
                    NSDate * value = [current_model_object valueForKey:actual_field];
                    if (value == nil) {
                        sqlite3_bind_double(pp_stmt, index, 0.0);
                    }else {
                        sqlite3_bind_double(pp_stmt, index, [value timeIntervalSince1970]);
                    }
                }
                    break;
                case _Data: {
                    NSData * value = [current_model_object valueForKey:actual_field];
                    if (value == nil) {
                        value = [NSData data];
                    }
                    sqlite3_bind_blob(pp_stmt, index, [value bytes], (int)[value length], SQLITE_TRANSIENT);
                }
                    break;
                case _String: {
                    NSString * value = [current_model_object valueForKey:actual_field];
                    if (value == nil) {
                        value = @"";
                    }
                    if ([value respondsToSelector:@selector(UTF8String)]) {
                        sqlite3_bind_text(pp_stmt, index, [value UTF8String], -1, SQLITE_TRANSIENT);
                    }else {
                        sqlite3_bind_text(pp_stmt, index, [[NSString stringWithFormat:@"%@",value] UTF8String], -1, SQLITE_TRANSIENT);
                    }
                }
                    break;
                case _Number: {
                    NSNumber * value = [current_model_object valueForKey:actual_field];
                    if (value == nil) {
                        value = @(0.0);
                    }
                    sqlite3_bind_double(pp_stmt, index, [value doubleValue]);
                }
                    break;
                case _Int: {
                    /* 32bit os type issue
                     long value = ((long (*)(id, SEL))(void *) objc_msgSend)((id)sub_model_object, property_info.getter);*/
                    NSNumber * value = [current_model_object valueForKey:actual_field];
                    sqlite3_bind_int64(pp_stmt, index, (sqlite3_int64)[value longLongValue]);
                }
                    break;
                case _Char: {
                    char value = ((char (*)(id, SEL))(void *) objc_msgSend)((id)current_model_object, property_info.getter);
                    sqlite3_bind_int(pp_stmt, index, value);
                }
                    break;
                case _Float: {
                    float value = ((float (*)(id, SEL))(void *) objc_msgSend)((id)current_model_object, property_info.getter);
                    sqlite3_bind_double(pp_stmt, index, value);
                }
                    break;
                case _Double: {
                    double value = ((double (*)(id, SEL))(void *) objc_msgSend)((id)current_model_object, property_info.getter);
                    sqlite3_bind_double(pp_stmt, index, value);
                }
                    break;
                case _Boolean: {
                    BOOL value = ((BOOL (*)(id, SEL))(void *) objc_msgSend)((id)current_model_object, property_info.getter);
                    sqlite3_bind_int(pp_stmt, index, value);
                }
                    break;
                default:
                    break;
            }
        }];
        sqlite3_step(pp_stmt);
        sqlite3_finalize(pp_stmt);
    }else {
        [self log:@"更新失败"];
        [self close];
        return NO;
    }
    [self close];
    return YES;
}

+ (BOOL)update:(id)model_object where:(NSString *)where {
    BOOL result = YES;
    if ([self localNameWithModel:[model_object class]]) {
        dispatch_semaphore_wait([self shareInstance].dsema, DISPATCH_TIME_FOREVER);
        @autoreleasepool {
            result = [self updateModel:model_object where:where];
        }
        dispatch_semaphore_signal([self shareInstance].dsema);
    }else {
        result = NO;
    }
    return result;
}

+ (BOOL)update:(Class)model_class value:(NSString *)value where:(NSString *)where {
    if (model_class == nil) return NO;
    BOOL result = YES;
    if ([self localNameWithModel:model_class]) {
        dispatch_semaphore_wait([self shareInstance].dsema, DISPATCH_TIME_FOREVER);
        @autoreleasepool {
            if (value != nil && value.length > 0) {
                if ([self openTable:model_class]) {
                    NSString * table_name = [self getTableName:model_class];
                    NSString * update_sql = [NSString stringWithFormat:@"UPDATE %@ SET %@",table_name,value];
                    if (where != nil && where.length > 0) {
                        update_sql = [update_sql stringByAppendingFormat:@" WHERE %@", [self handleWhere:where]];
                    }
                    result = [self execSql:update_sql];
                    [self close];
                }else {
                    result = NO;
                }
            }else {
                result = NO;
            }
        }
        dispatch_semaphore_signal([self shareInstance].dsema);
    }else {
        result = NO;
    }
    return result;
}

+ (BOOL)clear:(Class)model_class {
    return [self deletes:model_class where:nil];
}

+ (BOOL)commonDeleteModel:(Class)model_class where:(NSString *_Nullable)where {
    BOOL result = YES;
    if ([self localNameWithModel:model_class]) {
        if ([self openTable:model_class]) {
            NSString * table_name = [self getTableName:model_class];
            NSString * delete_sql = [NSString stringWithFormat:@"DELETE FROM %@",table_name];
            if (where != nil && where.length > 0) {
                delete_sql = [delete_sql stringByAppendingFormat:@" WHERE %@",[self handleWhere:where]];
            }
            result = [self execSql:delete_sql];
            [self close];
        }else {
            result = NO;
        }
    }else {
        result = NO;
    }
    return result;
}

+ (BOOL)deletes:(Class)model_class where:(NSString *_Nullable)where {
    BOOL result = YES;
    dispatch_semaphore_wait([self shareInstance].dsema, DISPATCH_TIME_FOREVER);
    @autoreleasepool {
        result = [self commonDeleteModel:model_class where:where];
    }
    dispatch_semaphore_signal([self shareInstance].dsema);
    return result;
}

+ (void)close {
    if (_tfy_database) {
        sqlite3_close(_tfy_database);
        _tfy_database = nil;
    }
}

+ (void)removeAllModel {
    dispatch_semaphore_wait([self shareInstance].dsema, DISPATCH_TIME_FOREVER);
    @autoreleasepool {
        NSFileManager * file_manager = [NSFileManager defaultManager];
        NSString * cache_path = [self databaseCacheDirectory: nil];
        BOOL is_directory = YES;
        if ([file_manager fileExistsAtPath:cache_path isDirectory:&is_directory]) {
            NSArray * file_array = [file_manager contentsOfDirectoryAtPath:cache_path error:nil];
            [file_array enumerateObjectsUsingBlock:^(id  _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![file isEqualToString:@".DS_Store"]) {
                    NSString * file_path = [NSString stringWithFormat:@"%@%@",cache_path,file];
                    [file_manager removeItemAtPath:file_path error:nil];
                    [self log:[NSString stringWithFormat:@"已经删除了数据库 ->%@",file_path]];
                }
            }];
        }
    }
    dispatch_semaphore_signal([self shareInstance].dsema);
}

+ (void)removeModel:(Class)model_class {
    dispatch_semaphore_wait([self shareInstance].dsema, DISPATCH_TIME_FOREVER);
    @autoreleasepool {
        NSFileManager * file_manager = [NSFileManager defaultManager];
        NSString * file_path = [self localPathWithModel:model_class];
        if (file_path) {
            [file_manager removeItemAtPath:file_path error:nil];
        }
    }
    dispatch_semaphore_signal([self shareInstance].dsema);
}

+ (NSString *)commonLocalPathWithModel:(Class)model_class isPath:(BOOL)isPath {
    NSString * class_name = NSStringFromClass(model_class);
    NSFileManager * file_manager = [NSFileManager defaultManager];
    NSString * file_directory = [self databaseCacheDirectory: model_class];
    BOOL isDirectory = YES;
    __block NSString * file_path = nil;
    if ([file_manager fileExistsAtPath:file_directory isDirectory:&isDirectory]) {
        NSArray <NSString *> * file_name_array = [file_manager contentsOfDirectoryAtPath:file_directory error:nil];
        if (file_name_array != nil && file_name_array.count > 0) {
            [file_name_array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj rangeOfString:class_name].location != NSNotFound) {
                    if (isPath) {
                        file_path = [NSString stringWithFormat:@"%@%@",file_directory,obj];
                    }else {
                        file_path = [obj mutableCopy];
                    }
                    *stop = YES;
                }
            }];
        }
    }
    return file_path;
}

+ (NSString *)localNameWithModel:(Class)model_class {
    return [self commonLocalPathWithModel:model_class isPath:NO];
}

+ (NSString *)localPathWithModel:(Class)model_class {
    return [self commonLocalPathWithModel:model_class isPath:YES];
}

+ (NSString *)versionWithModel:(Class)model_class {
    NSString * model_version = nil;
    NSString * model_name = [self localNameWithModel:model_class];
    if (model_name) {
        NSRange end_range = [model_name rangeOfString:@"." options:NSBackwardsSearch];
        NSRange start_range = [model_name rangeOfString:@"v" options:NSBackwardsSearch];
        if (end_range.location != NSNotFound &&
            start_range.location != NSNotFound) {
            model_version = [model_name substringWithRange:NSMakeRange(start_range.length + start_range.location, end_range.location - (start_range.length + start_range.location))];
        }
    }
    return model_version;
}

+ (void)log:(NSString *)msg {
    NSLog(@"TFY_ModelSqlite:[%@]",msg);
}

@end


/**当存储NSArray/NSDictionary属性并且里面是自定义模型对象时，模型对象必须实现NSSecureCoding协议，可以使用TFY_SqliteModel库一行代码实现NSSecureCoding相关代码**/

typedef NS_OPTIONS(NSUInteger, TFY_SqliteTYPE) {
    _SqliteArray = 1 << 0,
    _SqliteDictionary = 1 << 1,
    _SqliteString = 1 << 2,
    _SqliteInteger = 1 << 3,
    _SqliteUInteger = 1 << 4,
    _SqliteFloat = 1 << 5,
    _SqliteDouble = 1 << 6,
    _SqliteBoolean = 1 << 7,
    _SqliteChar = 1 << 8,
    _SqliteNumber = 1 << 9,
    _SqliteNull = 1 << 10,
    _SqliteModel = 1 << 11,
    _SqliteData = 1 << 12,
    _SqliteDate = 1 << 13,
    _SqliteValue = 1 << 14,
    _SqliteUrl = 1 << 15,
    _SqliteSet = 1 << 16,
    _SqliteUnknown = 1 << 17
};

@interface TFY_SqliteModelPropertyInfo : NSObject {
@public
    Class class;
    TFY_SqliteTYPE type;
    SEL setter;
    SEL getter;
}
@end
@implementation TFY_SqliteModelPropertyInfo

- (void)setClass:(Class)_class valueClass:(Class)valueClass {
    class = _class;
    if (class == nil) {
        type = _SqliteNull;
        return;
    }
    if ([class isSubclassOfClass:[NSString class]]) {type = _SqliteString;}
    else if ([class isSubclassOfClass:[NSDictionary class]]) {type = _SqliteDictionary;}
    else if ([valueClass isSubclassOfClass:[NSDictionary class]]) {type = _SqliteModel;}
    else if ([class isSubclassOfClass:[NSArray class]]) {type = _SqliteArray;}
    else if ([class isSubclassOfClass:[NSNumber class]]) {type = _SqliteNumber;}
    else if ([class isSubclassOfClass:[NSDate class]]) {type = _SqliteDate;}
    else if ([class isSubclassOfClass:[NSValue class]]) {type = _SqliteValue;}
    else if ([class isSubclassOfClass:[NSData class]]) {type = _SqliteData;}
    else {type = _SqliteUnknown;}
}

- (instancetype)init {
    self = [super init];
    if (self) {
        type = _SqliteUnknown;
    }
    return self;
}

@end

@implementation NSObject (TFY_SqliteModel)

#pragma mark - 枚举类属性列表 -

+ (void)tfy_SqliteEnumeratePropertyNameUsingBlock:(void (NS_NOESCAPE ^)(NSString * propertyName, NSUInteger index, BOOL * stop))block {
    unsigned int propertyCount = 0;
    BOOL stop = NO;
    objc_property_t * properties = class_copyPropertyList(self, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        block([NSString stringWithUTF8String:name],i,&stop);
        if (stop) break;
    }
    free(properties);
}

+ (void)tfy_SqliteEnumeratePropertyAttributesUsingBlock:(void (NS_NOESCAPE ^)(NSString * propertyName,objc_property_t property, NSUInteger index, BOOL * stop))block {
    unsigned int propertyCount = 0;
    BOOL stop = NO;
    objc_property_t * properties = class_copyPropertyList(self, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        block([NSString stringWithUTF8String:name],property,i,&stop);
        if (stop) break;
    }
    free(properties);
}

#pragma mark - 模型对象序列化 Api -

- (void)copySuperObject:(id)newSelf {
    Class superClass = class_getSuperclass(self.class);
    if (superClass != nil &&
        superClass != [NSObject class]) {
        NSObject * superObject = superClass.new;
        [superClass tfy_SqliteEnumeratePropertyNameUsingBlock:^(NSString *propertyName, NSUInteger index, BOOL *stop) {
            [superObject setValue:[self valueForKey:propertyName] forKey:propertyName];
            [newSelf setValue:[self valueForKey:propertyName] forKey:propertyName];
        }];
        [superObject copySuperObject:newSelf];
    }
}

- (id)tfy_SqliteCopy {
    id newSelf = self.class.new;
    [self copySuperObject:newSelf];
    [self.class tfy_SqliteEnumeratePropertyAttributesUsingBlock:^(NSString *propertyName, objc_property_t property, NSUInteger index, BOOL *stop) {
        NSDictionary <NSString *, TFY_SqliteModelPropertyInfo *> * propertyInfoMap = [self.class getModelPropertyDictionary];
        TFY_SqliteModelPropertyInfo * propertyInfo = nil;
        if (propertyInfoMap != nil) {
            propertyInfo = propertyInfoMap[propertyName];
        }
        if (propertyInfo == nil) {
            propertyInfo = [TFY_SqliteModelPropertyInfo new];
            const char * attributes = property_getAttributes(property);
            propertyInfo->type = [self.class parserTypeWithAttr:[NSString stringWithUTF8String:attributes]];
            propertyInfo->setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[propertyName substringToIndex:1].uppercaseString, [propertyName substringFromIndex:1]]);
        }
        if ([newSelf respondsToSelector:propertyInfo->setter]) {
            id value = [self valueForKey:propertyName];
            switch (propertyInfo->type) {
                case _SqliteChar: {
                    ((void (*)(id, SEL, char))(void *) objc_msgSend)((id)newSelf, propertyInfo->setter, [value charValue]);
                }
                    break;
                case _SqliteFloat: {
                    ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)newSelf, propertyInfo->setter, [value floatValue]);
                }
                    break;
                case _SqliteDouble: {
                    ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)newSelf, propertyInfo->setter, [value doubleValue]);
                }
                    break;
                case _SqliteBoolean:{
                    ((void (*)(id, SEL, BOOL))(void *) objc_msgSend)((id)newSelf, propertyInfo->setter, [value boolValue]);
                }
                    break;
                case _SqliteInteger:{
                    ((void (*)(id, SEL, NSInteger))(void *) objc_msgSend)((id)newSelf, propertyInfo->setter, [value integerValue]);
                }
                    break;
                case _SqliteUInteger:{
                    ((void (*)(id, SEL, NSUInteger))(void *) objc_msgSend)((id)newSelf, propertyInfo->setter, [value unsignedIntegerValue]);
                }
                    break;
                default: {
                    if (value) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)newSelf, propertyInfo->setter, [value copy]);
                    }
                }
                    break;
            }
        }
    }];
    return newSelf;
}

- (void)tfy_SqliteEncode:(NSCoder *)aCoder {
    Class superClass = class_getSuperclass(self.class);
    if (superClass != nil &&
        superClass != [NSObject class]) {
        NSObject * superObject = superClass.new;
        [superClass tfy_SqliteEnumeratePropertyNameUsingBlock:^(NSString *propertyName, NSUInteger index, BOOL *stop) {
            [superObject setValue:[self valueForKey:propertyName] forKey:propertyName];
        }];
        [superObject tfy_SqliteEncode:aCoder];
    }
    [self.class tfy_SqliteEnumeratePropertyNameUsingBlock:^(NSString *propertyName, NSUInteger index, BOOL *stop) {
        id value = [self valueForKey:propertyName];
        if (value != nil) {
            [aCoder encodeObject:value forKey:propertyName];
        }
    }];
}

- (void)tfy_SqliteDecode:(NSCoder *)aDecoder {
    Class superClass = class_getSuperclass(self.class);
    if (superClass != nil &&
        superClass != [NSObject class]) {
        NSObject * superObject = superClass.new;
        [superObject tfy_SqliteDecode:aDecoder];
        [superClass tfy_SqliteEnumeratePropertyNameUsingBlock:^(NSString *propertyName, NSUInteger index, BOOL *stop) {
            [self setValue:[superObject valueForKey:propertyName] forKey:propertyName];
        }];
    }
    [self.class tfy_SqliteEnumeratePropertyAttributesUsingBlock:^(NSString *propertyName, objc_property_t property, NSUInteger index, BOOL *stop) {
        id value = [aDecoder decodeObjectForKey:propertyName];
        if (value != nil) {
            NSDictionary <NSString *, TFY_SqliteModelPropertyInfo *> * propertyInfoMap = [self.class getModelPropertyDictionary];
            TFY_SqliteModelPropertyInfo * propertyInfo = nil;
            if (propertyInfoMap != nil) {
                propertyInfo = propertyInfoMap[propertyName];
            }
            if ([value isKindOfClass:[NSNumber class]]) {
                if (propertyInfo == nil) {
                    propertyInfo = [TFY_SqliteModelPropertyInfo new];
                    const char * attributes = property_getAttributes(property);
                    NSArray * attributesArray = [[NSString stringWithUTF8String:attributes] componentsSeparatedByString:@"\""];
                    if (attributesArray.count != 1) {
                        propertyInfo->type = _SqliteNumber;
                    }else {
                        propertyInfo->type = [self.class parserTypeWithAttr:[NSString stringWithUTF8String:attributes]];
                    }
                    propertyInfo->setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[propertyName substringToIndex:1].uppercaseString, [propertyName substringFromIndex:1]]);
                }
                if ([self respondsToSelector:propertyInfo->setter]) {
                    switch (propertyInfo->type) {
                        case _SqliteChar:
                            ((void (*)(id, SEL, char))(void *) objc_msgSend)((id)self, propertyInfo->setter, [value charValue]);
                            break;
                        case _SqliteFloat:
                            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)self, propertyInfo->setter, [value floatValue]);
                            break;
                        case _SqliteDouble:
                            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)self, propertyInfo->setter, [value doubleValue]);
                            break;
                        case _SqliteBoolean:
                            ((void (*)(id, SEL, BOOL))(void *) objc_msgSend)((id)self, propertyInfo->setter, [value boolValue]);
                            break;
                        case _SqliteInteger:
                            ((void (*)(id, SEL, NSInteger))(void *) objc_msgSend)((id)self, propertyInfo->setter, [value integerValue]);
                            break;
                        case _SqliteUInteger:
                            ((void (*)(id, SEL, NSUInteger))(void *) objc_msgSend)((id)self, propertyInfo->setter, [value unsignedIntegerValue]);
                            break;
                        case _SqliteNumber:
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)self, propertyInfo->setter, value);
                            break;
                        default:
                            break;
                    }
                }
            }else {
                if (propertyInfo != nil) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)self, propertyInfo->setter, value);
                }else {
                    SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[propertyName substringToIndex:1].uppercaseString, [propertyName substringFromIndex:1]]);
                    if ([self respondsToSelector:setter]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)self, setter, value);
                    }
                }
            }
        }
    }];
}

#pragma mark - json转模型对象 Api -

+ (id)tfy_SqliteModelWithJson:(id)json {
    if (json) {
        if ([json isKindOfClass:[NSData class]]) {
            id jsonObject = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
            return [self tfy_SqliteModelWithJson:jsonObject];
        }else if ([json isKindOfClass:[NSDictionary class]]) {
            return [self handleDataModelEngine:json class:self];
        }else if ([json isKindOfClass:[NSArray class]]) {
            return [self handleDataModelEngine:json class:self];
        }else if ([json isKindOfClass:[NSString class]]) {
            id  jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
            return [self tfy_SqliteModelWithJson:jsonData];
        }
    }
    return nil;
}

+ (id)tfy_SqliteModelWithJson:(id)json keyPath:(NSString *)keyPath {
    if (json) {
        if (keyPath != nil && keyPath.length > 0) {
            __block id jsonObject = nil;
            if ([json isKindOfClass:[NSData class]]) {
                jsonObject = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
            }else if ([json isKindOfClass:[NSDictionary class]]) {
                jsonObject = json;
            }else if ([json isKindOfClass:[NSArray class]]) {
                jsonObject = json;
            }else if ([json isKindOfClass:[NSString class]]) {
                id  jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
                jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
            }else {
                return nil;
            }
            NSArray<NSString *> * keyPathArray = [keyPath componentsSeparatedByString:@"."];
            [keyPathArray enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange range = [key rangeOfString:@"["];
                if (range.location != NSNotFound) {
                    NSString * realKey = [key substringToIndex:range.location];
                    NSString * indexString = key;
                    if (realKey.length > 0) {
                        jsonObject = jsonObject[realKey];
                        indexString = [key substringFromIndex:range.location];
                    }
                    NSString * handleIndexString = [indexString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
                    NSInteger indexLength = handleIndexString.length;
                    for (NSUInteger i = 0; i < indexLength; i++) {
                        NSInteger index = [[handleIndexString substringWithRange:NSMakeRange(i, 1)] integerValue];
                        jsonObject = jsonObject[index];
                    }
                }else {
                    jsonObject = jsonObject[key];
                }
            }];
            if (jsonObject) {
                if ([jsonObject isKindOfClass:[NSDictionary class]] || [jsonObject isKindOfClass:[NSArray class]]) {
                    return [self tfy_SqliteModelWithJson:jsonObject];
                }else {
                    return jsonObject;
                }
            }
            return nil;
        }else {
            return [self tfy_SqliteModelWithJson:json];
        }
    }
    return nil;
}

#pragma mark - 模型对象转json Api -

- (NSString *)tfy_SqliteJson {
    id jsonSet = nil;
    if ([self isKindOfClass:[NSDictionary class]]) {
        jsonSet = [self parserDictionaryEngine:(NSDictionary *)self];
    }else if ([self isKindOfClass:[NSArray class]]) {
        jsonSet = [self parserArrayEngine:(NSArray *)self];
    }else {
        jsonSet = [self tfy_SqliteDictionary];
    }
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:jsonSet options:kNilOptions error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)tfy_SqliteDictionary {
    NSMutableDictionary * jsonDictionary = [NSMutableDictionary new];
    Class superClass = class_getSuperclass(self.class);
    if (superClass != nil &&
        superClass != [NSObject class]) {
        NSObject * superObject = superClass.new;
        [superClass tfy_SqliteEnumeratePropertyNameUsingBlock:^(NSString *propertyName, NSUInteger index, BOOL *stop) {
            [superObject setValue:[self valueForKey:propertyName] forKey:propertyName];
        }];
        [jsonDictionary setDictionary:[superObject tfy_SqliteDictionary]];
    }
    NSDictionary <NSString *, TFY_SqliteModelPropertyInfo *> * propertyInfoMap = [self.class getModelPropertyDictionary];
    [self.class tfy_SqliteEnumeratePropertyAttributesUsingBlock:^(NSString *propertyName, objc_property_t property, NSUInteger index, BOOL *stop) {
        TFY_SqliteModelPropertyInfo * propertyInfo = nil;
        if (propertyInfoMap != nil) {
            propertyInfo = propertyInfoMap[propertyName];
        }
        if (propertyInfo) {
            if (propertyInfo->getter == nil) {
                propertyInfo->getter = NSSelectorFromString(propertyName);
            }
            switch (propertyInfo->type) {
                case _SqliteData: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo->getter);
                    if (value) {
                        if ([value isKindOfClass:[NSData class]]) {
                            [jsonDictionary setObject:[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] forKey:propertyName];
                        }else {
                            [jsonDictionary setObject:value forKey:propertyName];
                        }
                    }else {
                        [jsonDictionary setObject:[NSNull new] forKey:propertyName];
                    }
                }
                    break;
                case _SqliteDate: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo->getter);
                    if (value) {
                        if ([value isKindOfClass:[NSString class]]) {
                            [jsonDictionary setObject:value forKey:propertyName];
                        }else {
                            NSDateFormatter * formatter = [NSDateFormatter new];
                            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                            [jsonDictionary setObject:[formatter stringFromDate:value] forKey:propertyName];
                        }
                    }else {
                        [jsonDictionary setObject:[NSNull new] forKey:propertyName];
                    }
                }
                    break;
                case _SqliteValue:
                    break;
                case _SqliteString:
                case _SqliteNumber: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo->getter);
                    if (value != nil) {
                        [jsonDictionary setObject:value forKey:propertyName];
                    }else {
                        [jsonDictionary setObject:[NSNull new] forKey:propertyName];
                    }
                }
                    break;
                case _SqliteModel: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo->getter);
                    [jsonDictionary setObject:[value tfy_SqliteDictionary] forKey:propertyName];
                }
                    break;
                case _SqliteArray: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo->getter);
                    [jsonDictionary setObject:[self parserArrayEngine:value] forKey:propertyName];
                }
                    break;
                case _SqliteDictionary: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo->getter);
                    [jsonDictionary setObject:[self parserDictionaryEngine:value] forKey:propertyName];
                }
                    break;
                case _SqliteChar: {
                    char value = ((char (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo->getter);
                    [jsonDictionary setObject:[NSNumber numberWithChar:value] forKey:propertyName];
                }
                    break;
                case _SqliteFloat: {
                    Float64 value = ((Float64 (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo->getter);
                    [jsonDictionary setObject:[NSNumber numberWithFloat:value] forKey:propertyName];
                }
                    break;
                case _SqliteDouble: {
                    double value = ((double (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo->getter);
                    [jsonDictionary setObject:[NSNumber numberWithDouble:value] forKey:propertyName];
                }
                    break;
                case _SqliteBoolean: {
                    BOOL value = ((BOOL (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo->getter);
                    [jsonDictionary setObject:[NSNumber numberWithBool:value] forKey:propertyName];
                }
                    break;
                case _SqliteInteger: {
                    NSInteger value = ((NSInteger (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo->getter);
                    [jsonDictionary setObject:[NSNumber numberWithInteger:value] forKey:propertyName];
                }
                    break;
                case _SqliteUInteger: {
                    NSUInteger value = ((NSUInteger (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyInfo->getter);
                    [jsonDictionary setObject:[NSNumber numberWithUnsignedInteger:value] forKey:propertyName];
                }
                    break;
                case _SqliteNull: {
                    [jsonDictionary setObject:[NSNull new] forKey:propertyName];
                }
                    break;
                default:
                    break;
            }
        }else {
            const char * attributes = property_getAttributes(property);
            NSArray * attributesArray = [[NSString stringWithUTF8String:attributes] componentsSeparatedByString:@"\""];
            if (attributesArray.count == 1) {
                id value = [self valueForKey:propertyName];
                [jsonDictionary setObject:value forKey:propertyName];
            }else {
                id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, NSSelectorFromString(propertyName));
                if (value != nil) {
                    Class classType = NSClassFromString(attributesArray[1]);
                    if ([classType isSubclassOfClass:[NSString class]]) {
                        [jsonDictionary setObject:value forKey:propertyName];
                    }else if ([classType isSubclassOfClass:[NSNumber class]]) {
                        [jsonDictionary setObject:value forKey:propertyName];
                    }else if ([classType isSubclassOfClass:[NSDictionary class]]) {
                        [jsonDictionary setObject:[self parserDictionaryEngine:value] forKey:propertyName];
                    }else if ([classType isSubclassOfClass:[NSArray class]]) {
                        [jsonDictionary setObject:[self parserArrayEngine:value] forKey:propertyName];
                    }else if ([classType isSubclassOfClass:[NSDate class]]) {
                        if ([value isKindOfClass:[NSString class]]) {
                            [jsonDictionary setObject:value forKey:propertyName];
                        }else {
                            NSDateFormatter * formatter = [NSDateFormatter new];
                            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                            [jsonDictionary setObject:[formatter stringFromDate:value] forKey:propertyName];
                        }
                    }else if ([classType isSubclassOfClass:[NSData class]]) {
                        if ([value isKindOfClass:[NSData class]]) {
                            [jsonDictionary setObject:[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] forKey:propertyName];
                        }else {
                            [jsonDictionary setObject:value forKey:propertyName];
                        }
                    }else if ([classType isSubclassOfClass:[NSValue class]] || [classType isSubclassOfClass:[NSSet class]] || [classType isSubclassOfClass:[NSURL class]] || [classType isSubclassOfClass:[NSError class]]) {
                    }else {
                        [jsonDictionary setObject:[value tfy_SqliteDictionary] forKey:propertyName];
                    }
                }else {
                    [jsonDictionary setObject:[NSNull new] forKey:propertyName];
                }
            }
        }
    }];
    return jsonDictionary;
}

#pragma mark - 模型对象转json解析引擎(private) -

- (id)parserDictionaryEngine:(NSDictionary *)value {
    if (value == nil) return [NSNull new];
    NSMutableDictionary * subJsonDictionary = [NSMutableDictionary new];
    NSArray * allKey = value.allKeys;
    for (NSString * key in allKey) {
        id subValue = value[key];
        if ([subValue isKindOfClass:[NSString class]] ||
            [subValue isKindOfClass:[NSNumber class]]) {
            [subJsonDictionary setObject:subValue forKey:key];
        }else if ([subValue isKindOfClass:[NSDictionary class]]){
            [subJsonDictionary setObject:[self parserDictionaryEngine:subValue] forKey:key];
        }else if ([subValue isKindOfClass:[NSArray class]]) {
            [subJsonDictionary setObject:[self parserArrayEngine:subValue] forKey:key];
        }else {
            [subJsonDictionary setObject:[subValue tfy_SqliteDictionary] forKey:key];
        }
    }
    return subJsonDictionary;
}

- (id)parserArrayEngine:(NSArray *)value {
    if (value == nil) return [NSNull new];
    NSMutableArray * subJsonArray = [NSMutableArray new];
    for (id subValue in value) {
        if ([subValue isKindOfClass:[NSString class]] ||
            [subValue isKindOfClass:[NSNumber class]]) {
            [subJsonArray addObject:subValue];
        }else if ([subValue isKindOfClass:[NSDictionary class]]){
            [subJsonArray addObject:[self parserDictionaryEngine:subValue]];
        }else if ([subValue isKindOfClass:[NSArray class]]) {
            [subJsonArray addObject:[self parserArrayEngine:subValue]];
        }else {
            [subJsonArray addObject:[subValue tfy_SqliteDictionary]];
        }
    }
    return subJsonArray;
}

#pragma mark - json转模型对象解析引擎(private) -

static const char  TFY_SqliteModelPropertyInfokey = '\0';
static const char  TFY_SqliteReplaceKeyValue = '\0';
static const char  TFY_SqliteReplacePropertyClass = '\0';
static const char  TFY_SqliteReplaceContainerElementClass = '\0';

+ (NSDictionary <NSString *, Class> *)getContainerElementClassMapper {
    return objc_getAssociatedObject(self, &TFY_SqliteReplaceContainerElementClass);
}

+ (void)setContainerElementClassMapper:(NSDictionary <NSString *, Class> *)mapper {
    objc_setAssociatedObject(self, &TFY_SqliteReplaceContainerElementClass, mapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSDictionary <NSString *, Class> *)getModelPropertyClassMapper {
    return objc_getAssociatedObject(self, &TFY_SqliteReplacePropertyClass);
}

+ (void)setModelPropertyClassMapper:(NSDictionary <NSString *, Class> *)mapper {
    objc_setAssociatedObject(self, &TFY_SqliteReplacePropertyClass, mapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSDictionary <NSString *, NSString *> *)getModelReplacePropertyMapper {
    return objc_getAssociatedObject(self, &TFY_SqliteReplaceKeyValue);
}

+ (void)setModelReplacePropertyMapper:(NSDictionary *)mapper {
    objc_setAssociatedObject(self, &TFY_SqliteReplaceKeyValue, mapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSDictionary <NSString *, TFY_SqliteModelPropertyInfo *>*)getModelPropertyDictionary {
    return objc_getAssociatedObject(self, &TFY_SqliteModelPropertyInfokey);
}

+ (TFY_SqliteModelPropertyInfo *)getPropertyInfo:(NSString *)property {
    NSDictionary * propertyInfo = objc_getAssociatedObject(self, &TFY_SqliteModelPropertyInfokey);
    return propertyInfo != nil ? propertyInfo[property] : nil;
}

+ (void)setModelInfo:(TFY_SqliteModelPropertyInfo *)modelInfo property:(NSString *)property {
    NSMutableDictionary * propertyInfo = objc_getAssociatedObject(self, &TFY_SqliteModelPropertyInfokey);
    if (propertyInfo == nil) {
        propertyInfo = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &TFY_SqliteModelPropertyInfokey, propertyInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [propertyInfo setObject:modelInfo forKey:property];
}

+ (NSString *)existproperty:(NSString *)property withObject:(NSObject *)object {
    objc_property_t property_t = class_getProperty(object.class, [property UTF8String]);
    if (property_t != NULL) {
        const char * name = property_getName(property_t);
        NSString * nameString = [NSString stringWithUTF8String:name];
        return nameString;
    }else {
        unsigned int  propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList([object class], &propertyCount);
        for (unsigned int i = 0; i < propertyCount; ++i) {
            objc_property_t property_t = properties[i];
            const char * name = property_getName(property_t);
            NSString * nameString = [NSString stringWithUTF8String:name];
            if ([nameString.lowercaseString isEqualToString:property.lowercaseString]) {
                free(properties);
                return nameString;
            }
        }
        free(properties);
        Class superClass = class_getSuperclass(object.class);
        if (superClass && superClass != [NSObject class]) {
            NSString * name =  [self existproperty:property withObject:superClass.new];
            if (name != nil && name.length > 0) {
                return name;
            }
        }
        return nil;
    }
}

+ (TFY_SqliteTYPE)parserTypeWithAttr:(NSString *)attr {
    NSArray * sub_attrs = [attr componentsSeparatedByString:@","];
    NSString * first_sub_attr = sub_attrs.firstObject;
    first_sub_attr = [first_sub_attr substringFromIndex:1];
    TFY_SqliteTYPE attr_type = _SqliteNull;
    const char type = *[first_sub_attr UTF8String];
    switch (type) {
        case 'B':
            attr_type = _SqliteBoolean;
            break;
        case 'c':
        case 'C':
            attr_type = _SqliteChar;
            break;
        case 'S':
        case 'I':
        case 'L':
        case 'Q':
            attr_type = _SqliteUInteger;
        case 'l':
        case 'q':
        case 'i':
        case 's':
            attr_type = _SqliteInteger;
            break;
        case 'f':
            attr_type = _SqliteFloat;
            break;
        case 'd':
        case 'D':
            attr_type = _SqliteDouble;
            break;
        default:
            break;
    }
    return attr_type;
}

+ (TFY_SqliteModelPropertyInfo *)classExistProperty:(NSString *)property withObject:(NSObject *)object valueClass:(Class)valueClass {
    TFY_SqliteModelPropertyInfo * propertyInfo = nil;
    objc_property_t property_t = class_getProperty(object.class, [property UTF8String]);
    if (property_t != NULL) {
        const char * attributes = property_getAttributes(property_t);
        NSString * attr = [NSString stringWithUTF8String:attributes];
        NSArray * arrayString = [attr componentsSeparatedByString:@"\""];
        propertyInfo = [TFY_SqliteModelPropertyInfo new];
        if (arrayString.count == 1) {
            propertyInfo->type = [self parserTypeWithAttr:arrayString[0]];
        }else {
            [propertyInfo setClass: NSClassFromString(arrayString[1]) valueClass:valueClass];
        }
        return propertyInfo;
    }else {
        unsigned int  propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList([object class], &propertyCount);
        for (unsigned int i = 0; i < propertyCount; ++i) {
            objc_property_t property_t = properties[i];
            const char * name = property_getName(property_t);
            NSString * nameStr = [NSString stringWithUTF8String:name];
            if ([nameStr.lowercaseString isEqualToString:property.lowercaseString]) {
                const char * attributes = property_getAttributes(property_t);
                NSString * attr = [NSString stringWithUTF8String:attributes];
                NSArray * arrayString = [attr componentsSeparatedByString:@"\""];
                free(properties);
                propertyInfo = [TFY_SqliteModelPropertyInfo new];
                if (arrayString.count == 1) {
                    propertyInfo->type = [self parserTypeWithAttr:arrayString[0]];
                }else {
                    [propertyInfo setClass: NSClassFromString(arrayString[1]) valueClass:valueClass];
                }
                return propertyInfo;
            }
        }
        free(properties);
        Class superClass = class_getSuperclass(object.class);
        if (superClass && superClass != [NSObject class]) {
            propertyInfo = [self classExistProperty:property withObject:superClass.new valueClass:valueClass];
            if (propertyInfo != nil) {
                return propertyInfo;
            }
        }
    }
    return propertyInfo;
}

+ (id)handleDataModelEngine:(id)object class:(Class)class {
    if(object) {
        if([object isKindOfClass:[NSDictionary class]]) {
            __block NSObject *  modelObject = nil;
            NSDictionary  * dictionary = object;
            __block NSDictionary <NSString *, NSString *> * replacePropertyNameMap = [class getModelReplacePropertyMapper];
            __block NSDictionary <NSString *, Class> * replacePropertyClassMap = [class getModelPropertyClassMapper];
            __block NSDictionary <NSString *, Class> * replaceContainerElementClassMap = [class getContainerElementClassMapper];
            if (replacePropertyNameMap == nil &&
                [class respondsToSelector:@selector(tfy_SqliteModelReplacePropertyMapper)]) {
                replacePropertyNameMap = [class tfy_SqliteModelReplacePropertyMapper];
                [class setModelReplacePropertyMapper:replacePropertyNameMap];
            }
            if ([class isSubclassOfClass:[NSDictionary class]]) {
                modelObject = [NSMutableDictionary dictionary];
                [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString * key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
                        Class subModelClass = NSClassFromString(key);
                        if (subModelClass == nil) {
                            subModelClass = NSClassFromString([NSString stringWithFormat:@"%@%@:",[key substringToIndex:1].uppercaseString, [key substringFromIndex:1]]);
                            if (subModelClass == nil) {
                                subModelClass = [obj class];
                            }
                        }
                        [(NSMutableDictionary *)modelObject setObject:[self handleDataModelEngine:obj class:subModelClass] forKey:key];
                    }else {
                        [(NSMutableDictionary *)modelObject setObject:obj forKey:key];
                    }
                }];
            }else {
                modelObject = [class new];
                [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString * key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    NSString * actualProperty = key;
                    id subObject = obj;
                    if (replacePropertyNameMap != nil) {
                        NSString * replaceName =  replacePropertyNameMap[actualProperty];
                        if (replaceName) {
                            actualProperty = replaceName;
                        }
                    }
                    TFY_SqliteModelPropertyInfo * propertyInfo = [class getPropertyInfo:actualProperty];
                    if (propertyInfo == nil || (propertyInfo != nil && propertyInfo->type == _SqliteUnknown)) {
                        if (replacePropertyClassMap) {
                            propertyInfo = [TFY_SqliteModelPropertyInfo new];
                            [propertyInfo setClass:replacePropertyClassMap[actualProperty] valueClass:[obj class]];
                        }else {
                            if ([class respondsToSelector:@selector(tfy_SqliteModelReplacePropertyClassMapper)]) {
                                [class setModelPropertyClassMapper:[class tfy_SqliteModelReplacePropertyClassMapper]];
                            }
                            propertyInfo = [self classExistProperty:actualProperty withObject:modelObject valueClass:[obj class]];
                        }
                        if (propertyInfo) {
                            [class setModelInfo:propertyInfo property:actualProperty];
                        }else {
                            return;
                        }
                        SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[actualProperty substringToIndex:1].uppercaseString, [actualProperty substringFromIndex:1]]);
                        if (![modelObject respondsToSelector:setter]) {
                            actualProperty = [self existproperty:actualProperty withObject:modelObject];
                            if (actualProperty == nil) {
                                return;
                            }
                            setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[actualProperty substringToIndex:1].uppercaseString, [actualProperty substringFromIndex:1]]);
                        }
                        propertyInfo->setter = setter;
                    }
                    switch (propertyInfo->type) {
                        case _SqliteArray:
                            if(![subObject isKindOfClass:[NSNull class]]){
                                Class subModelClass = NULL;
                                if (replaceContainerElementClassMap) {
                                    subModelClass = replaceContainerElementClassMap[actualProperty];
                                }else if ([class respondsToSelector:@selector(tfy_SqliteModelReplaceContainerElementClassMapper)]) {
                                    replaceContainerElementClassMap = [class tfy_SqliteModelReplaceContainerElementClassMapper];
                                    subModelClass = replaceContainerElementClassMap[actualProperty];
                                    [class setContainerElementClassMapper:replaceContainerElementClassMap];
                                }
                                if (subModelClass == NULL) {
                                    subModelClass = NSClassFromString(actualProperty);
                                    if (subModelClass == nil) {
                                        NSString * first = [actualProperty substringToIndex:1];
                                        NSString * other = [actualProperty substringFromIndex:1];
                                        subModelClass = NSClassFromString([NSString stringWithFormat:@"%@%@",[first uppercaseString],other]);
                                    }
                                }
                                if (subModelClass) {
                                    ((void (*)(id, SEL, NSArray *))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, [self handleDataModelEngine:subObject class:subModelClass]);
                                }else {
                                    ((void (*)(id, SEL, NSArray *))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, subObject);
                                }
                                
                            }else{
                                ((void (*)(id, SEL, NSArray *))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, @[]);
                            }
                            break;
                        case _SqliteDictionary:
                            if(![subObject isKindOfClass:[NSNull class]]){
                                Class subModelClass = NULL;
                                if (replaceContainerElementClassMap) {
                                    subModelClass = replaceContainerElementClassMap[actualProperty];
                                }else if ([class respondsToSelector:@selector(tfy_SqliteModelReplaceContainerElementClassMapper)]) {
                                    replaceContainerElementClassMap = [class tfy_SqliteModelReplaceContainerElementClassMapper];
                                    if (replaceContainerElementClassMap) {
                                        subModelClass = replaceContainerElementClassMap[actualProperty];
                                        [class setContainerElementClassMapper:replaceContainerElementClassMap];
                                    }
                                }
                                if (subModelClass == NULL) {
                                    subModelClass = NSClassFromString(actualProperty);
                                    if (subModelClass == nil) {
                                        NSString * first = [actualProperty substringToIndex:1];
                                        NSString * other = [actualProperty substringFromIndex:1];
                                        subModelClass = NSClassFromString([NSString stringWithFormat:@"%@%@",[first uppercaseString],other]);
                                    }
                                }
                                if (subModelClass) {
                                    NSMutableDictionary * subObjectDictionary = [NSMutableDictionary dictionary];
                                    [subObject enumerateKeysAndObjectsUsingBlock:^(NSString * key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                                        [subObjectDictionary setObject:[self handleDataModelEngine:obj class:subModelClass] forKey:key];
                                    }];
                                    ((void (*)(id, SEL, NSDictionary *))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, subObjectDictionary);
                                }else {
                                    ((void (*)(id, SEL, NSArray *))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, subObject);
                                }
                                
                            }else{
                                ((void (*)(id, SEL, NSDictionary *))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, @{});
                            }
                            break;
                        case _SqliteString:
                            if(![subObject isKindOfClass:[NSNull class]]){
                                ((void (*)(id, SEL, NSString *))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, subObject);
                            }else{
                                ((void (*)(id, SEL, NSString *))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, @"");
                            }
                            break;
                        case _SqliteNumber:
                            if(![subObject isKindOfClass:[NSNull class]]){
                                ((void (*)(id, SEL, NSNumber *))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, subObject);
                            }else{
                                ((void (*)(id, SEL, NSNumber *))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, @(0));
                            }
                            break;
                        case _SqliteInteger:
                            ((void (*)(id, SEL, NSInteger))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, [subObject integerValue]);
                            break;
                        case _SqliteUInteger:
                            ((void (*)(id, SEL, NSUInteger))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, [subObject unsignedIntegerValue]);
                            break;
                        case _SqliteBoolean:
                            ((void (*)(id, SEL, BOOL))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, [subObject boolValue]);
                            break;
                        case _SqliteFloat:
                            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, [subObject floatValue]);
                            break;
                        case _SqliteDouble:
                            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, [subObject doubleValue]);
                            break;
                        case _SqliteChar:
                            ((void (*)(id, SEL, char))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, [subObject charValue]);
                            break;
                        case _SqliteModel:
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, [self handleDataModelEngine:subObject class:propertyInfo->class]);
                            break;
                        case _SqliteDate:
                            if(![subObject isKindOfClass:[NSNull class]]){
                                ((void (*)(id, SEL, NSDate *))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, subObject);
                            }
                            break;
                        case _SqliteValue:
                            if(![subObject isKindOfClass:[NSNull class]]){
                                ((void (*)(id, SEL, NSValue *))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, subObject);
                            }
                            break;
                        case _SqliteData: {
                            if(![subObject isKindOfClass:[NSNull class]]){
                                ((void (*)(id, SEL, NSData *))(void *) objc_msgSend)((id)modelObject, propertyInfo->setter, subObject);
                            }
                            break;
                        }
                        default:
                            
                            break;
                    }
                }];
            }
            return modelObject;
        }else if ([object isKindOfClass:[NSArray class]]){
            NSMutableArray  * modelObjectArr = [NSMutableArray new];
            [object enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                id subModelObject = [self handleDataModelEngine:obj class:class];
                if(subModelObject){
                    [modelObjectArr addObject:subModelObject];
                }
            }];
            return modelObjectArr;
        }else {
            return object;
        }
    }
    return nil;
}


@end
