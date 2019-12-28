//
//  HPModelEffect_Mili.m
//  AwemeLike
//
//  Created by wang on 2019/11/10.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPModelEffect_Mili.h"

@implementation HPModelEffect_Mili
{
    NSInteger diff;
    NSInteger count;
    CGFloat intensity;
}

- (instancetype)init {
    if (self = [super init]) {
        diff = 30;
        count = 0;
        intensity = 0.0;
    }
    return self;
}

- (void)handleTimerEvent:(CMTime)frameTime {
    
    HPModelEffectFeatureGeneral *feature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"mili"];
    if (count == 0) {
        intensity = 0.0;
        [feature setUniform:@"intensity" value: @[@(intensity)]];
        [self pushGrabFramebuffer:@"display_texture"];
    } else {
        intensity = intensity + 1.0 / diff;
        if (intensity > 1.0) {
            intensity = 1.0;
        }
        [feature setUniform:@"intensity" value: @[@(intensity)]];
    }
            
    count = count + 1;
    count = count % diff;
}

- (void)clear {
    [super clear];
    count = 0;
    intensity = 0.0;
    
}
@end
