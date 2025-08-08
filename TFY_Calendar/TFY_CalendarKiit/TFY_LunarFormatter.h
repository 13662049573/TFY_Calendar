//
//  TFY_LunarFormatter.h
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef NS_SWIFT_NAME
#define NS_SWIFT_NAME(name)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TFY_LunarFormatter : NSObject
- (NSString *)stringFromDate:(NSDate *)date NS_SWIFT_NAME(string(fromDate:));
@end

NS_ASSUME_NONNULL_END
