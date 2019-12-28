//
//  GPUImageMagnificationFilter.m
//  AwemeLike
//
//  Created by wang on 2019/9/18.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImageRotateFilter.h"

@implementation GPUImageRotateFilter

- (instancetype)init {
    // Do a luminance pass first to reduce the calculations performed at each fragment in the edge detection phase
    
    if (!(self = [super initWithFragmentShaderFromString:kGPUImagePassthroughFragmentShaderString]))
    {
        return nil;
    }
    return self;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    inputRotation = kGPUImageNoRotation;
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    if (self.rotateDegree == 90 || self.rotateDegree == 180) {
        inputTextureSize = CGSizeMake(inputTextureSize.height, inputTextureSize.width);
    }
    
    [self renderToTextureWithVertices:imageVertices textureCoordinates:[self.class textureCoordinatesForRotationDegree:self.rotateDegree]];
    
    [self informTargetsAboutNewFrameAtTime:frameTime];
}

+ (const GLfloat *)textureCoordinatesForRotationDegree:(CGFloat)degree
{
    static const GLfloat noRotate[] = {
        0.0, 0.0,
        1.0, 0.0,
        0.0, 1.0,
        1.0, 1.0,
    };
    static const GLfloat rotate90[] = {
        0.0, 1.0,
        0.0, 0.0,
        1.0, 1.0,
        1.0, 0.0,
    };
    static const GLfloat rotate180[] = {
        1.0, 1.0,
        0.0, 1.0,
        1.0, 0.0,
        0.0, 0.0,
    };
    static const GLfloat rotate270[] = {
        1.0, 0.0,
        1.0, 1.0,
        0.0, 0.0,
        0.0, 1.0,
    };
    
    if (degree == 90) {
        return rotate90;
    } else if (degree == 180) {
        return rotate180;
    } else if (degree == 270) {
        return rotate270;
    }
    return noRotate;
}
@end
