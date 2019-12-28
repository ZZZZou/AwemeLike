//
//  HPModelEffect_Tremble.m
//  AwemeLike
//
//  Created by wang on 2019/11/10.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPModelEffect_Tremble.h"

static CGFloat move[] = {-2.5, -2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2, 2.5};
static CGFloat big_move[] = {-6.0, -5.5, -5.0, -4.5, -4.0, 4.0, 4.5, 5.0, 5.5, 6.0};

@implementation HPModelEffect_Tremble
{
    CMTime beginFrameTime;
    NSUInteger timer_count;
}

- (void)handleTimerEvent:(CMTime)frameTime {
    if (CMTIME_IS_INVALID(beginFrameTime)) {
        beginFrameTime = frameTime;
    }
    CGFloat diff = CMTimeGetSeconds(CMTimeSubtract(frameTime, beginFrameTime));
    diff = fabs(diff);
    
    HPModelEffectFeatureGeneral *waveFeature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"wave"];
    [waveFeature setUniform:@"iTime" value:@[@(diff)]];
    
    if (timer_count % 5 == 0) {
         HPModelEffectFeatureGeneral *shiftFeature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"shift_color"];
        if (timer_count % 400 == 0) {
            NSInteger array_count = arc4random_uniform(10);
            NSInteger stayed_color =  arc4random_uniform(3);
    
            [shiftFeature setUniform:@"move" value:@[@(big_move[array_count])]];
            [shiftFeature setUniform:@"stay_color" value:@[@(stayed_color)]];
        } else {
            NSInteger array_count = arc4random_uniform(11);
            NSInteger stayed_color =  arc4random_uniform(3);
            
            [shiftFeature setUniform:@"move" value:@[@(move[array_count])]];
            [shiftFeature setUniform:@"stay_color" value:@[@(stayed_color)]];
        }
    }
    timer_count = timer_count + 1;
    
}

- (void)clear {
    [super clear];
    beginFrameTime = kCMTimeInvalid;
    timer_count = 0;
    
}

@end
