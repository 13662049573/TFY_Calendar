//
//  TFY_PageSegmentedTitleView.m
//  TFY_Navigation
//
//  Created by tiandengyou on 2020/5/25.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "TFY_PageSegmentedTitleView.h"

@interface TFY_PageSegmentedTitleView ()
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

//配置信息
@property (nonatomic, strong) TFY_PageControllerConfig *config;

//底部分割线
@property (nonatomic, strong) UIView *separatorLine;

//判断是否已经加载了数据
@property (nonatomic, assign) BOOL haveLoadedDataSource;
@end

@implementation TFY_PageSegmentedTitleView

//初始化方法
- (instancetype)initWithConfig:(TFY_PageControllerConfig *)config {
    if (self = [super init]) {
        [self initSegmentedWithConfig:config];
    }
    return self;
}

//初始化方法
- (void)initSegmentedWithConfig:(TFY_PageControllerConfig *)config {
    
    self.config = config;
    
    self.segmentedControl = [[UISegmentedControl alloc] init];
    [self.segmentedControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.tintColor = config.segmentedTintColor;
    self.segmentedControl.backgroundColor = config.segmentBackColor;
    self.segmentedControl.apportionsSegmentWidthsByContent = config.segmentWidthsByContent;
    self.segmentedControl.layer.masksToBounds = YES; //默认为no，不设置则下面一句无效
    self.segmentedControl.layer.cornerRadius = config.segmentCornerRadius; //设置圆角大小，同UIView
    self.segmentedControl.layer.borderWidth = config.segmentBorderWidth; //边框宽度，重新画边框，若不重新画，可能会出现圆角处无边框的情况
    self.segmentedControl.layer.borderColor = config.segmentBorderColor.CGColor; //边框颜色
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:config.segmentNormalColor,NSFontAttributeName:config.segmentNormalFont} forState:UIControlStateSelected];
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:config.segmentSelectedColor,NSFontAttributeName:config.segmentSelectedFont} forState:UIControlStateNormal];
    [self addSubview:self.segmentedControl];
    
    self.separatorLine = [[UIView alloc] init];
    self.separatorLine.backgroundColor = config.separatorLineColor;
    self.separatorLine.hidden = config.separatorLineHidden;
    [self addSubview:self.separatorLine];
}

//自动布局
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat segmentH = self.bounds.size.height - self.config.titleViewInset.top - self.config.titleViewInset.bottom;
    CGFloat segmentW = self.bounds.size.width - self.config.titleViewInset.left - self.config.titleViewInset.right;
    
    self.segmentedControl.frame = CGRectMake(self.config.titleViewInset.left, self.config.titleViewInset.top, segmentW, segmentH);
    
    self.separatorLine.frame = CGRectMake(0, self.bounds.size.height - self.config.separatorLineHeight, self.bounds.size.width, self.config.separatorLineHeight);
    
    //加载数据源
    if (!self.haveLoadedDataSource) {
        [self loadDataSource];
    }
}

//加载分段选择器数据源
- (void)loadDataSource {
    self.haveLoadedDataSource = true;
    for (NSInteger i = 0; i < [self.dataSource pageTitleViewNumberOfTitle]; i++) {
        NSString *title = [self.dataSource pageTitleViewTitleForIndex:i];
        [self.segmentedControl insertSegmentWithTitle:title atIndex:self.segmentedControl.numberOfSegments animated:false];
    }
    self.segmentedControl.selectedSegmentIndex = self.selectedIndex;
}

//刷新方法
- (void)reloadData {
    [self.segmentedControl removeAllSegments];
    for (NSInteger i = 0; i < [self.dataSource pageTitleViewNumberOfTitle]; i++) {
        NSString *title = [self.dataSource pageTitleViewTitleForIndex:i];
        [self.segmentedControl insertSegmentWithTitle:title atIndex:self.segmentedControl.numberOfSegments animated:false];
    }
    self.segmentedControl.selectedSegmentIndex = self.selectedIndex;
}

//切换方法
- (void)segmentValueChanged:(UISegmentedControl *)segmentedControl {
    [self.delegate pageTitleViewDidSelectedAtIndex:segmentedControl.selectedSegmentIndex];
    self.lastSelectedIndex = segmentedControl.selectedSegmentIndex;
}

#pragma mark -
#pragma mark Setter
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    self.segmentedControl.selectedSegmentIndex = selectedIndex;
}

@end
