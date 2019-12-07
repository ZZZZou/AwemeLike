//
//  GPUImageGaussianHighPassFilter.m
//  AwemeLike
//
//  Created by wang on 2019/9/30.
//  Copyright © 2019 Hytera. All rights reserved.
//

//高反差滤波：继承group -> 大高斯和twoinput作为初始化滤波器 -> 源frame作为大高斯的第一个frame，大高斯作为twoinput的第二个frame                                                                                                     高反差滤波->小高斯保边
#import "GPUImageBoxBlurFilter.h"
#import "GPUImageBoxDifferenceFilter.h"
#import "GPUImageBoxHighPassFilter.h"

@implementation GPUImageBoxHighPassFilter
{
    GPUImageGaussianBlurFilter *boxBlurFilter;
    GPUImageBoxDifferenceFilter *boxDifferenceFilter;
}

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    boxBlurFilter = [[GPUImageBoxBlurFilter alloc] init];
    [self addFilter:boxBlurFilter];
    
    // Take the difference of the current frame from the low pass filtered result to get the high pass
    boxDifferenceFilter = [[GPUImageBoxDifferenceFilter alloc] init];
    [self addFilter:boxDifferenceFilter];
    
    // Texture location 0 needs to be the original image for the difference blend
    [boxBlurFilter addTarget:boxDifferenceFilter atTextureLocation:1];
    
    self.initialFilters = [NSArray arrayWithObjects:boxBlurFilter, boxDifferenceFilter, nil];
    self.terminalFilter = boxDifferenceFilter;
    
    boxBlurFilter.texelSpacingMultiplier = 4;
    return self;
}

- (void)setDelta:(CGFloat)delta {
    boxDifferenceFilter.delta = delta;
}

- (void)setBlurRadiusInPixels:(CGFloat)blurRadiusInPixels {
    boxBlurFilter.blurRadiusInPixels = blurRadiusInPixels;
}
@end
