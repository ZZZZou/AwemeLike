//
//  GPUImageGeneralFilter.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/7.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "GPUImageGeneralFilter.h"

@implementation GPUImageGeneralFilter

- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString {
    self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString];
    if (self) {
        
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext useImageProcessingContext];
            self->filterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:vertexShaderString fragmentShaderString:fragmentShaderString];
            
//            if (!self->filterProgram.initialized)
//            {
                [self->filterProgram addAttribute:@"attPosition"];
                [self->filterProgram addAttribute:@"attUV"];
                
                if (![self->filterProgram link])
                {
                    NSString *progLog = [self->filterProgram programLog];
                    NSLog(@"Program link log: %@", progLog);
                    NSString *fragLog = [self->filterProgram fragmentShaderLog];
                    NSLog(@"Fragment shader compile log: %@", fragLog);
                    NSString *vertLog = [self->filterProgram vertexShaderLog];
                    NSLog(@"Vertex shader compile log: %@", vertLog);
                    self->filterProgram = nil;
                    NSAssert(NO, @"Filter shader link failed");
                }
//            }
            
            self->filterPositionAttribute = [self->filterProgram attributeIndex:@"attPosition"];
            self->filterTextureCoordinateAttribute = [self->filterProgram attributeIndex:@"attUV"];
            self->filterInputTextureUniform = [self->filterProgram uniformIndex:@"inputImageTexture"];

            [GPUImageContext setActiveShaderProgram:self->filterProgram];

            glEnableVertexAttribArray(self->filterPositionAttribute);
            glEnableVertexAttribArray(self->filterTextureCoordinateAttribute);
        });
    }
    return self;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    
    GLint vertexStep = (GLint)self.generalModel.vertexStep;
    GLint uvStep = (GLint)self.generalModel.uvStep;
    GLfloat *vertexData = [self.generalModel vertexCoordinates];
    GLfloat *uvData = [self.generalModel textureCoordinates];
    GLsizei count = (GLsizei)self.generalModel.drawCount;
    
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
    
    
    glVertexAttribPointer(filterPositionAttribute, vertexStep, GL_FLOAT, 0, 0, vertexData);
    glVertexAttribPointer(filterTextureCoordinateAttribute, uvStep, GL_FLOAT, 0, 0, uvData);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, count);
    
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
    
}

- (GLfloat)getUniformFloat:(GLuint)program name:(char *)name {
    GLint location = glGetUniformLocation(program, name);
    GLfloat value;
    glGetUniformfv(program, location, &value);
    return value;
}

- (GLfloat)getUniformInt:(GLuint)program name:(char *)name {
    GLint location = glGetUniformLocation(program, name);
    GLint value;
    glGetUniformiv(program, location, &value);
    return value;
}


- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation]];
}

@end
