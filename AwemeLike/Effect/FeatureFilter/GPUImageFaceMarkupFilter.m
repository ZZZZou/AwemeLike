//
//  GPUImageFaceMarkupFilter.h
//  AwemeLike
//
//  Created by wang on 2019/9/24.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImagePicture.h"
#import "FaceDetector.h"
#import "GPUImageFaceMarkupFilter.h"

NSString *const GPUImageFaceMarkupFilterVertexShaderString = SHADER_STRING
(
 attribute vec3 position;
 attribute vec2 inputTextureCoordinate;
 varying vec2   textureCoordinate;
 varying vec2   textureCoordinate2;
 
 void main(void) {
     gl_Position = vec4(position, 1.);
     textureCoordinate = inputTextureCoordinate;
     textureCoordinate2 = position.xy * 0.5 + 0.5;
 }
 );

NSString *const GPUImageFaceMarkupFilterFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform float intensity;
 uniform int blendMode;
 
 float blendHardLight(float base, float blend) {
     return blend<0.5?(2.0*base*blend):(1.0-2.0*(1.0-base)*(1.0-blend));
 }
 
 vec3 blendHardLight(vec3 base, vec3 blend) {
     return vec3(blendHardLight(base.r,blend.r),blendHardLight(base.g,blend.g),blendHardLight(base.b,blend.b));
 }
 
 float blendSoftLight(float base, float blend) {
     return (blend<0.5)?(base+(2.0*blend-1.0)*(base-base*base)):(base+(2.0*blend-1.0)*(sqrt(base)-base));
 }
 vec3 blendSoftLight(vec3 base, vec3 blend) {
     return vec3(blendSoftLight(base.r,blend.r),blendSoftLight(base.g,blend.g),blendSoftLight(base.b,blend.b));
 }
 
 vec3 blendMultiply(vec3 base, vec3 blend) {
     return base*blend;
 }
 
 float blendOverlay(float base, float blend) {
     return base<0.5?(2.0*base*blend):(1.0-2.0*(1.0-base)*(1.0-blend));
 }
 vec3 blendOverlay(vec3 base, vec3 blend) {
     return vec3(blendOverlay(base.r,blend.r),blendOverlay(base.g,blend.g),blendOverlay(base.b,blend.b));
 }
 
 vec3 blendFunc(vec3 base, vec3 blend, int blendMode) {
     if (blendMode == 0) {
         return blend;
     } else if (blendMode == 15) {
         return blendMultiply(base, blend);
     } else if (blendMode == 17) {
         return blendOverlay(base, blend);
     } else if (blendMode == 22) {
         return blendHardLight(base, blend);
     }
     return blend;
 }
 
 void main()
{
    vec4 fgColor = texture2D(inputImageTexture2, textureCoordinate);
    fgColor = fgColor * intensity;
    vec4 bgColor = texture2D(inputImageTexture, textureCoordinate2);
    if (fgColor.a == 0.0) {
        gl_FragColor = bgColor;
        return;
    }
    
    
    vec3 color = blendFunc(bgColor.rgb, clamp(fgColor.rgb * (1.0 / fgColor.a), 0.0, 1.0), blendMode);
//    color = color * intensity;
    gl_FragColor = vec4(bgColor.rgb * (1.0 - fgColor.a) + color.rgb * fgColor.a, 1.0);
}
 
 );

@implementation GPUImageFaceMarkupFilter
{
    GPUImageFramebuffer *secondInputFramebuffer;
    GLint filterInputTextureUniform2;
    
    GLProgram *secondFilterProgram;
    GLint secondFilterPositionAttribute, secondFilterTextureCoordinateAttribute;
    GLint secondFilterInputTextureUniform;
}

- (instancetype)init {
    self = [super initWithVertexShaderFromString:GPUImageFaceMarkupFilterVertexShaderString fragmentShaderFromString:GPUImageFaceMarkupFilterFragmentShaderString];
    if (self) {
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext useImageProcessingContext];
            
            self->filterInputTextureUniform2 = [self->filterProgram uniformIndex:@"inputImageTexture2"];
            
            self->secondFilterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
            
            if (!self->secondFilterProgram.initialized)
            {
                [self initializeSecondaryAttributes];
                
                if (![self->secondFilterProgram link])
                {
                    NSString *progLog = [self->secondFilterProgram programLog];
                    NSLog(@"Program link log: %@", progLog);
                    NSString *fragLog = [self->secondFilterProgram fragmentShaderLog];
                    NSLog(@"Fragment shader compile log: %@", fragLog);
                    NSString *vertLog = [self->secondFilterProgram vertexShaderLog];
                    NSLog(@"Vertex shader compile log: %@", vertLog);
                    self->secondFilterProgram = nil;
                    NSAssert(NO, @"Filter shader link failed");
                }
            }
            
            self->secondFilterPositionAttribute = [self->secondFilterProgram attributeIndex:@"position"];
            self->secondFilterTextureCoordinateAttribute = [self->secondFilterProgram attributeIndex:@"inputTextureCoordinate"];
            self->secondFilterInputTextureUniform = [self->secondFilterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
            
            [GPUImageContext setActiveShaderProgram:self->secondFilterProgram];
            glEnableVertexAttribArray(self->secondFilterPositionAttribute);
            glEnableVertexAttribArray(self->secondFilterTextureCoordinateAttribute);
            
        });
    }
   
    return self;
}

