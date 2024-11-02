//
//  ScanViewController.m
//  YQImageCodeToolDEMO
//
//  Created by problemchild on 2017/3/18.
//  Copyright © 2017年 ProblenChild. All rights reserved.
//

#import "ScanViewController.h"


#import "YQImageCodeTool.h"


@interface ScanViewController ()<YQImageCodeToolDelegate>

@property(nonatomic,strong)UILabel *showLab;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //设置代理
    [YQImageCodeTool defaultTool].delegate = self;
    
    
    //检查相机权限是否可用
    //若未尝试获取权限，则会立即尝试获取权限。
    [[YQImageCodeTool defaultTool] checkCameraAvailable];
    
    
    //初始化相机View
    [[YQImageCodeTool defaultTool] setUpTheCameraViewWithFrame:CGRectMake(0, 150,
                                                                         self.view.bounds.size.width,
                                                                         self.view.bounds.size.height - 150)];
    
    //展示使用CameraView
    [self.view addSubview:[YQImageCodeTool defaultTool].cameraView];
    
    //[[YQImageCodeTool defaultTool] changeCameraViewToDirectionLeft];
    
    //显示信息的Lable
    self.showLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 66,
                                                           self.view.bounds.size.width,
                                                           150 - 64)];
    self.showLab.textAlignment = NSTextAlignmentCenter;
    self.showLab.numberOfLines = 0;
    [self.view addSubview:self.showLab];
}

- (void)viewDidDisappear:(BOOL)animated {
    [YQImageCodeTool defaultTool].delegate = nil;
}


#pragma mark YQImageCodeToolDelegate
//遵循代理

//扫描到了信息
- (void)YQImageCodeToolGotCodeMessage:(NSString *)message {
    NSLog(@"message:%@",message);
    
    self.showLab.text = [NSString stringWithFormat:@"扫描到的信息：%@",message];
    
}

//相机是否能用返回结果
- (void)YQImageCodeToolCameraAvailableResult:(BOOL)available {
    NSLog(@"Camera available = %d",available);
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
