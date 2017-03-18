//
//  CreatViewController.m
//  YQImageCodeToolDEMO
//
//  Created by problemchild on 2017/3/18.
//  Copyright © 2017年 ProblenChild. All rights reserved.
//

#import "CreatViewController.h"
#import "YQImageCodeTool.h"

@interface CreatViewController ()

@property(nonatomic,strong)UITextField *field;
@property(nonatomic,strong)UIImageView *showIMGV;

@end

@implementation CreatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.field = [[UITextField alloc]initWithFrame:CGRectMake(10,
                                                              70,
                                                              self.view.bounds.size.width-30-60,
                                                              30)];
    self.field.placeholder = @"输入要生成的信息";
    self.field.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.field];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"生成" forState:UIControlStateNormal];
    btn.frame = CGRectMake(20+self.field.frame.size.width,
                           70,
                           60,
                           30);
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn addTarget:self  action:@selector(creat) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    
    
    CGFloat width = self.view.frame.size.height - 140;
    if(width>self.view.frame.size.width-40){
        width = self.view.frame.size.width-40;
    }
    
    self.showIMGV = [[UIImageView alloc]initWithFrame:CGRectMake(0,
                                                                 100,
                                                                 width,
                                                                 width)];
    self.showIMGV.center = CGPointMake(self.view.center.x, self.showIMGV.center.y);
    self.showIMGV.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.showIMGV];
    
}


-(void)creat{
    
    [self.field resignFirstResponder];
    
    if(self.field.text.length <= 0){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"你没有输入内容"
                                                                                 message:@"请输入内容"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"好的"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              //NSLog(@"相关操作");
                                                              
                                                          }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        
        
        //生成二维码
        UIImage *image = [YQImageCodeTool CreatQrCodeImageWithMessage:self.field.text
                                                             andWidth:500];
        
        //放到屏幕上查看
        self.showIMGV.image = image;
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
