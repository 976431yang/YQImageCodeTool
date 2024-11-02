//
//  YQImageCodeTool.h
//  YQImageCodeToolDEMO
//
//  Created by problemchild on 16/9/14.
//  Copyright © 2016年 ProblenChild. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol YQImageCodeToolDelegate <NSObject>

//获取到了二维码/条形码 信息
- (void)YQImageCodeToolGotCodeMessage:(NSString *)message;

//相机是否能用返回结果
- (void)YQImageCodeToolCameraAvailableResult:(BOOL)available;

@end


//图片二维码/条形码 识别、生成工具
@interface YQImageCodeTool : NSObject

//--代理
@property(nonatomic,weak) id <YQImageCodeToolDelegate> delegate;

//--单例
+ (YQImageCodeTool *)defaultTool;

//--检查相机权限是否可用
//若未尝试获取权限，则会立即尝试获取权限。
//请在代理中捕获结果。
- (void)checkCameraAvailable;

//--检测相机权限的结果。
typedef void(^CameraAvailableBlock)(bool available);
@property (nonatomic, strong) CameraAvailableBlock cameraAvailableBlock;

//--初始化扫描相机
//注：会自动尝试获取相机权限
//size传相机View的size
//返回成功与否的结果
- (void)setUpTheCameraViewWithFrame:(CGRect)frame;

//--相机View
@property (nonatomic, strong) UIView *cameraView;

//把相机View的朝向恢复成向上
- (void)changeCameraViewToDirectionUp;

//把相机View的朝向调整成倒置方向
- (void)changeCameraViewToDirectionDown;

//把相机View的朝向调整成向左横屏
- (void)changeCameraViewToDirectionLeft;

//把相机View的朝向调整成向右横屏
- (void)changeCameraViewToDirectionRight;

//创建二维码
+ (UIImage *)creatQrCodeImageWithMessage:(NSString *)message
                                andWidth:(CGFloat)size;


@end
