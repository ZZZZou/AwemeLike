//
//  HPModelEffect_Pane.m
//  AwemeLike
//
//  Created by wang on 2019/11/10.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPModelEffect_Pane.h"

@implementation HPModelEffect_Pane
{
    BOOL initFlag;
    CGFloat width;
    CGFloat xPos;
    CGFloat speed;
}

- (instancetype)init {
    if (self = [super init]) {
        initFlag = true;
        width = 0.55;
        xPos = -0.55;
        speed = 0.04;
    }
    return self;
}

- (void)handleTimerEvent:(CMTime)frameTime {
    HPModelEffectFeatureGeneral *feature = (HPModelEffectFeatureGeneral *)[self getFeatureByName:@"mlcg_1"];
    if (initFlag) {
        xPos = -width;
        [self pushGrabFramebuffer:@"mlcgTexture"];
        
        [feature setUniform:@"xPos" value: @[@(xPos)]];
        initFlag = false;
    } else {
        xPos = xPos + speed;
        [feature setUniform:@"xPos" value: @[@(xPos)]];
    }
    if (xPos > 1.0){
        xPos = -width;
        [self pushGrabFramebuffer:@"mlcgTexture"];
        [feature setUniform:@"xPos" value: @[@(xPos)]];
    }
}

- (void)clear {
    [super clear];
    xPos = -width;
    initFlag = true;
}
@end
