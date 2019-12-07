//
//  HPVideoTimeLineView.m
//  AwemeLike
//
//  Created by wang on 2019/10/24.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPVideoEffectTimeLineView.h"

@implementation HPVideoEffectTimeLineRangeModel

@end

@interface HPVideoEffectTimeLineView()

@property(nonatomic, strong) UIView *backgroundView;
@property(nonatomic, strong) UIView *rangeViewContainer;
@property(nonatomic, strong) HPSliderView *slider;
@property(nonatomic, strong) UIView *trackRangeView;

@property(nonatomic, copy) NSArray<CALayer *> *backgroundImageLayerList;

@property(nonatomic, strong) NSMutableArray<UIView *> *cachedRangeViewList;
@property(nonatomic, strong) NSMutableArray<UIView *> *usedRangeViewList;
@end

@implementation HPVideoEffectTimeLineView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    //background image layer
    self.backgroundView.frame = self.bounds;
    CGFloat imgWidth = width / self.numOfBackgroundImage;
    [self.backgroundImageLayerList enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(imgWidth * idx, 0, imgWidth, height);
    }];
    
    //range view
    self.rangeViewContainer.frame = self.bounds;
    [self.rangeModelList enumerateObjectsUsingBlock:^(HPVideoEffectTimeLineRangeModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *rangeView = self.usedRangeViewList[idx];
        rangeView.frame = CGRectMake(obj.startPosition * width, 0, obj.length * width, height);
    }];
    
    //slider
    self.slider.frame = CGRectMake(0, 0, width, height);
}

- (instancetype)initWithFrame:(CGRect)frame numOfBackgroundImage:(NSInteger)numOfBackgroundImage {
    self = [super initWithFrame:frame];
    if (self) {
        self.numOfBackgroundImage = numOfBackgroundImage;
        [self initView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (void)initView {
    
    self.usedRangeViewList = @[].mutableCopy;
    self.cachedRangeViewList = @[].mutableCopy;
    
    self.backgroundView = [UIView new];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundView.clipsToBounds = true;
    [self addSubview:self.backgroundView];
    
    [self initBackgroundImageLayer];
    
    self.rangeViewContainer = [UIView new];
    self.rangeViewContainer.backgroundColor = UIColor.clearColor;
    [self addSubview:self.rangeViewContainer];
    
    [self initSlider];
    
    self.clipsToBounds = true;
}

- (void)initBackgroundImageLayer {
    [self.backgroundImageLayerList enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    NSMutableArray *layers = @[].mutableCopy;
    NSInteger index = 0;
    while (index < self.numOfBackgroundImage) {
        CALayer *layer = [CALayer layer];
        layer.contentsGravity = @"resizeAspectFill";
        [self.backgroundView.layer addSublayer:layer];
        [layers addObject:layer];
        index += 1;
    }
    self.backgroundImageLayerList = layers;
}

- (void)initSlider {
    self.slider = [[HPSliderView alloc] init];
    self.slider.backgroundColor = [UIColor clearColor];
    [self addSubview:self.slider];
    __weak typeof(self) wself = self;
    self.slider.valueDidChange = ^(float value, HPSliderState state) {
        __strong typeof(wself) self = wself;
        self.progress = value;
        if (self.progressDidChange) {
            self.progressDidChange(value, state);
        }
       
    };
}

- (void)setRangeModelList:(NSArray<HPVideoEffectTimeLineRangeModel*> *)rangeModelList {
    _rangeModelList = rangeModelList;
    
    [self resetRangeView];
}

- (void)resetRangeView {
    [self.usedRangeViewList enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.cachedRangeViewList addObjectsFromArray:self.usedRangeViewList];
    [self.usedRangeViewList removeAllObjects];
    
    [self.rangeModelList enumerateObjectsUsingBlock:^(HPVideoEffectTimeLineRangeModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *rangeView = [self getRangeView];
        rangeView.backgroundColor = obj.color;
        [self.rangeViewContainer addSubview:rangeView];
        [self.usedRangeViewList addObject:rangeView];
    }];
    
    [self setNeedsLayout];
}

- (UIView *)getRangeView {
    UIView *view = self.cachedRangeViewList.lastObject;
    if (view) {
        [self.cachedRangeViewList removeLastObject];
    } else {
        view = [UIView new];
    }
    return view;
}

- (void)beginTrackRangeView:(UIColor *)color {
    
    UIView *rangeView = [self getRangeView];
    rangeView.frame = CGRectMake(self.progress * self.bounds.size.width, 0, 0, self.bounds.size.height);
    rangeView.backgroundColor = color;
    
    [self.rangeViewContainer addSubview:rangeView];
    [self.usedRangeViewList addObject:rangeView];
    
    self.trackRangeView = rangeView;
}

- (void)updateTrackRangeView {
    
    CGFloat currentX = self.progress * self.bounds.size.width;
    CGRect frame = self.trackRangeView.frame;
    frame.size.width = currentX - frame.origin.x;
    self.trackRangeView.frame = frame;
}

- (void)endTrackRangeView {
    self.trackRangeView = nil;
}


- (void)setNumOfBackgroundImage:(NSInteger)numOfBackgroundImage {
    _numOfBackgroundImage = numOfBackgroundImage;
    [self initBackgroundImageLayer];
}

- (void)setBackgroundImage:(UIImage *)image at:(NSInteger)index {
    if (index >= self.backgroundImageLayerList.count) {
        return;
    }
    CALayer *layer = self.backgroundImageLayerList[index];
    layer.contents = (__bridge id _Nullable)(image.CGImage);
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.slider.value = progress;
}
@end
