//
//  HPRangeEffectManager.h
//  AwemeLike
//
//  Created by w22543 on 2019/10/23.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPRangeEffectFilter.h"
#import "HPModelEffect.h"
#import "GPUImage.h"
#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HPEffectType) {
    HPEffectTypeFilter = 0,
    HPEffectTypeFaceMarkup = 1,
    HPEffectTypeSplitScreen = 2,
    HPEffectTypeTransition =3,
};

@interface HPModelRangeEffect : NSObject

@property (nonatomic, assign) HPEffectType type;

@property(nonatomic, assign) CMTime sequenceIn;
@property(nonatomic, assign) CMTime sequenceOut;

@property(nonatomic, strong) UIColor *color;
@property(nonatomic, strong) HPModelEffect *effect;

@end

@interface HPRangeEffectManager : NSObject

@property (nonatomic, strong) HPModelRangeEffect *ongoingRangeEffect;
@property (nonatomic, readonly) NSArray<HPModelRangeEffect *> *filterEffects;
@property (nonatomic, readonly) NSArray<HPModelRangeEffect *> *faceMarkupEffects;
@property (nonatomic, readonly) NSArray<HPModelRangeEffect *> *splitScreenEffects;
@property (nonatomic, readonly) NSArray<HPModelRangeEffect *> *transitionEffects;

+ (instancetype)shareInstance;

- (void)addEffect:(HPModelRangeEffect *)effect;
- (HPModelRangeEffect *)removeLastEffectByType:(HPEffectType)effectType;
- (void)clear;

- (HPModelRangeEffect *)effectAtTime:(CMTime)time;

- (HPRangeEffectFilter *)generateFilter;
@end

