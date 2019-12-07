//
//  HPSliderView.m
//  AwemeLike
//
//  Created by w22543 on 2019/10/22.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPSliderView.h"

@interface HPSliderView()
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@end

@implementation HPSliderView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    self.controlView.frame = CGRectMake(0, 0, size.height + 16, size.height + 16);
    CGPoint center = self.controlView.center;
    center.x = self.value * size.width;
    center.y =  size.height/2;
    self.controlView.center = center;
    
    self.line.frame = CGRectMake(0, 0, 4, size.height + 12);
    self.line.center = CGPointMake(self.controlView.bounds.size.width/2, self.controlView.bounds.size.height/2);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self =[super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    self.controlView = [UIView new];
    self.controlView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.controlView];
    
    self.line = [UIView new];
    self.line.backgroundColor = [UIColor whiteColor];
    [self.controlView addSubview:self.line];
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.controlView addGestureRecognizer:self.pan];
    
}

- (void)handleGesture:(UIPanGestureRecognizer *)pan {
    
    CGPoint point = [pan translationInView:self.controlView];
    CGFloat x = self.controlView.center.x;
    x = x + point.x;
    if (x < 0) {
        x = 0;
    } else if (x > self.bounds.size.width) {
        x = self.bounds.size.width;
    }
    self.value = x / self.bounds.size.width;

    [pan setTranslation:CGPointZero inView:self.controlView];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        if (self.valueDidChange) {
            self.valueDidChange(self.value, HPSliderStateBegin);
        }
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        if (self.valueDidChange) {
            self.valueDidChange(self.value, HPSliderStateUpdate);
        }
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        if (self.valueDidChange) {
            self.valueDidChange(self.value, HPSliderStateEnd);
        }
    }
    
}

- (void)setValue:(float)value {
    _value = value;
    if (value < 0) {
        value = 0;
    } else if (value > 1) {
        value = 1;
    }
    CGPoint center = self.controlView.center;
    center.x = value * self.bounds.size.width;
    self.controlView.center = center;
}

@end
