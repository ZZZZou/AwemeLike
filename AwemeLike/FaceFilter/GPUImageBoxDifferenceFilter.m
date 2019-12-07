//
//  GPUImageBoxDifferenceFilter.m
//  AwemeLike
//
//  Created by wang on 2019/10/2.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImageBoxDifferenceFilter.h"

NSString *const kGPUImageBoxDifferenceVertexShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform highp float delta;
 
 void main()
{
    lowp vec3 iColor = texture2D(inputImageTexture, textureCoordinate).rgb;
    lowp vec3 meanColor = texture2D(inputImageTexture2, textureCoordinate2).rgb;
    highp vec3 diffColor = (iColor - meanColor) * delta;
    diffColor = min(diffColor * diffColor, 1.0);
    gl_FragColor = vec4(diffColor, 1.0);
}
);

@implementation GPUImageBoxDifferenceFilter
{
    GLint deltaUniform;
}

- (instancetype)init {
    self = [super initWithFragmentShaderFromString:kGPUImageBoxDifferenceVertexShaderString];
    
    if (self) {
        deltaUniform = [filterProgram uniformIndex:@"delta"];
        self.delta = 7.07;
    }
    return self;
}

- (void)setDelta:(CGFloat)delta {
    _delta = delta;
    
    [self setFloat:delta forUniform:deltaUniform program:filterProgram];
}

@end
