//
//  GPUImageBlendFilterHardLight.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/4.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "GPUImageBlendFilterHardLight.h"

NSString *const kGPUImageBlendFilterHardLightFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform float alphaFactor;
 
 float blendHardLight(float base, float blend) {
     return blend<0.5?(2.0*base*blend):(1.0-2.0*(1.0-base)*(1.0-blend));
 }
 
 vec3 blendHardLight(vec3 base, vec3 blend) {
     return vec3(blendHardLight(base.r,blend.r),blendHardLight(base.g,blend.g),blendHardLight(base.b,blend.b));
 }
 
 vec3 blendFunc(vec3 base, vec3 blend, float opacity) {
     return (blendHardLight(base, blend) * opacity + base * (1.0 - opacity));
 }
 
 void main()
{
    vec4 fgColor = texture2D(inputImageTexture2, textureCoordinate);
    fgColor = fgColor * alphaFactor;
    
    vec4 bgColor = texture2D(inputImageTexture, textureCoordinate2);
    if (fgColor.a == 0.0) {
        gl_FragColor = bgColor;
        return;
    }
    
    
    vec3 color = blendFunc(bgColor.rgb, clamp(fgColor.rgb * (1.0 / fgColor.a), 0.0, 1.0), 1.0 );
    gl_FragColor = vec4(bgColor.rgb * (1.0 - fgColor.a) + color.rgb * fgColor.a, 1.0);
}

);

@implementation GPUImageBlendFilterHardLight

- (id)init {
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageBlendFilterHardLightFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@-BlendHardLight", NSStringFromClass(self.class)];
}
@end
