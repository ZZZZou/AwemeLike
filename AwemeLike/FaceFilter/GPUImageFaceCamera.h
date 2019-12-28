//
//  GPUImageFaceCamera.h
//  AwemeLike
//
//  Created by w22543 on 2019/8/21.
//  Copyright © 2019年 Hytera. All rights reserved.
//


#import "GPUImageVideoCamera.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageFaceCamera : GPUImageVideoCamera
@property(nonatomic, assign) BOOL drawLandmarks;

- (void)switchTorch;
- (BOOL)torchAvailable;

- (void)setupFacepp;
@end

NS_ASSUME_NONNULL_END
