//
//  HPEffectManager.h
//  AwemeLike
//
//  Created by w22543 on 2019/11/8.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPModelEffectFeature.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HPModelEffect : GPUImageOutput<GPUImageInput>

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSArray<NSArray<HPModelEffectFeature *>*> *featureList;

- (void)clear;
- (void)handleTimerEvent:(CMTime)frameTime;
- (void)pushGrabFramebuffer:(NSString *)key;
- (HPModelEffectFeature *)getFeatureByName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
