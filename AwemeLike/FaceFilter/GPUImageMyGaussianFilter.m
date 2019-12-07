//
//  GPUImageMyGaussianFilter.m
//  AwemeLike
//
//  Created by wang on 2019/9/29.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImageMyGaussianFilter.h"


NSString *const kGPUImageMyGaussianVertexShaderString = SHADER_STRING
(
 attribute vec3 position;
 attribute vec2 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 uniform float texelWidthOffset;
 uniform float texelHeightOffset;
 varying vec4 textureShift_1;
 varying vec4 textureShift_2;
 varying vec4 textureShift_3;
 varying vec4 textureShift_4;
 
 void main(void)
{
    gl_Position = vec4(position, 1.0);
    textureCoordinate = inputTextureCoordinate;
    
    vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
    textureShift_1 = vec4(textureCoordinate - singleStepOffset, textureCoordinate + singleStepOffset);
    textureShift_2 = vec4(textureCoordinate - 2.0 * singleStepOffset, textureCoordinate + 2.0 * singleStepOffset);
    textureShift_3 = vec4(textureCoordinate - 3.0 * singleStepOffset, textureCoordinate + 3.0 * singleStepOffset);
    textureShift_4 = vec4(textureCoordinate - 4.0 * singleStepOffset, textureCoordinate + 4.0 * singleStepOffset);
}
);

NSString *const kGPUImageMyGaussianFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 varying highp vec2 textureCoordinate;
 varying highp vec4 textureShift_1;
 varying highp vec4 textureShift_2;
 varying highp vec4 textureShift_3;
 varying highp vec4 textureShift_4;
 
 void main()
{
    mediump vec3 sum = texture2D(inputImageTexture, textureCoordinate).rgb;
    sum += texture2D(inputImageTexture, textureShift_1.xy).rgb;
    sum += texture2D(inputImageTexture, textureShift_1.zw).rgb;
    sum += texture2D(inputImageTexture, textureShift_2.xy).rgb;
    sum += texture2D(inputImageTexture, textureShift_2.zw).rgb;
    sum += texture2D(inputImageTexture, textureShift_3.xy).rgb;
    sum += texture2D(inputImageTexture, textureShift_3.zw).rgb;
    sum += texture2D(inputImageTexture, textureShift_4.xy).rgb;
    sum += texture2D(inputImageTexture, textureShift_4.zw).rgb;
    
    gl_FragColor = vec4(sum * 0.1111, 1.0);
}

);

@implementation GPUImageMyGaussianFilter

- (instancetype)init {
    
    self = [super initWithFirstStageVertexShaderFromString:kGPUImageMyGaussianVertexShaderString firstStageFragmentShaderFromString:kGPUImageMyGaussianFragmentShaderString secondStageVertexShaderFromString:kGPUImageMyGaussianVertexShaderString secondStageFragmentShaderFromString:kGPUImageMyGaussianFragmentShaderString];
    if (self) {
        
    }
    return self;
}
@end
