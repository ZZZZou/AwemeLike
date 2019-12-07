//
//  GPUImageThinFaceFilter.h
//  AwemeLike
//
//  Created by w22543 on 2019/8/29.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "GPUImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageThinFaceFilter : GPUImageFilter

@property(nonatomic, assign) CGFloat thinFaceDelta;
@property(nonatomic, assign) CGFloat bigEyeDelta;


@end

NS_ASSUME_NONNULL_END
