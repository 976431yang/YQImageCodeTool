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
-(void)YQImageCodeToolGotCodeMessage:(NSString *)message;

@end


//图片二维码/条形码 识别、生成工具
@interface YQImageCodeTool : NSObject

//--代理
@property(nonatomic,strong) id <YQImageCodeToolDelegate> delegate;

//--单例
+(YQImageCodeTool *)defaultTool;

//--检查相机权限是否可用
//若未尝试获取权限，则会立即尝试获取权限。
//请在CameraAvailableBlock中捕获结果。
-(void)CheckCameraAvailable;

//--检测相机权限的结果。
typedef void(^CameraAvailableBlock)(bool available);
@property(nonatomic,strong)CameraAvailableBlock CameraAvailableBlock;

//--初始化扫描相机
//注：会自动尝试获取相机权限
//size传相机View的size
//返回成功与否的结果
-(void)SetUpTheCameraViewWithSize:(CGSize)Size;

//--相机View
@property(nonatomic,strong)UIView *CameraView;





@end