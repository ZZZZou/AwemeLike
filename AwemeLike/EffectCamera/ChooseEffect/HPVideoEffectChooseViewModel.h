//
//  HPVideoEffectChooseViewModel.h
//  AwemeLike
//
//  Created by w22543 on 2019/10/25.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPModelEffect.h"
#import "HPPlayer.h"
#import "HPRangeEffectManager.h"
#import "GPUImage.h"
#import <Foundation/Foundation.h>

@interface HPVideoEffectChooseEffectItem : NSObject
@property(nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *imgName;
@property (nonatomic, strong) UIColor *color;

@property(nonatomic, assign) BOOL selected;
@property(nonatomic, strong) HPModelEffect *effect;

@property(nonatomic, assign) CGFloat timeLoop;

@end

@interface HPVideoEffectChooseViewModel : NSObject

@property(nonatomic, assign) NSInteger currentSection;
@property(nonatomic, copy, readonly) NSArray<HPVideoEffectChooseEffectItem *> *currentEffectItems;
@property(nonatomic, copy, readonly) NSArray<HPModelRangeEffect *> *currentRangeEffects;
@property(nonatomic, copy) void(^progressDidChange)(CGFloat progress);

@property(nonatomic, strong) UIView *preview;
@property(nonatomic, assign) CGFloat musicVolume;
@property(nonatomic, assign) CGFloat originVolume;

- (instancetype)initWithVideoFilePath:(NSString *)videoFilePath musicFilePath:(NSString *)musicFilePath;

- (void)play;
- (void)pause;
- (BOOL)isPlaying;
- (CGFloat)duration;
- (void)seekTimeToProgress:(CGFloat)progress;
- (void)seekTimeToProgress:(CGFloat)progress state:(HPPlayerSeekTimeStatus)state;
- (void)presentFirstFrameBuffer;
- (void)decodeImage:(NSInteger)num scaleToWidth:(CGFloat)targetWidth completion:(void(^)(UIImage *img, NSInteger index))completion;

- (void)beginLongPressAtIndex:(NSInteger)index;
- (void)endLongPress;
- (void)tapTransitionEffectAtIndex:(NSInteger)index;

- (HPModelRangeEffect *)removeLastRangeEffect;
- (void)removeAllRangeEffect;

@end


