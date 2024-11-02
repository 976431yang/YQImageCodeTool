//
//  YQImageCodeTool.m
//  YQImageCodeToolDEMO
//
//  Created by problemchild on 16/9/14.
//  Copyright © 2016年 ProblenChild. All rights reserved.
//

#import "YQImageCodeTool.h"

@import AVFoundation;

@interface YQImageCodeTool () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreViewLayer;

@end

@implementation YQImageCodeTool

//单例
static YQImageCodeTool *staticTool;
+ (YQImageCodeTool *)defaultTool {
    if(!staticTool){
        staticTool = [YQImageCodeTool new];
        //[staticTool setup];
    }
    return staticTool;
}

//检查相机是否可用
//若未尝试获取权限，则会立即尝试获取权限。
//请在代理中捕获结果。
- (void)checkCameraAvailable {
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
            if (granted) {
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
- (void)setUpTheCameraViewWithFrame:(CGRect)frame {
    //一个AVCaptureDevice对象代表了一个物理上的视频设备，在这里配置了一个默认的视频设备。由于将要捕获视频数据，所以调用defaultDeviceWithMediaType方法和AVMediaTypeVideo来得到视频设备。
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    
    if(!input){
        @throw @"请使用真机运行";
    }
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
    self.videoPreViewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:captureSession];
    self.videoPreViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.cameraView = [[UIView alloc]initWithFrame:frame];
    
    self.videoPreViewLayer.frame = self.cameraView.bounds;
    
    [self.cameraView.layer addSublayer:self.videoPreViewLayer];
    
    
    [captureSession startRunning];
    
    //建立一个方框
    //现在这个UIView是隐形的，因为它的尺寸默认会被设成零。之后，当检测到二维码时，再改变它的尺寸，那么它就会变成一个绿色的方框了。
    qrCodeFrameView = [UIView new];
    qrCodeFrameView.layer.borderColor = [[UIColor greenColor] CGColor];
    qrCodeFrameView.layer.borderWidth = 5;
    [self.cameraView addSubview:qrCodeFrameView];
}

//把相机View的朝向恢复成向上
- (void)changeCameraViewToDirectionUp {
    self.videoPreViewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
}

//把相机View的朝向调整成倒置方向
- (void)changeCameraViewToDirectionDown {
    self.videoPreViewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
}

//把相机View的朝向调整成向左横屏
- (void)changeCameraViewToDirectionLeft {
    self.videoPreViewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
}

//把相机View的朝向调整成向右横屏
- (void)changeCameraViewToDirectionRight {
    self.videoPreViewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
}

//当AVCaptureMetadataOutput对象识别出来一个二维码，下边的方法（AVCaptureMetadataOutputObjectsDelegate的代理方法）就会被调用
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    //首先要要判断这个数组是否为空。如果为空，就要重置qrCodeFrameView的尺寸为零
    if (metadataObjects == nil || metadataObjects.count == 0) {
        qrCodeFrameView.frame = CGRectZero;
        return ;
    }
    
    //如果数组里有元数据，就去判断它是否是二维码。如果是，接着就去找到二维码的边界。
    AVMetadataMachineReadableCodeObject *metadataObj = metadataObjects[0];
    
    if (metadataObj.type == AVMetadataObjectTypeQRCode) {
        qrCodeFrameView.frame = [self CalculateFrameWithMetaDataFrame:metadataObj.bounds];
        
        // 最后，对二维码进行解码，得到人类可读信息。解码信息可以用过访问
        if (metadataObj.stringValue != nil) {
            [self.delegate YQImageCodeToolGotCodeMessage:metadataObj.stringValue];
            
            //复制到剪贴板
            UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
            pastboard.string = metadataObj.stringValue;
            
        } else {
            qrCodeFrameView.frame = CGRectZero;
            return ;
        }
    } else if (metadataObj.type == AVMetadataObjectTypeEAN13Code ||
               metadataObj.type == AVMetadataObjectTypeEAN8Code ||
               metadataObj.type == AVMetadataObjectTypeCode128Code) {
        //条形码
        qrCodeFrameView.frame = [self CalculateFrameWithMetaDataFrame:metadataObj.bounds];
        
        if (metadataObj.stringValue != nil) {
            [self.delegate YQImageCodeToolGotCodeMessage:metadataObj.stringValue];
            
            //复制到剪贴板
            UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
            pastboard.string = metadataObj.stringValue;
            
        } else {
            qrCodeFrameView.frame = CGRectZero;
            return ;
        }
        
    } else {
        qrCodeFrameView.frame = CGRectZero;
    }
}

