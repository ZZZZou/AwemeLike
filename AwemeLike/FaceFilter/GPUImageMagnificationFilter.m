//
//  GPUImageMagnificationFilter.m
//  AwemeLike
//
//  Created by wang on 2019/9/18.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImageMagnificationFilter.h"

NSString *const kGPUImageMagnificationFragmentString = SHADER_STRING
(
 
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform vec3 centerCoordinate;
 uniform float radius;
 uniform float aspectRatio;
 void main()
 {
     vec2 one = vec2(textureCoordinate.x, textureCoordinate.y * aspectRatio + 0.5 - 0.5 * aspectRatio);
     vec2 two = vec2(centerCoordinate.x, centerCoordinate.y * aspectRatio + 0.5 - 0.5 * aspectRatio);
     
//     vec2 one = vec2(textureCoordinate.x, textureCoordinate.y / aspectRatio);
//     vec2 two = vec2(centerCoordinate.x, centerCoordinate.y / aspectRatio);
     
     float distance = distance(one, two);
     vec2 finalCoordinate = textureCoordinate;
     if (distance < radius) {
         finalCoordinate = centerCoordinate.xy + (textureCoordinate - centerCoordinate.xy)/2.0;
     }
     gl_FragColor = texture2D(inputImageTexture, finalCoordinate);
 }
 
);
@implementation GPUImageMagnificationFilter
{
    GLint centerCoordinate;
    GLint radius;
    GLint aspectRatioUniform;
}

- (instancetype)init {
    // Do a luminance pass first to reduce the calculations performed at each fragment in the edge detection phase
    
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageMagnificationFragmentString]))
    {
        return nil;
    }
    aspectRatioUniform = [filterProgram uniformIndex:@"aspectRatio"];
    centerCoordinate = [filterProgram uniformIndex:@"centerCoordinate"];
    radius = [filterProgram uniformIndex:@"radius"];
    
   
   
    return self;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    [super setInputSize:newSize atIndex:textureIndex];
    
    CGFloat aspect = firstInputFramebuffer.bytesPerRow / 4 / inputTextureSize.height;
    aspect = 1/aspect;
    
    GPUVector3 center = {0.5, 0.5, 0};
    [self setVec3:center forUniform:centerCoordinate program:filterProgram];
    
    [self setFloat:0.4 forUniform:radius program:filterProgram];
    
    [self setFloat:aspect forUniform:aspectRatioUniform program:filterProgram];
}

@end
