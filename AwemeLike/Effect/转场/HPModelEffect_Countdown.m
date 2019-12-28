//
//  HPModelEffect_Countdown.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/11.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPModelEffect_Countdown.h"

@implementation HPModelEffect_Countdown
{
    CMTime beginFrameTime;
}

- (void)handleTimerEvent:(CMTime)frameTime {
    if (CMTIME_IS_INVALID(beginFrameTime)) {
        beginFrameTime = frameTime;
    }
    CGFloat diff = CMTimeGetSeconds(CMTimeSubtract(frameTime, beginFrameTime));
    diff = fabs(diff);
    if (diff > 1.750) {
        beginFrameTime = frameTime;
        diff = 0;
    }
    NSInteger gFPS = 16;
    NSInteger frameCount = diff * gFPS;
    CGFloat scale = 0;
    CGFloat angle = 0;
    
    if (frameCount <= 7 && frameCount > 0) {
        scale = frameCount * 0.028571;
    } else if (frameCount > 7 && frameCount <= 13) {
        scale = (13 - frameCount) * 0.028571;
    } else if (frameCount > 13 && frameCount <= 18) {
        scale = (frameCount - 13) * 0.04;
    } else if (frameCount >= 20 && frameCount <= 24) {
        scale = 0.76 - (frameCount - 20) * 0.22;
        angle = 3.14 / 6 - (frameCount - 20) * 3.14 / 18;
    }
    
    HPModelEffectFeatureGeneral *feature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"baseDraw"];
    [feature setUniform:@"scaling" value:@[@(scale)]];
    [feature setUniform:@"angle" value:@[@(angle)]];
}

- (void)clear {
    [super clear];
    beginFrameTime = kCMTimeInvalid;
    
}
@end
