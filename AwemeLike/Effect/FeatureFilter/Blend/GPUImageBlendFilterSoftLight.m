//
//  GPUImageBlendFilterSoftLight.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/4.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "GPUImageBlendFilterSoftLight.h"

NSString *const GPUImageBlendFilterSoftLightFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform float alphaFactor;
 
 float blendSoftLight(float base, float blend) {
     return (blend<0.5)?(base+(2.0*blend-1.0)*(base-base*base)):(base+(2.0*blend-1.0)*(sqrt(base)-base));
 }
 
 vec3 blendSoftLight(vec3 base, vec3 blend) {
     return vec3(blendSoftLight(base.r,blend.r),blendSoftLight(base.g,blend.g),blendSoftLight(base.b,blend.b));
 }
 
 vec3 blendFunc(vec3 base, vec3 blend, float opacity) {
     return (blendSoftLight(base, blend) * opacity + base * (1.0 - opacity));
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

@implementation GPUImageBlendFilterSoftLight

- (id)init {
    if (!(self = [super initWithFragmentShaderFromString:GPUImageBlendFilterSoftLightFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@-BlendSoftLight", NSStringFromClass(self.class)];
}
@end
