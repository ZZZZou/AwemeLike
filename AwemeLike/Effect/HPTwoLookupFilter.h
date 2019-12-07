//
//  HPTwoLookupFilter.h
//  AwemeLike
//
//  Created by wang on 2019/11/17.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface HPTwoLookupFilter : GPUImageFilter

- (instancetype)initWithLeftLUTPath:(NSString *)leftLUTPath leftIntensity:(CGFloat)leftIntensity rightLUTPath:(NSString *)rightLUTPath rightIntensity:(CGFloat)rightIntensity split:(CGFloat)split;
- (void)updatesplit:(CGFloat)split;
@end

NS_ASSUME_NONNULL_END
