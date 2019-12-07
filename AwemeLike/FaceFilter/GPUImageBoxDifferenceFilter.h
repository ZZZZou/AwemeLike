//
//  GPUImageBoxDifferenceFilter.h
//  AwemeLike
//
//  Created by wang on 2019/10/2.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageBoxDifferenceFilter : GPUImageTwoInputFilter

@property(readwrite, nonatomic) CGFloat delta;
@end

NS_ASSUME_NONNULL_END
