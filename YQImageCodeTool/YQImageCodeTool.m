//
//  YQImageCodeTool.m
//  YQImageCodeToolDEMO
//
//  Created by problemchild on 16/9/14.
//  Copyright © 2016年 ProblenChild. All rights reserved.
//

#import "YQImageCodeTool.h"

@import AVFoundation;

@interface YQImageCodeTool ()<AVCaptureMetadataOutputObjectsDelegate>

@end

@implementation YQImageCodeTool

//单例
static YQImageCodeTool *staticTool;
+(YQImageCodeTool *)defaultTool{
    if(!staticTool){
        staticTool = [YQImageCodeTool new];
        //[staticTool setup];
    }
    return staticTool;
}

//检查相机是否可用
//若未尝试获取权限，则会立即尝试获取权限。
//请在代理中捕获结果。
-(void)CheckCameraAvailable{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized) {
        [self.delegate YQImageCodeToolCameraAvailableResult:YES];
    } else if(status == AVAuthorizationStatusDenied){
        [self.delegate YQImageCodeToolCameraAvailableResult:NO];
    } else if(status == AVAuthorizationStatusRestricted){
        [self.delegate YQImageCodeToolCameraAvailableResult:NO];
    } else if(status == AVAuthorizationStatusNotDetermined){
        //尚未尝试获取
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                [self.delegate YQImageCodeToolCameraAvailableResult:YES];
            } else {
                [self.delegate YQImageCodeToolCameraAvailableResult:NO];
            }
        }];
    }
}

//相机回话
AVCaptureSession *captureSession;
//显示相机画面的layer
AVCaptureVideoPreviewLayer *videoPreviewLayer;
//识别出码的范围方框
UIView *qrCodeFrameView;

//初始化扫描相机
//注：会自动尝试获取相机权限
-(void)SetUpTheCameraViewWithSize:(CGSize)Size
{
    //一个AVCaptureDevice对象代表了一个物理上的视频设备，在这里配置了一个默认的视频设备。由于将要捕获视频数据，所以调用defaultDeviceWithMediaType方法和AVMediaTypeVideo来得到视频设备。
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    
    
    //AVCaptureSession会话是用来管理视频数据流从输入设备传送到输出端的会话过程的。
    captureSession = [AVCaptureSession new];
    [captureSession addInput:input];
    
    //这个会话的输出端被设定为一个AVCaptureMetaDataOutput对象
    AVCaptureMetadataOutput *captureMetadataOutput = [AVCaptureMetadataOutput new];
    [captureSession addOutput:captureMetadataOutput];
    
    //把self设置为captureMetadataOutput对象的代理
    //根据苹果的文档，这个队列必须是串行的，所以直接使用dispatch_get_main_queue()获取默认的GCD的串行执行队列
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //metadataObjectTypes属性也非常重要，因为它的值会被用来判定整个应用程序对哪类元数据感兴趣。在这里将它指定为AVMetadataObjectTypeQRCode。
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode, nil]];
    
    
    //制作摄像头视频View
    AVCaptureVideoPreviewLayer *videoPreViewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:captureSession];
    videoPreViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.CameraView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,
                                                              Size.width,
                                                              Size.height)];
    
    videoPreViewLayer.frame = self.CameraView.bounds;
    
    [self.CameraView.layer addSublayer:videoPreViewLayer];
    
    
    [captureSession startRunning];
    
    //建立一个方框
    //现在这个UIView是隐形的，因为它的尺寸默认会被设成零。之后，当检测到二维码时，再改变它的尺寸，那么它就会变成一个绿色的方框了。
    qrCodeFrameView = [UIView new];
    qrCodeFrameView.layer.borderColor = [[UIColor greenColor] CGColor];
    qrCodeFrameView.layer.borderWidth = 5;
    [self.CameraView addSubview:qrCodeFrameView];
}

//当AVCaptureMetadataOutput对象识别出来一个二维码，下边的方法（AVCaptureMetadataOutputObjectsDelegate的代理方法）就会被调用
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    //首先要要判断这个数组是否为空。如果为空，就要重置qrCodeFrameView的尺寸为零
    if (metadataObjects == nil || metadataObjects.count == 0)
    {
        qrCodeFrameView.frame = CGRectZero;
        return ;
    }
    
    //如果数组里有元数据，就去判断它是否是二维码。如果是，接着就去找到二维码的边界。
    AVMetadataMachineReadableCodeObject *metadataObj = metadataObjects[0];
    
    if (metadataObj.type == AVMetadataObjectTypeQRCode)
    {
        
        //通过调用viewPreviewLayer的transformedMetadataObjectForMetadataObject方法(已测试不可用)，元数据对象就会被转化成图层的坐标。通过这个坐标，可以获取二维码的边界并构建绿色方框。

        
        qrCodeFrameView.frame = [self CalculateFrameWithMetaDataFrame:metadataObj.bounds];
        
        
        // 最后，对二维码进行解码，得到人类可读信息。解码信息可以用过访问
        if (metadataObj.stringValue != nil)
        {
            [self.delegate YQImageCodeToolGotCodeMessage:metadataObj.stringValue];
            
            //复制到剪贴板
            UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
            pastboard.string = metadataObj.stringValue;
            
        }else{
            qrCodeFrameView.frame = CGRectZero;
            return ;
        }
    }
    else if (metadataObj.type == AVMetadataObjectTypeEAN13Code||metadataObj.type == AVMetadataObjectTypeEAN8Code||metadataObj.type == AVMetadataObjectTypeCode128Code) {
        //条形码
        
        qrCodeFrameView.frame = [self CalculateFrameWithMetaDataFrame:metadataObj.bounds];
        
        if (metadataObj.stringValue != nil)
        {
            [self.delegate YQImageCodeToolGotCodeMessage:metadataObj.stringValue];
            
            //复制到剪贴板
            UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
            pastboard.string = metadataObj.stringValue;
            
        }else{
            qrCodeFrameView.frame = CGRectZero;
            return ;
        }
        
    }else{
        qrCodeFrameView.frame = CGRectZero;
    }
}

//计算frame
-(CGRect)CalculateFrameWithMetaDataFrame:(CGRect)metadataFrame{
    if(self.CameraView.frame.size.width/9*16>self.CameraView.frame.size.height){
        CGFloat width = self.CameraView.frame.size.width*
                        metadataFrame.size.height;
        CGFloat height = self.CameraView.frame.size.width*
                        metadataFrame.size.width/9*16;
        
        CGFloat x = (1-metadataFrame.origin.y)*
        self.CameraView.frame.size.width-width;
        
        CGFloat shouldHeight = self.CameraView.frame.size.width/9*16;
        CGFloat shouldY = (metadataFrame.origin.x)*shouldHeight;
        
        CGFloat y = self.CameraView.frame.size.height/2-(shouldHeight/2-shouldY);
        
        return  CGRectMake(x,y,width, height);
        
    }else{
        CGFloat width = self.CameraView.frame.size.height*
        metadataFrame.size.height/16*9;
        CGFloat height = self.CameraView.frame.size.height*
        metadataFrame.size.width;
        
        CGFloat shouldWidth = self.CameraView.frame.size.height/16*9;
        CGFloat shouldX = (1-metadataFrame.origin.y)*shouldWidth;
        CGFloat x = self.CameraView.frame.size.width/2-
        (shouldWidth/2-shouldX)-width;
        
        CGFloat y = self.CameraView.frame.size.height*metadataFrame.origin.x;
        
        return  CGRectMake(x,y,width, height);
    }
}
@end
