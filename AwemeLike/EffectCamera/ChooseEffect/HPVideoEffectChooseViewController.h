//
//  HPVideoEffectChooseViewController.h
//  AwemeLike
//
//  Created by wang on 2019/10/20.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPVideoEffectChooseViewModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HPVideoEffectChooseViewController : UIViewController

@property(nonatomic, strong) UIImage *transitionImage;
@property(nonatomic, strong) HPVideoEffectChooseViewModel *vm;
- (UIView *)videoView;
- (UIView *)bottomView;
@end

@interface HPVideoEffectChooseViewController(Transitioning)<UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@end

NS_ASSUME_NONNULL_END
