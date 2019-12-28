//
//  GPUImageBeautyFilter.h
//  AwemeLike
//
//  Created by wang on 2019/10/2.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImageFilterGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageBeautyFaceFilter : GPUImageFilterGroup

@property(readwrite, nonatomic) CGFloat highPassDelta;
@property(nonatomic, assign) CGFloat blurAlpha;
@property(readwrite, nonatomic) CGFloat sharpen;
@property(nonatomic, assign) CGFloat white;
@end

NS_ASSUME_NONNULL_END
