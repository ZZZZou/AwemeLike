//
//  GPUImageLUTFilter.m
//  AwemeLike
//
//  Created by wang on 2019/11/9.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImageLUTFilter.h"

@implementation GPUImageLUTFilter

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
