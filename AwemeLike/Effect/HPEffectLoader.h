//
//  HPEffectLoader.h
//  AwemeLike
//
//  Created by w22543 on 2019/11/6.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPModelEffect.h"
#import "HPModelEffectFeature.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HPEffectLoader : NSObject
+ (NSDictionary *)loadLUTEffectModelFromLocal;
+ (NSDictionary *)loadEffectModelFromLocal;
@end

NS_ASSUME_NONNULL_END
