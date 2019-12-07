//
//  HPRangeEffectManager.m
//  AwemeLike
//
//  Created by w22543 on 2019/10/23.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPRangeEffectManager.h"

@implementation HPModelRangeEffect

- (BOOL)containt:(CMTime)time {
    
    return CMTIME_COMPARE_INLINE(time, >=, self.sequenceIn) && CMTIME_COMPARE_INLINE(time, <=, self.sequenceOut);
}

@end

@interface HPRangeEffectManager()

@property (nonatomic, strong) NSMutableArray<HPModelRangeEffect *> *allEffects;
@end

@implementation HPRangeEffectManager

static HPRangeEffectManager *share;
+ (instancetype)shareInstance {
    if (share == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            share = [HPRangeEffectManager new];
        });
    }
    return share;
}

- (NSArray<HPModelRangeEffect *> *)filterEffects {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(HPModelRangeEffect *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        return evaluatedObject.type == HPEffectTypeFilter;
    }];
    
    return [self.allEffects filteredArrayUsingPredicate:predicate];
}

- (NSArray<HPModelRangeEffect *> *)faceMarkupEffects {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(HPModelRangeEffect *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        return evaluatedObject.type == HPEffectTypeFaceMarkup;
    }];
    
    return [self.allEffects filteredArrayUsingPredicate:predicate];
}

- (NSArray<HPModelRangeEffect *> *)splitScreenEffects {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(HPModelRangeEffect *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        return evaluatedObject.type == HPEffectTypeSplitScreen;
    }];
    
    return [self.allEffects filteredArrayUsingPredicate:predicate];
}

- (NSArray<HPModelRangeEffect *> *)transitionEffects {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(HPModelRangeEffect *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        return evaluatedObject.type == HPEffectTypeTransition;
    }];
    
    return [self.allEffects filteredArrayUsingPredicate:predicate];
}

- (void)addEffect:(HPModelRangeEffect *)Effect {
    if (self.allEffects == nil) {
        self.allEffects = @[].mutableCopy;
    }
    [self.allEffects addObject:Effect];
}

- (HPModelRangeEffect *)removeLastEffectByType:(HPEffectType)EffectType {
    __block NSInteger index = -1;
    [self.allEffects enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HPModelRangeEffect * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == EffectType) {
            index = idx;
            *stop = true;
        }
    }];
    
    HPModelRangeEffect *delEffect;
    if (index != -1) {
        delEffect = self.allEffects[index];
        [self.allEffects removeObjectAtIndex:index];
    }
    
    return delEffect;
}

- (void)clear {
    [self.allEffects removeAllObjects];
}

- (HPModelRangeEffect *)effectAtTime:(CMTime)time {
    
    __block HPModelRangeEffect *Effect;
    [self.allEffects enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HPModelRangeEffect * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj containt:time]) {
            Effect = obj;
            *stop = true;
        }
    }];
    
    return Effect;
    
}

- (HPRangeEffectFilter *)generateFilter {
    return [HPRangeEffectFilter new];
}

@end
