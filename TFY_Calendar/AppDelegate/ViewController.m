//
//  ViewController.m
//  TFY_Calendar
//
//  Created by 田风有 on 2019/12/1.
//  Copyright © 2019 田风有. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic , strong)UITableView *tableView;
@property(nonatomic , strong)NSMutableArray *dataSouce;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"日历";
    
    [self.view addSubview:self.tableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSouce.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.dataSouce[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *controller = self.dataSouce[indexPath.row];
    UIViewController *vc = [NSClassFromString(controller) new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = UITableViewCreateWithStyle(UITableViewStylePlain);
        _tableView.makeChain
        .frame(self.view.bounds)
        .showsVerticalScrollIndicator(NO)
        .showsHorizontalScrollIndicator(NO)
        .adJustedContentIOS11()
        .delegate(self)
        .dataSource(self)
        .backgroundColor(UIColor.whiteColor)
        .estimatedSectionFooterHeight(0.01)
        .estimatedSectionHeaderHeight(0.01)
        .rowHeight(60)
        .tableHeaderView(UIView.new)
        .tableFooterView(UIView.new);
    }
    return _tableView;
}

-(NSMutableArray *)dataSouce{
    if (!_dataSouce) {
        _dataSouce = [NSMutableArray arrayWithCapacity:7];
        [_dataSouce addObjectsFromArray:@[@"RangePickerViewController",@"DIYExampleViewController",@"ButtonsViewController",@"HidePlaceholderViewController",@"DelegateAppearanceViewController",@"FullScreenExampleViewController",@"LoadViewExampleViewController",@"ScopeExampleViewController",@"CalendarTagController"]];
    }
    return _dataSouce;
}

@end
