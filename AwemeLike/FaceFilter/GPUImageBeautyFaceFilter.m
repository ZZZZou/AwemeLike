//
//  GPUImageBeautyFilter.m
//  AwemeLike
//
//  Created by wang on 2019/10/2.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImageBoxBlurFilter.h"
#import "GPUImageBoxHighPassFilter.h"
#import "GPUImageBaseBeautyFaceFilter.h"
#import "GPUImageBeautyFaceFilter.h"

@implementation GPUImageBeautyFaceFilter
{
    GPUImageGaussianBlurFilter *boxBlurFilter;
    GPUImageBoxHighPassFilter *boxHighPassFilter;
    GPUImageBaseBeautyFaceFilter *beautyFilter;
}

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    boxBlurFilter = [[GPUImageBoxBlurFilter alloc] init];
    [self addFilter:boxBlurFilter];
    
    boxHighPassFilter = [[GPUImageBoxHighPassFilter alloc] init];
    [self addFilter:boxHighPassFilter];
    
    beautyFilter = [[GPUImageBaseBeautyFaceFilter alloc] init];
    [self addFilter:beautyFilter];
    
    [boxBlurFilter addTarget:beautyFilter atTextureLocation:1];
    [boxHighPassFilter addTarget:beautyFilter atTextureLocation:2];
    
    self.initialFilters = [NSArray arrayWithObjects:boxBlurFilter, boxHighPassFilter, beautyFilter, nil];
    self.terminalFilter = beautyFilter;
    
    [self setBlurRadiusInPixels:4];
    boxBlurFilter.texelSpacingMultiplier = 4;
    
    self.white =  0.2;
    self.blurAlpha = 0.5;
    self.sharpen = 0.5;
    
    return self;
}

- (void)setHighPassDelta:(CGFloat)highPassDelta {
    boxHighPassFilter.delta = highPassDelta;
}

- (void)setBlurAlpha:(CGFloat)blurAlpha {
    beautyFilter.blurAlpha = blurAlpha;
}

- (void)setSharpen:(CGFloat)sharpen {
    beautyFilter.sharpen = sharpen;
}

- (void)setWhite:(CGFloat)white {
    beautyFilter.white = white;
}

- (void)setBlurRadiusInPixels:(CGFloat)blurRadiusInPixels {
    boxBlurFilter.blurRadiusInPixels = blurRadiusInPixels;
    boxHighPassFilter.blurRadiusInPixels = blurRadiusInPixels;
}
@end
