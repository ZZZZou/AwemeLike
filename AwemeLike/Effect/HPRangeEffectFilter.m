//
//  HPRangeEffectFilter.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/15.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPRangeEffectManager.h"
#import "HPRangeEffectFilter.h"

@implementation HPRangeEffectFilter
{
    NSMutableArray *nextTargets;
    NSMutableArray *nextTargetTextureLocations;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        nextTargets = [NSMutableArray array];
        nextTargetTextureLocations = [NSMutableArray array];
    }
    return self;
}


- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    
    HPRangeEffectManager *manager = [HPRangeEffectManager shareInstance];
    HPModelRangeEffect *rangeEffect = manager.ongoingRangeEffect;
    if (rangeEffect == nil) {
        rangeEffect = [manager effectAtTime:frameTime];
    }
    
    HPModelEffect *lastEffect = (HPModelEffect *)self.targets.firstObject;
    HPModelEffect *currenEffect = rangeEffect.effect;
    if (currenEffect != nil && currenEffect != lastEffect) {
        [currenEffect clear];
        [super removeAllTargets];
        [self origin_addTarget:currenEffect];
    }
    GPUImageOutput *prevFilter = self;
    if (currenEffect) {
        prevFilter = currenEffect;
    }
    if (prevFilter == self) {
        [super removeAllTargets];
    } else {
        [prevFilter removeAllTargets];
    }
    for (int i = 0; i < nextTargets.count; i++) {
        id<GPUImageInput> theFilter = nextTargets[i];
        NSInteger textureLocation = [nextTargetTextureLocations[i] integerValue];
        if (prevFilter == self) {
            [super addTarget:theFilter atTextureLocation:textureLocation];
        } else {
            [prevFilter addTarget:theFilter atTextureLocation:textureLocation];
        }
    }
    
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
    
}

#pragma mark - Target

- (void)origin_addTarget:(id<GPUImageInput>)newTarget;
{
    NSInteger nextAvailableTextureIndex = [newTarget nextAvailableTextureIndex];
    
    if([targets containsObject:newTarget])
    {
        return;
    }
    cachedMaximumOutputSize = CGSizeZero;
    [self setInputFramebufferForTarget:newTarget atIndex:nextAvailableTextureIndex];
    [self->targets addObject:newTarget];
    [self->targetTextureIndices addObject:[NSNumber numberWithInteger:nextAvailableTextureIndex]];
}

- (void)addTarget:(id<GPUImageInput>)newTarget atTextureLocation:(NSInteger)textureLocation {
    if ([nextTargets containsObject:newTarget]) {
        return;
    }
    [nextTargets addObject:newTarget];
    [nextTargetTextureLocations addObject:@(textureLocation)];
    
}

- (void)removeTarget:(id<GPUImageInput>)targetToRemove {
    NSInteger index = [nextTargets indexOfObject:targetToRemove];
    
    if (index != NSNotFound) {
        [nextTargets removeObjectAtIndex:index];
        [nextTargetTextureLocations removeObjectAtIndex:index];
    }

}

- (void)removeAllTargets {
    [nextTargets removeAllObjects];
    [nextTargetTextureLocations removeAllObjects];
}


@end
