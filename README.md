# YQImageCodeTool
####微博：畸形滴小男孩

###iOS端二维码/条形码 的 识别/生成 的小工具


####使用方法：把文件拖到XCodeg工程中，引入头文件使用
```Objective-C
#import "YQImageCodeTool.h"
```
#####扫描二维码/条形码
-注：若需要扫描 条形码 ，请尽量将条形码对准中间，以提高识别率。（二维码无此问题）
```Objective-C
	
	//设置代理
    [YQImageCodeTool defaultTool].delegate = self;


	//检查相机权限是否可用
    //若未尝试获取权限，则会立即尝试获取权限。
    [[YQImageCodeTool defaultTool] CheckCameraAvailable];

    //初始化相机View
    [[YQImageCodeTool defaultTool]SetUpTheCameraViewWithSize:CGSizeMake(200, 400)];
    
    //展示使用CameraView
    [self.view addSubview:[YQImageCodeTool defaultTool].CameraView];


//代理
#pragma mark YQImageCodeToolDelegate

//扫描到了信息（CameraView会自动在识别到的区域显示一个绿色边框，效果见下图）
-(void)YQImageCodeToolGotCodeMessage:(NSString *)message{
    NSLog(@"message:%@",message);
}

//相机是否可用返回结果
-(void)YQImageCodeToolCameraAvailableResult:(BOOL)available{
    NSLog(@"Camera available = %d",available);
}
```
![image](https://github.com/976431yang/YQImageCodeTool/blob/master/DEMO/screenshot/screenShot1.PNG)
![image](https://github.com/976431yang/YQImageCodeTool/blob/master/DEMO/screenshot/screenShot2.PNG)
![image](https://github.com/976431yang/YQImageCodeTool/blob/master/DEMO/screenshot/screenShot3.PNG)

#####生成二维码
```Objective-C
	
	//Message：需要写入二维码的信息
	//Width：需要生成的二维码的大小的宽度（正方形）
	UIImage *image = [YQImageCodeTool CreatQrCodeImageWithMessage:@"http://www.baidu.com"
                                                         andWidth:500];

```

