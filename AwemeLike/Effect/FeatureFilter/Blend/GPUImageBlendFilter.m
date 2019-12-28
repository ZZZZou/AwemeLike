//
//  GPUImageBlendFilter.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/5.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "GPUImageBlendFilter.h"

NSString *const kGPUImageBlendFilterVertexShaderString = SHADER_STRING
(
 attribute vec3 position;
 attribute vec2 inputTextureCoordinate;
 varying vec2   textureCoordinate;
 varying vec2   textureCoordinate2;
 
 uniform mat4 matrix;
 
 void main(void) {
     vec4 p = matrix * vec4(position, 1.);
     textureCoordinate = inputTextureCoordinate;
     textureCoordinate2 = p.xy * 0.5 + 0.5;
     gl_Position = p;
 }
 );

@implementation GPUImageBlendFilter

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString {
    if (!(self = [super initWithVertexShaderFromString:kGPUImageBlendFilterVertexShaderString  fragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
         self->filterInputTextureUniform2 = [self->filterProgram uniformIndex:@"inputImageTexture2"];
        self->matrixUniform = [self->filterProgram uniformIndex:@"matrix"];
        
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
    return self;
}

- (void)initializeSecondaryAttributes;
{
    [secondFilterProgram addAttribute:@"position"];
    [secondFilterProgram addAttribute:@"inputTextureCoordinate"];
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    
    GLfloat *firstVertices = self.stickerModel.vertexCoordinates;
    GPUMatrix4x4 matrix = self.stickerModel.vertexMatrix;
    BOOL showSticker = !self.stickerModel.faceDetect || (self.stickerModel.faceDetect && self.stickerModel.hasFace);
    
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
    
    if (showSticker) {
        [GPUImageContext setActiveShaderProgram:filterProgram];
        [self setUniformsForProgramAtIndex:0];
        
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
        glUniform1i(filterInputTextureUniform, 2);
        
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, [secondInputFramebuffer texture]);
        glUniform1i(filterInputTextureUniform2, 3);
        
        glUniformMatrix4fv(matrixUniform, 1, GL_FALSE, (GLfloat *)&matrix);
        
        glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, firstVertices);
        glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
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
   
    [self.stickerModel setUniformAtProgram:filterProgram frameTime:frameTime];
    secondInputFramebuffer = [self.stickerModel stickerFramebufferAtFrameTime:frameTime];
    
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation]];
}

@end