- (void)initializeSecondaryAttributes;
{
    [secondFilterProgram addAttribute:@"position"];
    [secondFilterProgram addAttribute:@"inputTextureCoordinate"];
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    
   
    BOOL hasFace = self.markupModel.hasFace;
    secondInputFramebuffer = [self.markupModel secondFramebuffer];
    
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        [secondInputFramebuffer unlock];
        return;
    }
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if (hasFace) {
        GLfloat *firstVertices = self.markupModel.vertexCoordinates;
        GLfloat *firstTextureCoordinates = self.markupModel.textureCoordinates;
        GLuint *firstIndexs = self.markupModel.elementIndexs;
        GLsizei elementCount = self.markupModel.elementCount;
        [GPUImageContext setActiveShaderProgram:filterProgram];
        [self setUniformsForProgramAtIndex:0];
        
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
        glUniform1i(filterInputTextureUniform, 2);
        
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, [secondInputFramebuffer texture]);
        glUniform1i(filterInputTextureUniform2, 3);
        
        glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, firstVertices);
        glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, firstTextureCoordinates);
        
        glDrawElements(GL_TRIANGLES, elementCount, GL_UNSIGNED_INT, firstIndexs);
    }
    
    
    //second
    [GPUImageContext setActiveShaderProgram:secondFilterProgram];
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE_MINUS_DST_ALPHA, GL_ONE);
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(secondFilterInputTextureUniform, 2);
    glVertexAttribPointer(secondFilterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(secondFilterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisable(GL_BLEND);
    
    [firstInputFramebuffer unlock];
    [secondInputFramebuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
    
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    
    [self.markupModel setUniformAtProgram:filterProgram frameTime:frameTime];
    
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation]];
}
@end

/*
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
 
 glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
 glClear(GL_COLOR_BUFFER_BIT);
 
 glActiveTexture(GL_TEXTURE2);
 glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
 glUniform1i(filterInputTextureUniform, 2);
 
 glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
 glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
 
 glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
 
 
 FaceModel *faceInfo = [FaceDetector shareInstance].oneFace;
 if (faceInfo) {
 glEnable(GL_BLEND);
 glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
 glActiveTexture(GL_TEXTURE2);
 glBindTexture(GL_TEXTURE_2D, mask.framebufferForOutput.texture);
 glUniform1i(filterInputTextureUniform, 2);
 
 NSArray *maskTextureCoordinates = [maskTextureCoordinatesString componentsSeparatedByString:@" "];
 
 const GLsizei pointCount = (GLsizei)faceInfo.landmarks.count;
 GLfloat faceVertices[pointCount * 2];
 GLfloat faceTextureCoordinates[pointCount * 2];
 
 for (int i = 0; i < pointCount; i ++) {
 CGPoint pointer = [faceInfo.landmarks[i] CGPointValue];
 GLfloat x = pointer.x * 2 - 1;
 GLfloat y = pointer.y * 2 - 1;
 faceVertices[i*2+0] = x;
 faceVertices[i*2+1] = y;
 
 faceTextureCoordinates[i*2+0] = ([maskTextureCoordinates[i*2+0] floatValue] * 1280 - 0) / 1280;
 faceTextureCoordinates[i*2+1] = ([maskTextureCoordinates[i*2+1] floatValue] * 1280 - 0) / 1280;
 }
 glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, faceVertices);
 glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, faceTextureCoordinates);
 
 //        GLfloat pupilVertices[4 * 2];
 //        CGPoint center = [faceInfo.landmarks[74] CGPointValue];
 //        CGPoint point72 = [faceInfo.landmarks[56] CGPointValue];
 //        CGPoint point73 = [faceInfo.landmarks[57] CGPointValue];
 //        CGFloat hLength = sqrt(pow((point72.x-point73.x), 2) + pow((point72.y-point73.y), 2)) / 5 * 3;
 //        CGFloat wLength = hLength / (inputTextureSize.width / inputTextureSize.height);
 //        pupilVertices[0] = (center.x - wLength/2) * 2 - 1;
 //        pupilVertices[1] = (center.y - hLength/2) * 2 - 1;
 //        pupilVertices[2] = (center.x + wLength/2) * 2 - 1;
 //        pupilVertices[3] = (center.y - hLength/2) * 2 - 1;
 //        pupilVertices[4] = (center.x - wLength/2) * 2 - 1;
 //        pupilVertices[5] = (center.y + hLength/2) * 2 - 1;
 //        pupilVertices[6] = (center.x + wLength/2) * 2 - 1;
 //        pupilVertices[7] = (center.y + hLength/2) * 2 - 1;
 //        glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, pupilVertices);
 //        glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
 
 glDrawElements(GL_TRIANGLES, (GLsizei)sizeof(faceIndexs)/sizeof(GLuint), GL_UNSIGNED_INT, faceIndexs);
 
 //        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
 
 glDisable(GL_BLEND);
 }
 
 [firstInputFramebuffer unlock];
 
 if (usingNextFrameForImageCapture)
 {
 dispatch_semaphore_signal(imageCaptureSemaphore);
 }
 }
 */
