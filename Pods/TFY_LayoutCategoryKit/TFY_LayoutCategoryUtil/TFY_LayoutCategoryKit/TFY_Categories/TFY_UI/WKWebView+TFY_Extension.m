//
//  WKWebView+TFY_Extension.m
//  TFY_CHESHI
//
//  Created by 田风有 on 2019/3/29.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "WKWebView+TFY_Extension.h"
#include <objc/runtime.h>
#import "UIViewController+TFY_Tools.h"
@interface WKWebView ()<WKNavigationDelegate>

@property (nonatomic, strong) UIProgressView *tfy_progressView;

@end

@implementation WKWebView (TFY_Extension)
- (void)tfy_showProgressWithColor:(UIColor *)color {
    
    //进度条初始化
    self.tfy_progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    //设置进度条上进度的颜色
    self.tfy_progressView.progressTintColor = (color != nil) ? color : [self tfy_hexColor:@"11BF76"];
    //设置进度条背景色
    self.tfy_progressView.trackTintColor = [UIColor lightGrayColor];
    //设置进度条的高度，下面这句代码表示进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
    self.tfy_progressView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    [self addSubview:self.tfy_progressView];
    
    [self addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    self.navigationDelegate = self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if(self.tfy_progressView != nil) {
        
        if (object == self && [keyPath isEqualToString:@"estimatedProgress"])
        {
            CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
            if (newprogress == 1)
            {
                self.tfy_progressView.hidden = YES;
                [self.tfy_progressView setProgress:0 animated:NO];
            }
            else
            {
                self.tfy_progressView.hidden = NO;
                [self.tfy_progressView setProgress:newprogress animated:YES];
            }
        }
    }
}

//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    //开始加载网页时展示出progressView
    if(self.tfy_progressView != nil) {
        
        self.tfy_progressView.hidden = NO;
        //开始加载网页的时候将progressView的Height恢复为1.5倍
        self.tfy_progressView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        //防止progressView被网页挡住
        [self bringSubviewToFront:self.tfy_progressView];
    }
}

//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    //加载完成后隐藏progressView
    if(self.tfy_progressView != nil) {
        
        self.tfy_progressView.hidden = YES;
    }
}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    //加载失败同样需要隐藏progressView
    if(self.tfy_progressView != nil) {
        
        self.tfy_progressView.hidden = YES;
    }
}

- (void)setTfy_progressView:(UIProgressView *)tfy_progressView {
    
    objc_setAssociatedObject(self, &@selector(tfy_progressView), tfy_progressView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIProgressView *)tfy_progressView {
    
    UIProgressView *obj = objc_getAssociatedObject(self, &@selector(tfy_progressView));
    return obj;
}

- (void)dealloc {
    
    if(self.tfy_progressView != nil) {
        
        [self removeObserver:self forKeyPath:@"estimatedProgress"];
    }
}

-(UIColor *)tfy_hexColor:(NSString *)hexColor {
    
    unsigned int red, green, blue;
    
    NSRange range;
    
    range.length = 2;
    
    range.location = 0;
    
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2;
    
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/ 255.0f) green:(float)(green/ 255.0f) blue:(float)(blue/ 255.0f) alpha: 1.0f];
}

- (void )tfy_screenSnapshot:(void(^)(UIImage *snapShotImage))finishBlock{
    if (!finishBlock)return;
    
    //获取父view
    UIView *superview;
    UIViewController *currentViewController = [UIViewController currentViewController];
    if (currentViewController){
        superview = currentViewController.view;
    }else{
        superview = self.superview;
    }
    
    //添加遮盖
    UIView *snapShotView = [superview snapshotViewAfterScreenUpdates:YES];
    snapShotView.frame = CGRectMake(superview.frame.origin.x, superview.frame.origin.y, snapShotView.frame.size.width, snapShotView.frame.size.height);
    
    [superview addSubview:snapShotView];
    
    //保存原始信息
    CGRect oldFrame = self.frame;
    CGPoint oldOffset = self.scrollView.contentOffset;
    CGSize contentSize = self.scrollView.contentSize;
    
    //计算快照屏幕数
    NSUInteger snapshotScreenCount = floorf(contentSize.height / self.scrollView.bounds.size.height);
    
    //设置frame为contentSize
    self.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);

    self.scrollView.contentOffset = CGPointZero;
    
    UIGraphicsBeginImageContextWithOptions(contentSize, NO, [UIScreen mainScreen].scale);
    
    __weak typeof(self) weakSelf = self;
    //截取完所有图片
    [self scrollToDraw:0 maxIndex:(NSInteger )snapshotScreenCount finishBlock:^{
        [snapShotView removeFromSuperview];
        
        UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        weakSelf.frame = oldFrame;
        weakSelf.scrollView.contentOffset = oldOffset;
        
        finishBlock(snapshotImage);
    }];
}

//滑动画了再截图
- (void )scrollToDraw:(NSInteger )index maxIndex:(NSInteger )maxIndex finishBlock:(void(^)(void))finishBlock{
    UIView *snapshotView = self.superview;
    
    //截取的frame
    CGRect snapshotFrame = CGRectMake(0, (float)index * snapshotView.bounds.size.height, snapshotView.bounds.size.width, snapshotView.bounds.size.height);
    
    // set up webview originY
    CGRect myFrame = self.frame;
    myFrame.origin.y = -((index) * snapshotView.frame.size.height);
    self.frame = myFrame;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        
        [snapshotView drawViewHierarchyInRect:snapshotFrame afterScreenUpdates:YES];
        
        if(index < maxIndex){
            [self scrollToDraw:index + 1 maxIndex:maxIndex finishBlock:finishBlock];
        }else{
            if (finishBlock) {
                finishBlock();
            }
        }
    });
}

@end
