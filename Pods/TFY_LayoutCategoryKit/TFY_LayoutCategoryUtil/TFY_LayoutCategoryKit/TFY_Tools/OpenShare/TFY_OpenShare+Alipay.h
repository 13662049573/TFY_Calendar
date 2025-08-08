//
//  TFY_OpenShare+Alipay.h
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/6/1.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "TFY_OpenShare.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_OpenShare (Alipay)
+(void)connectAlipay;
+(void)AliPay:(NSString*)link Success:(paySuccess)success Fail:(payFail)fail;
@end

NS_ASSUME_NONNULL_END
