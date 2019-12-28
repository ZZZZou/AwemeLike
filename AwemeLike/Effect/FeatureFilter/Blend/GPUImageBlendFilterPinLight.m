//
//  GPUImageBlendFilterPinLight.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/4.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "GPUImageBlendFilterPinLight.h"

NSString *const kGPUImageBlendFilterPinLightFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform float alphaFactor;
 
 float blendDarken(float base, float blend) {
     return min(blend,base);
 }
 
 float blendLighten(float base, float blend) {
     return max(blend,base);
 }
 
 float blendPinLight(float base, float blend) {
     return (blend<0.5)?blendDarken(base,(2.0*blend)):blendLighten(base,(2.0*(blend-0.5)));
 }
 
 vec3 blendPinLight(vec3 base, vec3 blend) {
     return vec3(blendPinLight(base.r,blend.r),blendPinLight(base.g,blend.g),blendPinLight(base.b,blend.b));
 }
 
 vec3 blendFunc(vec3 base, vec3 blend, float opacity) {
     return (blendPinLight(base, blend) * opacity + base * (1.0 - opacity));
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

@implementation GPUImageBlendFilterPinLight

- (id)init {
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageBlendFilterPinLightFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@-BlendPinLight", NSStringFromClass(self.class)];
}
@end
