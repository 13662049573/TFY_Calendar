//
//  TFY_GCDGroup.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/1/29.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "TFY_GCDGroup.h"

@interface TFY_GCDGroup ()
@property (strong, nonatomic, readwrite) dispatch_group_t dispatchGroup;
@end

@implementation TFY_GCDGroup

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dispatchGroup = dispatch_group_create();
    }
    return self;
}

- (void)enter {
    
    dispatch_group_enter(self.dispatchGroup);
}

- (void)leave {
    
    dispatch_group_leave(self.dispatchGroup);
}

- (void)wait {
    
    dispatch_group_wait(self.dispatchGroup, DISPATCH_TIME_FOREVER);
}

- (BOOL)wait:(int64_t)delta {
    
    return dispatch_group_wait(self.dispatchGroup, dispatch_time(DISPATCH_TIME_NOW, delta)) == 0;
}


@end
