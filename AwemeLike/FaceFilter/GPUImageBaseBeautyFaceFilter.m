//
//  GPUImageBaseBeautyFaceFilter.m
//  AwemeLike
//
//  Created by wang on 2019/10/2.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImagePicture.h"
#import "GPUImageBaseBeautyFaceFilter.h"


NSString *const kGPUImageBaseBeautyFaceVertexShaderString = SHADER_STRING
(
 attribute vec3 position;
 attribute vec2 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 varying vec4 textureShift_1;
 varying vec4 textureShift_2;
 varying vec4 textureShift_3;
 varying vec4 textureShift_4;
 
 uniform float widthOffset;
 uniform float heightOffset;
 void main(void)
{
    gl_Position = vec4(position, 1.0);
    textureCoordinate = inputTextureCoordinate;
    textureShift_1 = vec4(inputTextureCoordinate + vec2(-widthOffset,0.0),inputTextureCoordinate + vec2(widthOffset,0.0));
    textureShift_2 = vec4(inputTextureCoordinate + vec2(0.0,-heightOffset),inputTextureCoordinate + vec2(0.0,heightOffset));
    textureShift_3 = vec4(inputTextureCoordinate + vec2(widthOffset,heightOffset),inputTextureCoordinate + vec2(-widthOffset,-heightOffset));
    textureShift_4 = vec4(inputTextureCoordinate + vec2(-widthOffset,heightOffset),inputTextureCoordinate + vec2(widthOffset,-heightOffset));
}
);


