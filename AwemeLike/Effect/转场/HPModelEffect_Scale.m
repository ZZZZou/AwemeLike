//
//  HPModelEffect_Scale.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/11.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPModelEffect_Scale.h"

static CGFloat scale1[] = {
    1.0,
    1.022,
    1.1,
    1.261,
    1.564,
    2.176,
    3.01
};

static CGFloat scale2[] = {
    1.35,
    2.451,
    2.898,
    3.0
};

static CGFloat blur[] = {
    0.0,
    0.0,
    0.0,
    20.0,
    30.0,
    40.0,
    50.0,
    50.0,
    40.0,
    10.0,
    0.0
};


@implementation HPModelEffect_Scale
{
    CMTime beginFrameTime;
    NSInteger status;
}

- (void)handleTimerEvent:(CMTime)frameTime {
    
    if (CMTIME_IS_INVALID(beginFrameTime)) {
        beginFrameTime = frameTime;
    }
    CGFloat diff = CMTimeGetSeconds(CMTimeSubtract(frameTime, beginFrameTime));
    diff = fabs(diff);
    
    NSInteger scale1Count = sizeof(scale1) / sizeof(CGFloat);
    NSInteger scale2Count = sizeof(scale2) / sizeof(CGFloat);
    
    NSInteger frameCount = MIN(floor(diff * 16), scale1Count + scale2Count);
    if (frameCount >= scale1Count && status == 0) {
        status = 1;
    } else if (frameCount >= scale1Count + scale2Count && status == 1) {
        status = 0;
        beginFrameTime = frameTime;
        frameCount = 0;
    }
    
    HPModelEffectFeatureGeneral *screen1Feature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"screen1"];
    screen1Feature.enable = false;
    HPModelEffectFeatureGeneral *screen2Feature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"screen2"];
    screen2Feature.enable = false;
    if (status == 0) {
        screen1Feature.enable = true;
        [screen1Feature setUniform:@"scale" value:@[@(scale1[frameCount])]];
       
    } else if(status == 1) {
        screen2Feature.enable = true;
        [screen2Feature setUniform:@"scale" value:@[@(scale2[frameCount - scale1Count])]];
                    
    }
    
    HPModelEffectFeatureGeneral *blurFeature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"blur"];
    blurFeature.enable = true;
    [blurFeature setUniform:@"u_radius" value:@[@(blur[frameCount])]];
    
    HPModelEffectFeatureGeneral *blur1Feature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"blur1"];
    blur1Feature.enable = true;
    [blur1Feature setUniform:@"u_radius" value:@[@(blur[frameCount])]];
}

- (void)clear {
    [super clear];
    beginFrameTime = kCMTimeInvalid;
    status = 0;
    
}
@end
