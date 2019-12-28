//
//  GPUImageBlendFilter.h
//  AwemeLike
//
//  Created by w22543 on 2019/11/5.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPModelEffectFeature.h"
#import "GPUImageTwoInputFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageBlendFilter : GPUImageFilter
{
    GPUImageFramebuffer *secondInputFramebuffer;
    GLint filterInputTextureUniform2;
    GLuint alphaFactorUniform;
    GLuint matrixUniform;
    
    GLProgram *secondFilterProgram;
    GLint secondFilterPositionAttribute, secondFilterTextureCoordinateAttribute;
    GLint secondFilterInputTextureUniform;
}
@property (nonatomic, strong) HPModelEffectFeatureSticker *stickerModel;
@end

NS_ASSUME_NONNULL_END
