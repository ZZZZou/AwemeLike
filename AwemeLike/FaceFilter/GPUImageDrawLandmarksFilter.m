//
//  GPUImageDrawLandmarksFilter.m
//  AwemeLike
//
//  Created by wang on 2019/9/24.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "FaceDetector.h"
#import "GPUImageDrawLandmarksFilter.h"

NSString *const kGPUImageDrawLandmarkVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 uniform float sizeScale;

 void main(void)
 {
     gl_Position = position;
     gl_PointSize = sizeScale;
 }
);

NSString *const kGPUImageDrawLandmarkFragmentShaderString = SHADER_STRING
(
 void main()
 {
    gl_FragColor = vec4(0.2, 0.709803922, 0.898039216, 1.0);
 }
);


@implementation GPUImageDrawLandmarksFilter
{
    GLint sizeScaleUniform;
}

- (instancetype)init {
    self = [super initWithVertexShaderFromString:kGPUImageDrawLandmarkVertexShaderString fragmentShaderFromString:kGPUImageDrawLandmarkFragmentShaderString];
    if (self) {
        
        sizeScaleUniform = [filterProgram uniformIndex:@"sizeScale"];
    }
    return self;
}

- (GPUImageFramebuffer *)framebufferForOutput {
    return firstInputFramebuffer;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    [firstInputFramebuffer activateFramebuffer];
    [GPUImageContext setActiveShaderProgram:filterProgram];
    if (usingNextFrameForImageCapture)
    {
        [firstInputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];

    
    for (FaceModel *faceInfo in [FaceDetector shareInstance].faceModels) {
        
        const GLsizei pointCount = (GLsizei)faceInfo.landmarks.count;
        GLfloat tempPoint[pointCount * 3];
        GLubyte indices[pointCount];
        
        for (int i = 0; i < faceInfo.landmarks.count; i ++) {
            CGPoint pointer = [faceInfo.landmarks[i] CGPointValue];
            GLfloat x = pointer.x * 2 - 1;
            GLfloat y = pointer.y * 2 - 1;
            
            tempPoint[i*3+0] = x;
            tempPoint[i*3+1] = y;
            tempPoint[i*3+2] = 0.0f;
            indices[i] = i;
        }
        glVertexAttribPointer(filterPositionAttribute, 3, GL_FLOAT, GL_TRUE, 0, tempPoint);
        glEnableVertexAttribArray(filterPositionAttribute);
        
        const GLfloat lineWidth = faceInfo.bounds.size.width / inputTextureSize.width * 20;
        glUniform1f(sizeScaleUniform, lineWidth);
        
        glDrawElements(GL_POINTS, (GLsizei)sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
    }
   
    [self informTargetsAboutNewFrameAtTime:frameTime];
}
@end
