//
//  HPTwoLookupFilter.m
//  AwemeLike
//
//  Created by wang on 2019/11/17.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImagePicture.h"
#import "HPTwoLookupFilter.h"

NSString *const kGPUImageTwoLookupFragmentShaderString = SHADER_STRING
(
 precision highp float;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 varying lowp vec2 textureCoordinate;
 uniform float leftIntensity;
 uniform float rightIntensity;
 uniform float mposition;
 void main()
{
    highp vec4 textureColor1 = texture2D(inputImageTexture, textureCoordinate);
    textureColor1 = clamp(textureColor1, 0.0, 1.0);
    
    highp float blueColor = textureColor1.b * 63.0;
    
    highp vec2 quad1;
    quad1.y = floor(floor(blueColor) / 8.0);
    quad1.x = floor(blueColor) - (quad1.y * 8.0);
    highp vec2 quad2;
    quad2.y = floor(ceil(blueColor) / 8.0);
    quad2.x = ceil(blueColor) - (quad2.y * 8.0);
    
    highp vec2 texPos1;
    texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor1.r);
    texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor1.g);
    highp vec2 texPos2;
    texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor1.r);
    texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor1.g);
    
    if(textureCoordinate.x<mposition){
        gl_FragColor = vec4(1.0);
        lowp vec4 newColor2_1 = texture2D(inputImageTexture2, texPos1);
        lowp vec4 newColor2_2 = texture2D(inputImageTexture2, texPos2);
        lowp vec4 newColor22 = mix(newColor2_1, newColor2_2, fract(blueColor));
        gl_FragColor = mix(textureColor1, vec4(newColor22.rgb, textureColor1.w), leftIntensity);
    }else{
        lowp vec4 newColor3_1 = texture2D(inputImageTexture3, texPos1);
        lowp vec4 newColor3_2 = texture2D(inputImageTexture3, texPos2);
        lowp vec4 newColor33 = mix(newColor3_1, newColor3_2, fract(blueColor));
        gl_FragColor = mix(textureColor1, vec4(newColor33.rgb, textureColor1.w), rightIntensity);
    }
    
    
}

);



@implementation HPTwoLookupFilter

{
    GPUImagePicture *lut1;
    GPUImagePicture *lut2;
    CGFloat leftIntensity;
    CGFloat rightIntensity;
    
    CGFloat split;
}

- (instancetype)initWithLeftLUTPath:(NSString *)leftLUTPath leftIntensity:(CGFloat)leftIntensity rightLUTPath:(NSString *)rightLUTPath rightIntensity:(CGFloat)rightIntensity split:(CGFloat)split {
    
    self = [super initWithFragmentShaderFromString:kGPUImageTwoLookupFragmentShaderString];
    if (self) {
        self->lut1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:leftLUTPath]];
        self->lut2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:rightLUTPath]];
        self->leftIntensity = leftIntensity;
        self->rightIntensity = rightIntensity;
        
        [self updatesplit:split];
    }
    
    
    return self;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    
    
    GLuint leftIntensityUniform = [filterProgram uniformIndex:@"leftIntensity"];
    glUniform1f(leftIntensityUniform, leftIntensity);
    
    GLuint rightIntensityUniform = [filterProgram uniformIndex:@"rightIntensity"];
    glUniform1f(rightIntensityUniform, rightIntensity);
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    
    glUniform1i(filterInputTextureUniform, 2);
    
    GLuint lut1Uniform = [filterProgram uniformIndex:@"inputImageTexture2"];
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, lut1.framebufferForOutput.texture);
    glUniform1i(lut1Uniform, 4);
    
    
    GLuint lut2Uniform = [filterProgram uniformIndex:@"inputImageTexture3"];
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, lut2.framebufferForOutput.texture);
    glUniform1i(lut2Uniform, 5);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    
    [filterProgram use];
    
    
    
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
}

- (void)updatesplit:(CGFloat)split {
    self->split = split;
    
    [self setFloat:split forUniformName:@"mposition"];
}

@end