//计算frame
- (CGRect)CalculateFrameWithMetaDataFrame:(CGRect)metadataFrame {
    BOOL dLandescape = NO;
    BOOL dDown = NO;
    switch (self.videoPreViewLayer.connection.videoOrientation) {
        case AVCaptureVideoOrientationPortrait:
        {
            
        }
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
        {
            dDown = YES;
            metadataFrame = CGRectMake(1-metadataFrame.origin.x-metadataFrame.size.width, 1-metadataFrame.origin.y-metadataFrame.size.height, metadataFrame.size.width, metadataFrame.size.height);
        }
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
        {
            dLandescape = YES;
            metadataFrame = CGRectMake(1-metadataFrame.origin.y-metadataFrame.size.height, metadataFrame.origin.x, metadataFrame.size.height, metadataFrame.size.width);
        }
            break;
        case AVCaptureVideoOrientationLandscapeRight:
        {
            dLandescape = YES;
            metadataFrame = CGRectMake(metadataFrame.origin.y, 1-metadataFrame.origin.x-metadataFrame.size.width, metadataFrame.size.height, metadataFrame.size.width);
        }
            break;
            
        default:
            break;
    }
    if (!dLandescape &&
        self.cameraView.frame.size.width/9*16 > self.cameraView.frame.size.height) {
        CGFloat width = self.cameraView.frame.size.width *
                        metadataFrame.size.height;
        CGFloat height = ((self.cameraView.frame.size.width/9)*16) *
                        metadataFrame.size.width;
        CGFloat x = (1-metadataFrame.origin.y) *
                    self.cameraView.frame.size.width-width;
        
        CGFloat shouldHeight = self.cameraView.frame.size.width/9*16;
        CGFloat shouldY = (metadataFrame.origin.x) * shouldHeight;
        
        CGFloat y = self.cameraView.frame.size.height / 2 -
                    (shouldHeight / 2 - shouldY);
        
        return  CGRectMake(x, y, width, height);
        
    } else if (!dLandescape) {
        CGFloat width = self.cameraView.frame.size.height*
                        metadataFrame.size.height/16*9;
        CGFloat height = self.cameraView.frame.size.height*
                            metadataFrame.size.width;
        
        CGFloat shouldWidth = self.cameraView.frame.size.height/9*16;
        CGFloat shouldX = (1-metadataFrame.origin.y)*shouldWidth;
        CGFloat x = self.cameraView.frame.size.width/2-
        (shouldWidth/2-shouldX)-width;
        
        CGFloat y = self.cameraView.frame.size.height*metadataFrame.origin.x;
        
        return  CGRectMake(x,y,width, height);
    } else if (self.cameraView.frame.size.width/16*9 >
               self.cameraView.frame.size.height) {
        CGFloat width = self.cameraView.frame.size.width *
                        metadataFrame.size.height;
        CGFloat height = ((self.cameraView.frame.size.width/16)*9) *
                         metadataFrame.size.width;
        CGFloat x = (1 - metadataFrame.origin.y) *
        self.cameraView.frame.size.width - width;
        
        CGFloat shouldHeight = self.cameraView.frame.size.width/16*9;
        CGFloat shouldY = (metadataFrame.origin.x) * shouldHeight;
        
        CGFloat y = self.cameraView.frame.size.height / 2 -
                    (shouldHeight / 2 - shouldY);
        
        return  CGRectMake(x,y,width, height);
    } else {
        CGFloat width = self.cameraView.frame.size.height*
                        metadataFrame.size.height/9*16;
        CGFloat height = self.cameraView.frame.size.height*
                        metadataFrame.size.width;
        CGFloat shouldWidth = self.cameraView.frame.size.height/9*16;
        CGFloat shouldX = (1-metadataFrame.origin.y)*shouldWidth;
        CGFloat x = self.cameraView.frame.size.width/2-
                    (shouldWidth/2 - shouldX) - width;
        
        CGFloat y = self.cameraView.frame.size.height*metadataFrame.origin.x;
        
        return  CGRectMake(x, y, width, height);
    }
}

//创建二维码
+ (UIImage *)creatQrCodeImageWithMessage:(NSString *)message
                                andWidth:(CGFloat)size{
    
    if ([message isEqualToString:@""] || (!message)) {
        return nil;
    }
    
    //创建二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //使用滤镜的默认属性
    [filter setDefaults];

    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    //把信息传给滤镜
    [filter setValue:data forKey:@"inputMessage"];

    CIImage *outputImage = [filter outputImage];
    
    //转换成UIImage,并放大
    CGRect extent = CGRectIntegral(outputImage.extent);
    CGFloat scale = MIN(size / CGRectGetWidth(extent),
                        size / CGRectGetHeight(extent));
    //创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:outputImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    //保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];

}
@end
