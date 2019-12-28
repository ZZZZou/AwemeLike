//
//  HPModelEffect_FlashScreen.m
//  AwemeLike
//
//  Created by wang on 2019/11/10.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPModelEffect_FlashScreen.h"

@implementation HPModelEffect_FlashScreen
{
    CMTime lastFrameTime;
}

- (void)handleTimerEvent:(CMTime)frameTime {
    
    CGFloat timeStep = 0.1;
    CGFloat diff = fabs(CMTimeGetSeconds(CMTimeSubtract(frameTime, lastFrameTime)));
    if (CMTIME_IS_INVALID(lastFrameTime) || diff >= timeStep) {
        lastFrameTime = frameTime;
        NSInteger index = -1;
        for (NSArray *subEffectFeatureList in self.featureList) {
            HPModelEffectFeature *feature = subEffectFeatureList.firstObject;
            if (feature.enable) {
                index = [self.featureList indexOfObject:subEffectFeatureList];
                feature.enable = false;
            }
        }
        index = (index + 1) % self.featureList.count;
        HPModelEffectFeature *feature = self.featureList[index].firstObject;
        feature.enable = true;
    }

}

- (void)clear {
    [super clear];
    lastFrameTime = kCMTimeInvalid;
    
}
@end