NSString *const kGPUImageBaseBeautyFaceFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying highp vec2 textureCoordinate;
 varying highp vec4 textureShift_1;
 varying highp vec4 textureShift_2;
 varying highp vec4 textureShift_3;
 varying highp vec4 textureShift_4;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 uniform sampler2D lookUpGray;
 uniform sampler2D lookUpOrigin;
 uniform sampler2D lookUpSkin;
 uniform sampler2D lookUpCustom;
 
 uniform highp float sharpen;
 uniform highp float blurAlpha;
 uniform highp float whiten;
 
 const float levelRangeInv = 1.02657;
 const float levelBlack = 0.0258820;
 const float alpha = 0.7;
 
 void main()
{
    lowp vec4 iColor = texture2D(inputImageTexture, textureCoordinate);
    lowp vec4 meanColor = texture2D(inputImageTexture2, textureCoordinate);
    lowp vec4 varColor = texture2D(inputImageTexture3, textureCoordinate);
    
    lowp float theta = 0.1;
    mediump float p = clamp((min(iColor.r, meanColor.r - 0.1) - 0.2) * 4.0, 0.0, 1.0);
    mediump float meanVar = (varColor.r + varColor.g + varColor.b) / 3.0;
    mediump float kMin;
    highp vec3 resultColor;
    kMin = (1.0 - meanVar / (meanVar + theta)) * p * blurAlpha;
    kMin = clamp(kMin, 0.0, 1.0);
    resultColor = mix(iColor.rgb, meanColor.rgb, kMin);
    
    mediump vec3 sum = 0.25*iColor.rgb;
    sum += 0.125 *texture2D(inputImageTexture,textureShift_1.xy).rgb;
    sum += 0.125 *texture2D(inputImageTexture,textureShift_1.zw).rgb;
    sum += 0.125 *texture2D(inputImageTexture,textureShift_2.xy).rgb;
    sum += 0.125 *texture2D(inputImageTexture,textureShift_2.zw).rgb;
    sum += 0.0625*texture2D(inputImageTexture,textureShift_3.xy).rgb;
    sum += 0.0625*texture2D(inputImageTexture,textureShift_3.zw).rgb;
    sum += 0.0625*texture2D(inputImageTexture,textureShift_4.xy).rgb;
    sum += 0.0625*texture2D(inputImageTexture,textureShift_4.zw).rgb;
    
    vec3 hPass = iColor.rgb - sum;
    vec3 color = resultColor + sharpen * hPass * 2.0;
    vec3 colorEPM = color;
 
    // whiten
    color = clamp((colorEPM - vec3(levelBlack)) * levelRangeInv, 0.0, 1.0);
    lowp vec3 texel = vec3(texture2D(lookUpGray, vec2(color.r, 0.5)).r, texture2D(lookUpGray, vec2(color.g, 0.5)).g, texture2D(lookUpGray, vec2(color.b, 0.5)).b);
    texel = mix(color, texel, 0.5);
    texel = mix(colorEPM, texel, alpha);

    texel = clamp(texel, 0., 1.);
    float blueColor = texel.b * 15.0;
    vec2 quad1;
    quad1.y = floor(floor(blueColor) * 0.25);
    quad1.x = floor(blueColor) - (quad1.y * 4.0);
    vec2 quad2;
    quad2.y = floor(ceil(blueColor) * 0.25);
    quad2.x = ceil(blueColor) - (quad2.y * 4.0);
    vec2 texPos2 = texel.rg * 0.234375 + 0.0078125;
    vec2 texPos1 = quad1 * 0.25 + texPos2;
    texPos2 = quad2 * 0.25 + texPos2;
    vec3 newColor1Origin = texture2D(lookUpOrigin, texPos1).rgb;
    vec3 newColor2Origin = texture2D(lookUpOrigin, texPos2).rgb;
    vec3 colorOrigin = mix(newColor1Origin, newColor2Origin, fract(blueColor));
    texel = mix(colorOrigin, color, alpha);
    
    texel = clamp(texel, 0., 1.);
    blueColor = texel.b * 15.0;
    quad1.y = floor(floor(blueColor) * 0.25);
    quad1.x = floor(blueColor) - (quad1.y * 4.0);
    quad2.y = floor(ceil(blueColor) * 0.25);
    quad2.x = ceil(blueColor) - (quad2.y * 4.0);
    texPos2 = texel.rg * 0.234375 + 0.0078125;
    texPos1 = quad1 * 0.25 + texPos2;
    texPos2 = quad2 * 0.25 + texPos2;
    vec3 newColor1 = texture2D(lookUpSkin, texPos1).rgb;
    vec3 newColor2 = texture2D(lookUpSkin, texPos2).rgb;
    color = mix(newColor1.rgb, newColor2.rgb, fract(blueColor));
    color = clamp(color, 0., 1.);
  
    highp float blueColor_custom = color.b * 63.0;
    highp vec2 quad1_custom;
    quad1_custom.y = floor(floor(blueColor_custom) / 8.0);
    quad1_custom.x = floor(blueColor_custom) - (quad1_custom.y * 8.0);
    highp vec2 quad2_custom;
    quad2_custom.y = floor(ceil(blueColor_custom) /8.0);
    quad2_custom.x = ceil(blueColor_custom) - (quad2_custom.y * 8.0);
    highp vec2 texPos1_custom;
    texPos1_custom.x = (quad1_custom.x * 1.0/8.0) + 0.5/512.0 + ((1.0/8.0 - 1.0/512.0) * color.r);
    texPos1_custom.y = (quad1_custom.y * 1.0/8.0) + 0.5/512.0 + ((1.0/8.0 - 1.0/512.0) * color.g);
    highp vec2 texPos2_custom;
    texPos2_custom.x = (quad2_custom.x * 1.0/8.0) + 0.5/512.0 + ((1.0/8.0 - 1.0/512.0) * color.r);
    texPos2_custom.y = (quad2_custom.y * 1.0/8.0) + 0.5/512.0 + ((1.0/8.0 - 1.0/512.0) * color.g);
    newColor1 = texture2D(lookUpCustom, texPos1_custom).rgb;
    newColor2 = texture2D(lookUpCustom, texPos2_custom).rgb;
    lowp vec3 color_custom = mix(newColor1, newColor2, fract(blueColor_custom));
    color = mix(color, color_custom, whiten);

    gl_FragColor = vec4(color, 1.0);
}

 
);

