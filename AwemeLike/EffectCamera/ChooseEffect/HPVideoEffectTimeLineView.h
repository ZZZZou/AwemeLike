//
//  HPVideoTimeLineView.h
//  AwemeLike
//
//  Created by wang on 2019/10/24.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPSliderView.h"
#import <UIKit/UIKit.h>

@interface HPVideoEffectTimeLineRangeModel : NSObject
@property(nonatomic, assign) CGFloat startPosition;
@property(nonatomic, assign) CGFloat length;
@property(nonatomic, strong) UIColor *color;
@end

@class HPVideoEffectTimeLineView;

//@protocol HPVideoEffectTimeLineViewDelegate <NSObject>

//- (void)timeLineView:(HPVideoEffectTimeLineView *)timeLineView didUpdateProgress:(CGFloat)progress;

//- (NSInteger)numOfBackgroundImageInTimeLineView:(HPVideoEffectTimeLineView *)timeLineView;
//- (UIImage *)timeLineView:(HPVideoEffectTimeLineView *)timeLineView backgroundImageForIndex:(NSInteger)index;
//@end

@interface HPVideoEffectTimeLineView : UIView

- (instancetype)initWithFrame:(CGRect)frame numOfBackgroundImage:(NSInteger)numOfBackgroundImage;
@property(nonatomic, assign) NSInteger numOfBackgroundImage;
- (void)setBackgroundImage:(UIImage *)image at:(NSInteger)index;

@property(nonatomic, copy) NSArray<HPVideoEffectTimeLineRangeModel*> *rangeModelList;
- (void)beginTrackRangeView:(UIColor *)color;
- (void)updateTrackRangeView;
- (void)endTrackRangeView;

@property(nonatomic, assign) CGFloat progress;
@property(nonatomic, copy) void(^progressDidChange)(CGFloat progress, HPSliderState state);

@end

