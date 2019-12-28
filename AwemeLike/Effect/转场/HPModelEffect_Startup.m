//
//  HPModelEffect_Startup.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/11.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPModelEffect_Startup.h"

@implementation HPModelEffect_Startup
{
    CMTime beginFrameTime;
    
    BOOL gDouState;
    BOOL gBeginState;
    CGFloat xscale;
    CGFloat yscale;
    NSInteger timeCount;
    NSInteger A;
    
    CGFloat black;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        gBeginState = false;
        gDouState = false;
        timeCount = 0.0;
        xscale = 0.15;
        yscale = 0.15;
        A = 0.0;
        
        black = 0;
    }
    return self;
}

/**
 - 0-0.5：播放turnon
 - 0.5-1.0：逐渐显示全屏
 - 1.0-1.7
 */
- (void)handleTimerEvent:(CMTime)frameTime {
    
    HPModelEffectFeatureSticker *wave = (HPModelEffectFeatureSticker *)[self getFeatureByName:@"clipname2"];
    HPModelEffectFeatureSticker *turnon = (HPModelEffectFeatureSticker *)[self getFeatureByName:@"clipname1"];
    HPModelEffectFeatureGeneral *feature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"distortion"];
    HPModelEffectFeatureGeneral *douFeature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"dou"];
    if (CMTIME_IS_INVALID(beginFrameTime)) {
        beginFrameTime = frameTime;
        
        gDouState = false;
        gBeginState = false;
        timeCount = 0.0;
        xscale = 0.15;
        yscale = 1.0;
        A = 0.0;
        black = 0;
        
        feature.enable = true;
        douFeature.enable = true;
        wave.enable = false;
        turnon.enable = true;
        [feature setUniform:@"u_black" value:@[@(0)]];
    }
    CGFloat diff = CMTimeGetSeconds(CMTimeSubtract(frameTime, beginFrameTime));
    diff = fabs(diff);
    
    if (diff > 1.7) {
        beginFrameTime = frameTime;
        diff = 0;
        gDouState = false;
        gBeginState = false;
        timeCount = 0.0;
        xscale = 0.15;
        yscale = 1.0;
        A = 0.0;
        black = 0;
        
        feature.enable = true;
        douFeature.enable = true;
        wave.enable = false;
        turnon.enable = true;
        [feature setUniform:@"u_black" value:@[@(0)]];
    }
    
    if (diff >= 0.5 && !gBeginState) {
        turnon.enable = false;
        wave.enable = true;
        
        beginFrameTime = frameTime;
        gBeginState = true;
    }
    
    if (!gBeginState || gDouState) {
        return;
    }
    
    if (diff > 1.0 && gDouState == false) {
        gDouState = true;
        
        feature.enable = false;
        douFeature.enable = false;
    }
    
    black = MIN(black+0.2, 1.0);
    xscale = MAX(0.0, xscale - 0.03);
    timeCount = (timeCount+1) % 999;
    [feature setUniform:@"u_xscale" value:@[@(xscale)]];
    [feature setUniform:@"u_yscale" value:@[@(0)]];
    [feature setUniform:@"u_time" value:@[@(timeCount/1000.0)]];
    [feature setUniform:@"u_black" value:@[@(black)]];
    
    A = (A + 1) % 8;
    CGFloat offset = floor(A/4) * 100.0;
    [douFeature setUniform:@"u_texeloffset" value:@[@(offset)]];
}

- (void)clear {
    [super clear];
    beginFrameTime = kCMTimeInvalid;
    
}
@end
