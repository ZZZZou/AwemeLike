//
//  HPModelEffect_Vision.m
//  AwemeLike
//
//  Created by wang on 2019/11/10.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPModelEffect_Vision.h"

@implementation HPModelEffect_Vision

- (void)handleTimerEvent:(CMTime)frameTime {
    static int counter = 0;
    if (counter == 0) {
        [self pushGrabFramebuffer:@(HPModelEffectFeatureGeneralUniformTypeInputTextureLast).description];
    }
    counter = (counter + 1) % 4;
}

@end
