//
//  HPModelEffect_Blur.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/11.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPModelEffect_Blur.h"

@implementation HPModelEffect_Blur
{
    CMTime beginFrameTime;
}

- (void)handleTimerEvent:(CMTime)frameTime {
    if (CMTIME_IS_INVALID(beginFrameTime)) {
        beginFrameTime = frameTime;
    }
    CGFloat diff = CMTimeGetSeconds(CMTimeSubtract(frameTime, beginFrameTime));
    diff = fabs(diff);
    if (diff > 1.5) {
        beginFrameTime = frameTime;
        diff = 0;
    }
    NSInteger gFPS = 16;
    NSInteger frameCount = diff * gFPS;
    CGFloat scale = 0;
    
    if (frameCount <= 10) {
        scale = 1.0 + 0.05 *(1.0 - cos(frameCount/10 * M_PI));
    } else if (frameCount <= 15) {
        scale = 1.1 + 0.025 *(1.0 - cos((frameCount-10)/(15-10) * M_PI));
    } else if (frameCount <= 23) {
        scale = 1.0 + 0.075 *(1.0 + cos((frameCount-15)/(23-15) * M_PI));
    }
    
    HPModelEffectFeatureGeneral *gxFeature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"gx"];
    HPModelEffectFeatureGeneral *gyFeature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"gy"];
    HPModelEffectFeatureGeneral *scaleFeature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"scale"];
    [gxFeature setUniform:@"uScale" value:@[@(12 *(scale-1.0))]];
    [gyFeature setUniform:@"uScale" value:@[@(12 *(scale-1.0))]];
    [scaleFeature setUniform:@"u_scale" value:@[@(scale)]];
}

- (void)clear {
    [super clear];
    beginFrameTime = kCMTimeInvalid;
    
}
@end
