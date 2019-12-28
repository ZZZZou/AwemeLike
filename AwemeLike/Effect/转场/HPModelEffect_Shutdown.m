//
//  HPModelEffect_Shutdown.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/11.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPModelEffect_Shutdown.h"

@implementation HPModelEffect_Shutdown
{
    CMTime beginFrameTime;
    
    BOOL gDouState;
    CGFloat xscale;
    CGFloat yscale;
    NSInteger timeCount;
    NSInteger A;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        gDouState = false;
        timeCount = 0.0;
        xscale = 0.15;
        yscale = 0.15;
        A = 0.0;
    }
    return self;
}

- (void)handleTimerEvent:(CMTime)frameTime {
    
    HPModelEffectFeatureSticker *wave = (HPModelEffectFeatureSticker *)[self getFeatureByName:@"clipname2"];
    HPModelEffectFeatureSticker *turnoff = (HPModelEffectFeatureSticker *)[self getFeatureByName:@"clipname1"];
    if (CMTIME_IS_INVALID(beginFrameTime)) {
        beginFrameTime = frameTime;
        gDouState = false;
        timeCount = 0.0;
        xscale = 0.15;
        yscale = 0.15;
        A = 0.0;
        wave.enable = true;
        turnoff.enable = false;
    }
    CGFloat diff = CMTimeGetSeconds(CMTimeSubtract(frameTime, beginFrameTime));
    diff = fabs(diff);
    
    if (diff > 1.2) {
        beginFrameTime = frameTime;
        diff = 0;
        gDouState = false;
        timeCount = 0.0;
        xscale = 0.15;
        yscale = 0.15;
        A = 0.0;
        wave.enable = true;
        turnoff.enable = false;
    }
    if (gDouState) {
        return;
    }
    HPModelEffectFeatureGeneral *feature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"distortion"];
    if (diff > 0.2 && gDouState == false) {
        gDouState = true;
        [feature setUniform:@"u_black" value:@[@(1)]];
        wave.enable = false;
        turnoff.enable = true;
        return;
    }
    xscale = MAX(0.0, xscale - 0.03);
    yscale = MAX(0.0, xscale - 0.0005);
    timeCount = (timeCount+1) % 999;
    [feature setUniform:@"u_xscale" value:@[@(arc4random_uniform(10)/100.0)]];
    [feature setUniform:@"u_yscale" value:@[@(arc4random_uniform(4)/60.0)]];
    [feature setUniform:@"u_time" value:@[@(timeCount/1000.0)]];
    [feature setUniform:@"u_black" value:@[@(0)]];
    
    A = (A + 1) % 8;
    CGFloat offset = floor(A/4) * 180.0;
    HPModelEffectFeatureGeneral *douFeature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"dou"];
    [douFeature setUniform:@"u_texeloffset" value:@[@(offset)]];
    
}

- (void)clear {
    [super clear];
    beginFrameTime = kCMTimeInvalid;
    
}

@end
