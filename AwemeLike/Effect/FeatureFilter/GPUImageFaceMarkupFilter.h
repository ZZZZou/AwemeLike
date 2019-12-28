//
//  GPUImageFaceMarkupFilter.h
//  AwemeLike
//
//  Created by wang on 2019/9/24.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPModelEffectFeature.h"
#import "GPUImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageFaceMarkupFilter : GPUImageFilter

@property (nonatomic, strong) HPModelEffectFeatureFaceMarkup *markupModel;
@end

NS_ASSUME_NONNULL_END
