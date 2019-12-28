//
//  GPUImageGaussianHighPassFilter.h
//  AwemeLike
//
//  Created by wang on 2019/9/30.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImageFilterGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageBoxHighPassFilter : GPUImageFilterGroup
@property(readwrite, nonatomic) CGFloat delta;
@property (readwrite, nonatomic) CGFloat blurRadiusInPixels;
@end

NS_ASSUME_NONNULL_END
