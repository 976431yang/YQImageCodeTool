//
//  ViewController.m
//  YQImageCodeToolDEMO
//
//  Created by problemchild on 16/9/14.
//  Copyright © 2016年 ProblenChild. All rights reserved.
//

#import "ViewController.h"


#import "YQImageCodeTool.h"


@interface ViewController ()<YQImageCodeToolDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //检查相机权限是否可用
    //若未尝试获取权限，则会立即尝试获取权限。
    [[YQImageCodeTool defaultTool] CheckCameraAvailable];
    
    //设置代理
    [YQImageCodeTool defaultTool].delegate = self;
    
    //初始化相机View
    [[YQImageCodeTool defaultTool]SetUpTheCameraViewWithSize:CGSizeMake(200, 200)];
    
    
    [self.view addSubview:[YQImageCodeTool defaultTool].CameraView];
    
    
    
}

#pragma mark YQImageCodeToolDelegate

//遵循代理

//扫描到了信息
-(void)YQImageCodeToolGotCodeMessage:(NSString *)message{
    NSLog(@"message:%@",message);
}

//相机是否能用返回结果
-(void)YQImageCodeToolCameraAvailableResult:(BOOL)available{
    NSLog(@"Camera available = %d",available);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
