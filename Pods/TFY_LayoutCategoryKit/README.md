使用方法：pod 'TFY_LayoutCategoryKit' 
这里不能和pod 'TFY_Category' 公用。TFY_LayoutCategoryKit 是TFY_Category 的更高一层分装和使用。

# TFY_LayoutCategoryUtil
全新链式的界面初始化和界面跳转，布局基于Masonry

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIButton * cancelButton;

@property (nonatomic, strong) UIButton * confirmButton;

@property (nonatomic, strong) UITextView *contentTextView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *recentUpdateDate;

@property (nonatomic, strong) UILabel *effectDate;

//创建一个View 
UIViewModelSet()
    .backgroundColor([UIColor whiteColor])
    .addToSuperView(self.view)
    .cornerRadius(17)
    .assignTo(^(__kindof UIView * _Nonnull view) {
        _contentView = view;//生成的View,给外部需要更改的对象
    });
    //这里创建三个Label
    UILabelModelSet()
    .multiple(3)//个数赋值
    .assignToObjects(^(NSArray<UILabel *> * _Nonnull objs) {//将对应的对象赋值
        _titleLabel = objs[0];
        _recentUpdateDate = objs[1];
        _effectDate = objs[2];
    })
    .addToSuperView(self.contentView)
    .textAlignment(NSTextAlignmentCenter)
    .part_first()
    .font(Font(PingFangSemibold, 17))
    .textColor(UIColorHexString(@"000000"))
    .text(@"隐私条款")
    .makeMasonry(^(MASConstraintMaker * _Nonnull make) {//基于布局
        make.centerX.equalTo(self.contentView);
        make.top.mas_offset(20);
        make.left.mas_offset(15);
        make.right.mas_offset(-15);
    })
    .part_range(NSMakeRange(1, 2))//这里是需要给第二个label进行初始化
    .font(Font(PingFangLight, 13))
    .textColor(UIColorHexAlpha(@"000000", 0.45))
    .textAlignment(NSTextAlignmentCenter)
    .part_sencond()
    .text(@"最近更新日期：2019年12月13日")
    .makeMasonry(^(MASConstraintMaker * _Nonnull make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(15);
        make.left.mas_offset(15);
        make.right.mas_offset(-15);
    })
    .part_third()//最后一个初始化Label
    .text(@"版本生效日期：2019年12月20日")
    .makeMasonry(^(MASConstraintMaker * _Nonnull make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.recentUpdateDate.mas_bottom).mas_offset(1);
        make.left.mas_offset(15);
        make.right.mas_offset(-15);
    });
    //创建BUtton 
    UIButtonModelSet()
    .multiple(2)//需要创建几个对象，这里写几个。后期对应的进行布局和赋值
    .font(Font(PingFangReguler, 15))
    .cornerRadius(20)
    .masksToBounds(YES)
    .addToSuperView(self.contentView)
    .part_first()
    .textColor(UIColorHexString(@"000000"), UIControlStateNormal)
    .backgroundColor(UIColorHexString(@"#ECECEC"))
    .addTarget(self, @selector(cancelClick), UIControlEventTouchUpInside)
    .text(@"取消", UIControlStateNormal)
    .makeMasonry(^(MASConstraintMaker * _Nonnull make) {
        make.width.mas_equalTo(128);
        make.height.mas_equalTo(40);
        make.bottom.mas_offset(-20);
        make.right.equalTo(self.contentView.mas_centerX).offset(-9.5);
    })
    .part_sencond()
    .textColor(UIColorHexString(@"ffffff"), UIControlStateNormal)
    .backgroundColor(UIColorHexString(@"#FF7800"))
    .addTarget(self, @selector(confirmClick), UIControlEventTouchUpInside)
    .text(@"同意", UIControlStateNormal)
    .makeMasonry(^(MASConstraintMaker * _Nonnull make) {
        make.width.mas_equalTo(128);
        make.height.mas_equalTo(40);
        make.bottom.mas_offset(-20);
        make.left.equalTo(self.contentView.mas_centerX).offset(9.5);
    })
    .assignToObjects(^(NSArray<UIButton *> * _Nonnull objs) {
        _cancelButton = objs[0];
        _confirmButton = objs[1];
    });
    //创建输入框
    UITextViewModelSet()
    .textColor(UIColorHexString(@"000000"))
    .font(Font(PingFangReguler, 14))
    .addToSuperView(self.contentView)
    .delegate(self)
    .editable(NO)
    .assignTo(^(__kindof UIView * _Nonnull view) {
        _contentTextView = view;
    })
    .makeMasonry(^(MASConstraintMaker * _Nonnull make) {
        make.top.equalTo(self.effectDate.mas_bottom).offset(10);
        make.left.mas_offset(20);
        make.right.mas_offset(-20);
        make.bottom.equalTo(self.cancelButton.mas_top).offset(-20);
    });
    
