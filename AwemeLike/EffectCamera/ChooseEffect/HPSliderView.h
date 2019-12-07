//
//  HPSliderView.h
//  AwemeLike
//
//  Created by w22543 on 2019/10/22.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HPSliderState) {
    HPSliderStateBegin,
    HPSliderStateUpdate,
    HPSliderStateEnd,
};

@interface HPSliderView : UIView

@property(nonatomic) float value;//0-1

@property (nonatomic, copy) void (^valueDidChange)(float value, HPSliderState state);

@end

NS_ASSUME_NONNULL_END
