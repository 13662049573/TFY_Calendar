//
//  TFY_ProgressHMB.h
//  TFY_ProgressHUD
//
//  Created by 田风有 on 2020/9/9.
//  Copyright © 2020 恋机科技. All rights reserved.
//  最新版本号:2.4.8

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double TFY_ProgressHMBVersionNumber;

FOUNDATION_EXPORT const unsigned char TFY_ProgressHMBVersionString[];

#define TFY_ProgressHMBRelease 0

#if TFY_ProgressHMBRelease

#import <TFY_ProgressHUD/TFY_ProgressHUD.h>
#import <TFY_ProgressHUD/TFY_PopupMenu.h>

#else

#import "TFY_ProgressHUD.h"
#import "TFY_PopupMenu.h"

#endif