@implementation GPUImageBaseBeautyFaceFilter
{
    
    GLint texelWidthUniform, texelHeightUniform;
    
    GLint sharpenUniform;
    GLint blurAlphaUniform;
    GLint whiteUniform;
    
    GLint lookUpGrayUniform;
    GLint lookUpOriginUniform;
    GLint lookUpSkinUniform;
    GLint lookUpCustomUniform;
    
    GLint grayTexId;
    GLint originTexId;
    GLint skinTexId;
    GLint customTexId;
    
    GPUImagePicture *grayImage;
    GPUImagePicture *originImage;
    GPUImagePicture *skinImage;
    GPUImagePicture *customImage;
}

- (instancetype)init {
    return [self initWithSharpen:1];
}

- (instancetype)initWithSharpen:(CGFloat)sharpen {
    self = [super initWithVertexShaderFromString:kGPUImageBaseBeautyFaceVertexShaderString fragmentShaderFromString:kGPUImageBaseBeautyFaceFragmentShaderString];
    
    if (self) {
        
        texelWidthUniform = [filterProgram uniformIndex:@"widthOffset"];
        texelHeightUniform = [filterProgram uniformIndex:@"heightOffset"];
        
        sharpenUniform = [filterProgram uniformIndex:@"sharpen"];
        blurAlphaUniform = [filterProgram uniformIndex:@"blurAlpha"];
        whiteUniform = [filterProgram uniformIndex:@"whiten"];
        
        lookUpGrayUniform = [filterProgram uniformIndex:@"lookUpGray"];
        lookUpOriginUniform = [filterProgram uniformIndex:@"lookUpOrigin"];
        lookUpSkinUniform = [filterProgram uniformIndex:@"lookUpSkin"];
        lookUpCustomUniform = [filterProgram uniformIndex:@"lookUpCustom"];
        
        grayImage = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"lookUpGray.png"]];
        originImage = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"lookUpOrigin.png"]];
        skinImage = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"lookUpSkin.png"]];
//        customImage = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"lookUpCustom.png"]];
        customImage = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"lookup2"]];
    }
    
    return self;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    
    grayTexId = grayImage.framebufferForOutput.texture;
    originTexId = originImage.framebufferForOutput.texture;
    skinTexId = skinImage.framebufferForOutput.texture;
    customTexId = customImage.framebufferForOutput.texture;
    
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        [secondInputFramebuffer unlock];
        [thirdInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    [self setupFilterForSize:self.sizeOfFBO];
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [secondInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform2, 3);
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [thirdInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform3, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, grayTexId);
    glUniform1i(lookUpGrayUniform, 5);
    
    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, originTexId);
    glUniform1i(lookUpOriginUniform, 6);

    glActiveTexture(GL_TEXTURE7);
    glBindTexture(GL_TEXTURE_2D, skinTexId);
    glUniform1i(lookUpSkinUniform, 7);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, customTexId);
    glUniform1i(lookUpCustomUniform, 0);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(filterSecondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation2]);
    glVertexAttribPointer(filterThirdTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation3]);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [firstInputFramebuffer unlock];
    [secondInputFramebuffer unlock];
    [thirdInputFramebuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
    
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    CGFloat texelWidth = 1.0 / filterFrameSize.width;
    CGFloat texelHeight = 1.0 / filterFrameSize.height;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext setActiveShaderProgram:self->filterProgram];
        if (GPUImageRotationSwapsWidthAndHeight(self->inputRotation))
        {
            glUniform1f(self->texelWidthUniform, texelHeight);
            glUniform1f(self->texelHeightUniform, texelWidth);
        }
        else
        {
            glUniform1f(self->texelWidthUniform, texelWidth);
            glUniform1f(self->texelHeightUniform, texelHeight);
        }
    });

}

- (void)setSharpen:(CGFloat)sharpen {
    _sharpen = sharpen;
    [self setFloat:sharpen forUniform:sharpenUniform program:filterProgram];
}

- (void)setBlurAlpha:(CGFloat)blurAlpha {
    _blurAlpha = blurAlpha;
    [self setFloat:blurAlpha forUniform:blurAlphaUniform program:filterProgram];
}

- (void)setWhite:(CGFloat)white {
    _white = white;
    [self setFloat:white forUniform:whiteUniform program:filterProgram];
}
@end
