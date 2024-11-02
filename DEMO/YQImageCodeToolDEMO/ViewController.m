//
//  ViewController.m
//  YQImageCodeToolDEMO
//
//  Created by problemchild on 16/9/14.
//  Copyright © 2016年 ProblenChild. All rights reserved.
//

#import "ViewController.h"

#import "ScanViewController.h"
#import "CreatViewController.h"



@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"二维码工具";
    
    self.tableview  = [[UITableView alloc]initWithFrame:self.view.bounds
                                                  style:UITableViewStyleGrouped];
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    
    [self.view addSubview:self.tableview];
    
    [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"扫码DEMO";
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"生成二维码DEMO";
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
   
    switch (indexPath.row) {
        case 0:
        {
            ScanViewController *ScanVC = [[ScanViewController alloc]init];
            
            [self.navigationController pushViewController:ScanVC animated:YES];
        }
            break;
        case 1:
        {
            CreatViewController *creatVC = [[CreatViewController alloc]init];
            
            [self.navigationController pushViewController:creatVC animated:YES];
        }
            break;
        default:
            break;
    }
}


@end
