//
//  HPModelEffect_FaculaBlur.m
//  AwemeLike
//
//  Created by wang on 2019/11/11.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPModelEffect_FaculaBlur.h"

@implementation HPModelEffect_FaculaBlur
{
    CMTime beginFrameTime;
}

- (void)handleTimerEvent:(CMTime)frameTime {
    if (CMTIME_IS_INVALID(beginFrameTime)) {
        beginFrameTime = frameTime;
    }
    CGFloat diff = CMTimeGetSeconds(CMTimeSubtract(frameTime, beginFrameTime));
    diff = fabs(diff);
    if (diff > 3.0) {
        beginFrameTime = frameTime;
    }
   
    HPModelEffectFeatureGeneral *feature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"bufferB"];
    
    CGFloat degree = MAX(0.0, sin((diff * M_PI + M_PI)/3.2));
    degree = 5 * MIN(1.0, degree);
    [feature setUniform:@"radius" value:@[@(degree)]];
}

- (void)clear {
    [super clear];
    beginFrameTime = kCMTimeInvalid;
    
}
@end
