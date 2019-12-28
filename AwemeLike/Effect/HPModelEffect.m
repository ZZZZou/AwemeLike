//
//  HPModelEffect.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/8.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPModelEffectFeature.h"
#import "HPModelEffect.h"

@implementation GPUImageFilter (HPEffect)
- (GLProgram *)program {
    return self->filterProgram;
}
@end

@interface HPModelEffect()
@end
@implementation HPModelEffect
{
    GPUImageFramebuffer *inputFramebuffer;
    
    NSMutableDictionary *bufferedFilters;
    NSMutableDictionary *bufferedFramebuffers;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        bufferedFramebuffers = @{}.mutableCopy;
        
    }
    return self;
}


- (void)handleTimerEvent:(CMTime)frameTime {
   
}

- (void)pushGrabFramebuffer:(NSString *)key {
    GPUImageFramebuffer *framebuffer = bufferedFramebuffers[key];
    [framebuffer unlock];

    bufferedFramebuffers[key] = inputFramebuffer;
    [inputFramebuffer lock];
}

- (HPModelEffectFeature *)getFeatureByName:(NSString *)name {
    HPModelEffectFeature *desFeature;
    for (NSArray *featureList in self.featureList) {
        for (HPModelEffectFeature *feature in featureList) {
            if ([feature.name isEqualToString:name]) {
                desFeature = feature;
                break;
            }
        }
    }
    return desFeature;
}

- (void)clear {
    runAsynchronouslyOnVideoProcessingQueue(^{
    
        [self->bufferedFilters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, GPUImageFilter *obj, BOOL * _Nonnull stop) {
            [obj.framebufferForOutput unlock];
        }];
        [self->bufferedFilters removeAllObjects];
        
        [self->bufferedFramebuffers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, GPUImageFramebuffer *obj, BOOL * _Nonnull stop) {
            [obj unlock];
        }];
        [self->bufferedFramebuffers removeAllObjects];
        
        [self.featureList enumerateObjectsUsingBlock:^(NSArray<HPModelEffectFeature *> * subList, NSUInteger idx, BOOL * _Nonnull stop) {
            [subList enumerateObjectsUsingBlock:^(HPModelEffectFeature * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj clear];
            }];
        }];
    });
}


#pragma mark -
#pragma mark GPUImageInput

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    self->inputTextureSize = newSize;
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex {
    self->inputFramebuffer = newInputFramebuffer;
    [self->inputFramebuffer lock];
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    
    [self handleTimerEvent:frameTime];
    
    
    GPUImageFramebuffer *lastOutputFramebuffer = inputFramebuffer;
    GPUImageFramebuffer *originInputFramebuffer = inputFramebuffer;
    [originInputFramebuffer lock];
    for (NSArray *subEffectFeatureList in self.featureList) {
        
        for (int i = 0; i < subEffectFeatureList.count; i++) {
            HPModelEffectFeature *feature = subEffectFeatureList[i];
            if (!feature.enable) {
                continue;
            }
            GPUImageFilter *theFilter = bufferedFilters[feature.name];
            if (theFilter == nil) {
                theFilter = [feature generateEffectFilter];
            }
            if ([feature isKindOfClass:HPModelEffectFeatureSticker.class]) {
                HPModelEffectFeatureSticker *stickerFeature = (HPModelEffectFeatureSticker *)feature;
                stickerFeature.inputAspect = inputTextureSize.width / inputTextureSize.height;
                [theFilter setInputFramebuffer:lastOutputFramebuffer atIndex:0];
            }else if ([feature isKindOfClass:HPModelEffectFeatureFaceMarkup.class]) {
                [theFilter setInputFramebuffer:lastOutputFramebuffer atIndex:0];
                
            } else if ([feature isKindOfClass:HPModelEffectFeatureLUT.class]) {
                [theFilter setInputFramebuffer:lastOutputFramebuffer atIndex:0];
                
            } else if ([feature isKindOfClass:HPModelEffectFeatureGeneral.class]) {
                HPModelEffectFeatureGeneral *generalFeature = (HPModelEffectFeatureGeneral *)feature;
                generalFeature.inputSize = inputTextureSize;
                [generalFeature setUniformAtProgram:theFilter.program frameTime:frameTime bufferedFilters:bufferedFilters bufferedFramebuffer:bufferedFramebuffers originInputFramebuffer:originInputFramebuffer];
            }
            [theFilter setInputSize:inputTextureSize atIndex:0];
            [theFilter newFrameReadyAtTime:frameTime atIndex:0];
            lastOutputFramebuffer = theFilter.framebufferForOutput;
            bufferedFilters[feature.name] = theFilter;
        }
        
        [lastOutputFramebuffer lock];
        [originInputFramebuffer unlock];
        originInputFramebuffer = lastOutputFramebuffer;
        
        
        [bufferedFilters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, GPUImageFilter *obj, BOOL * _Nonnull stop) {
            [obj.framebufferForOutput unlock];
        }];
        bufferedFilters = @{}.mutableCopy;
        
    }
    
    outputFramebuffer = lastOutputFramebuffer;
    [self informTargetsAboutNewFrameAtTime:frameTime];
    
    [self->inputFramebuffer unlock];
}

- (void)informTargetsAboutNewFrameAtTime:(CMTime)frameTime;
{
    if (self.frameProcessingCompletionBlock != NULL)
    {
        self.frameProcessingCompletionBlock(self, frameTime);
    }
    
    // Get all targets the framebuffer so they can grab a lock on it
    for (id<GPUImageInput> currentTarget in targets)
    {
        if (currentTarget != self.targetToIgnoreForUpdates)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            [self setInputFramebufferForTarget:currentTarget atIndex:textureIndex];
            [currentTarget setInputSize:inputTextureSize atIndex:textureIndex];
        }
    }
    
    [outputFramebuffer unlock];
    [self removeOutputFramebuffer];
    
    // Trigger processing last, so that our unlock comes first in serial execution, avoiding the need for a callback
    for (id<GPUImageInput> currentTarget in targets)
    {
        if (currentTarget != self.targetToIgnoreForUpdates)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            [currentTarget newFrameReadyAtTime:frameTime atIndex:textureIndex];
        }
    }
}


- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
}

- (CGSize)maximumOutputSize {
    return CGSizeZero;
}

- (void)endProcessing {
    for (id<GPUImageInput> currentTarget in targets)
    {
        [currentTarget endProcessing];
    }
}

- (BOOL)wantsMonochromeInput;
{
    return NO;
}

- (NSInteger)nextAvailableTextureIndex {
    return 0;
}


- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue {
}

- (void)dealloc {
    [self clear];
}
@end
