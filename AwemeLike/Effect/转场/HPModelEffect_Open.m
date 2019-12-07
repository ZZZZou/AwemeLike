//
//  HPModelEffect_Open.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/11.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPModelEffect_Open.h"

static CGFloat lower[] = {
    0.5,
    0.5,
    0.4605855855855856,
    0.3795045045045045,
    0.2972972972972973,
    0.22409909909909909,
    0.16328828828828829,
    0.11373873873873874,
    0.07545045045045046,
    0.04504504504504504,
    0.02364864864864865,
    0.009009009009009009,
    0.0011261261261261261,
    0.0
};

static CGFloat upper[] = {
    0.5,
    0.5,
    0.5382882882882883,
    0.6193693693693694,
    0.7015765765765766,
    0.7747747747747747,
    0.8355855855855856,
    0.8851351351351351,
    0.9234234234234234,
    0.9538288288288288,
    0.9752252252252253,
    0.9898648648648649,
    0.9977477477477478,
    1.0
};

@implementation HPModelEffect_Open
{
    CMTime beginFrameTime;
}

- (void)handleTimerEvent:(CMTime)frameTime {
    if (CMTIME_IS_INVALID(beginFrameTime)) {
        beginFrameTime = frameTime;
    }
    CGFloat diff = CMTimeGetSeconds(CMTimeSubtract(frameTime, beginFrameTime));
    diff = fabs(diff);
    if (diff > 1.75) {
        beginFrameTime = frameTime;
        diff = 0;
    }
    NSInteger gFPS = 16;
    NSInteger frameCount = MIN(floor(diff * gFPS), sizeof(upper)/sizeof(CGFloat)-1);
    
    HPModelEffectFeatureGeneral *feature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"black"];
    [feature setUniform:@"upper" value:@[@(upper[frameCount])]];
    [feature setUniform:@"lower" value:@[@(lower[frameCount])]];
    
//    NSLog(@"%f, %f", lower[frameCount], upper[frameCount]);
}

- (void)clear {
    [super clear];
    beginFrameTime = kCMTimeInvalid;
    
}
@end
