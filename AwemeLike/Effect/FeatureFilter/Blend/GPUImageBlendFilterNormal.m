//
//  GPUImageBlendFilterNormal.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/4.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "GPUImageBlendFilterNormal.h"

NSString *const kGPUImageBlendFilterNormalFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform float alphaFactor;
 
 void main()
{
    vec4 fgColor = texture2D(inputImageTexture2, textureCoordinate);
    fgColor = fgColor * alphaFactor;

//    vec4 bgColor = texture2D(inputImageTexture, textureCoordinate2);
//    gl_FragColor = vec4(bgColor.rgb * (1.0 - fgColor.a) + fgColor.rgb * 1., 1.0);
    gl_FragColor = fgColor;
}


 );

@implementation GPUImageBlendFilterNormal


- (id)init {
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageBlendFilterNormalFragmentShaderString]))
    {
        return nil;
    }
    return self;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"%@-Default", NSStringFromClass(self.class)];
}
@end
