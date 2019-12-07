//
//  GPUImageBaseBeautyFaceFilter.h
//  AwemeLike
//
//  Created by wang on 2019/10/2.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImageThreeInputFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageBaseBeautyFaceFilter : GPUImageThreeInputFilter

@property(nonatomic, assign) CGFloat sharpen;
@property(nonatomic, assign) CGFloat blurAlpha;
@property(nonatomic, assign) CGFloat white;

@end

NS_ASSUME_NONNULL_END
