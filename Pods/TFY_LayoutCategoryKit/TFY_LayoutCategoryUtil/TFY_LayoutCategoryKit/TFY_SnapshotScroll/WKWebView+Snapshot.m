//
//  WKWebView+Snapshot.m
//  TFY_LayoutCategoryUtil
//
//  Created by 田风有 on 2023/4/12.
//  Copyright © 2023 田风有. All rights reserved.
//

#import "WKWebView+Snapshot.h"
#import "TFY_WebViewPrintPageRenderer.h"

@implementation WKWebView (Snapshot)

- (UIImage *)takeSnapshotOfVisibleContent {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)takeSnapshotOfFullContent {
    TFY_WebViewPrintPageRenderer *render = [[TFY_WebViewPrintPageRenderer alloc] initFormatter:self.viewPrintFormatter contentSize:self.scrollView.contentSize];
    UIImage *image = [render printContentToImage];
    return image;
}

- (void)asyncTakeSnapshotOfFullContent:(void (^)(UIImage * _Nullable))completion {
    //在截图之前先将用户看到的当前页面截取下来，作为一张图片挡住接下来所执行的截取操作，
    //并且在执行完截图操作后，将截取的遮盖图片销毁。
    UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    coverImageView.image = [self takeSnapshotOfVisibleContent];
    [self addSubview:coverImageView];
    [self bringSubviewToFront:coverImageView];
    
    CGPoint originalOffset = self.scrollView.contentOffset;
    
    // 当contentSize.height<bounds.height时，保证至少有1页的内容绘制
    NSInteger pageNum = 1;
    if (self.scrollView.contentSize.height > self.scrollView.bounds.size.height) {
        pageNum = (NSInteger)floorf(self.scrollView.contentSize.height/self.scrollView.bounds.size.height);
    }
    
    [self loadPageContentIndex:0 maxIndex:pageNum completion:^{
        [self.scrollView setContentOffset:CGPointZero];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            TFY_WebViewPrintPageRenderer *render = [[TFY_WebViewPrintPageRenderer alloc] initFormatter:self.viewPrintFormatter contentSize:self.scrollView.contentSize];
            UIImage *image = [render printContentToImage];
            self.scrollView.contentOffset = originalOffset;
            [coverImageView removeFromSuperview];
            if (completion) completion(image);
        });
    }];
}

- (void)loadPageContentIndex:(NSInteger)index maxIndex:(NSInteger)maxIndex completion:(void(^)(void))completion {
    
    [self.scrollView setContentOffset:CGPointMake(0, index * self.scrollView.frame.size.height)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (index < maxIndex) {
            [self loadPageContentIndex:index + 1 maxIndex:maxIndex completion:completion];
        }else {
            if (completion) completion();
        }
    });
}

@end
