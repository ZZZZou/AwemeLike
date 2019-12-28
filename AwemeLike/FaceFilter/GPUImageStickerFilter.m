//
//  GPUImageStickerFilter.m
//  AwemeLike
//
//  Created by w22543 on 2019/9/18.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "FaceDetector.h"
#import <GLKit/GLKit.h>
#import "GPUImageStickerFilter.h"

NSString *const kGPUImageStickerFirstVertexShaderString = SHADER_STRING
(
 precision highp float;
 uniform mat4 uMVPMatrix;        // 变换矩阵
 attribute vec4 position;       // 图像顶点坐标
 attribute vec4 inputTextureCoordinate;   // 图像纹理坐标
 
 varying vec2 textureCoordinate; // 图像纹理坐标
 
 void main() {
     gl_Position =  uMVPMatrix * position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

NSString *const kGPUImageStickerSecondFragmentString = SHADER_STRING
(
 precision highp float;
 // 前景贴纸绘制
 varying vec2 textureCoordinate;     // 输入图像纹理坐标
 uniform sampler2D inputImageTexture;     // 输入图像纹理
 
 uniform sampler2D inputImageTexture2;   // 贴纸纹理
 uniform int enableSticker;          // 是否绘制贴纸
 
 // 混合
 vec4 blendColor(vec4 frameColor, vec4 sourceColor) {
     
     vec4 outputColor;
     outputColor.r = frameColor.r * frameColor.a + sourceColor.r * sourceColor.a * (1.0 - frameColor.a);
     outputColor.g = frameColor.g * frameColor.a + sourceColor.g * sourceColor.a * (1.0 - frameColor.a);
     outputColor.b = frameColor.b * frameColor.a + sourceColor.b * sourceColor.a * (1.0 - frameColor.a);
     outputColor.a = frameColor.a + sourceColor.a * (1.0 - frameColor.a);
     return outputColor;
 }
 
 void main() {
     lowp vec4 sourceColor = texture2D(inputImageTexture, textureCoordinate);
     if (enableSticker == 0) {
         gl_FragColor = sourceColor;
     } else {
         lowp vec4 frameColor = texture2D(inputImageTexture2, textureCoordinate);
         gl_FragColor = blendColor(frameColor, sourceColor);
     }
 }
 );

@implementation GPUImageStickerFilter
{
    GLint enableSticker;
    GLint stickerTexMatrix;
    
    GLuint stickerTexId;
    CGFloat stickerTexWidth;
    CGFloat stickerTexHeight;
}

- (instancetype)init {
    
    if (!(self = [super initWithFirstStageVertexShaderFromString:kGPUImageStickerFirstVertexShaderString firstStageFragmentShaderFromString:kGPUImagePassthroughFragmentShaderString secondStageVertexShaderFromString:kGPUImageVertexShaderString secondStageFragmentShaderFromString:kGPUImageStickerSecondFragmentString]))
    {
        return nil;
    }
    stickerTexMatrix = [filterProgram uniformIndex:@"uMVPMatrix"];
    enableSticker = [secondFilterProgram uniformIndex:@"enableSticker"];
    
    [self createStickerTexture];
    return self;
}

- (void)createStickerTexture {
    
    glGenTextures(1, &stickerTexId);
    glBindTexture(GL_TEXTURE_2D, stickerTexId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    CGImageRef cgimg = [UIImage imageNamed:@"ear_000"].CGImage;
    CGFloat width =CGImageGetWidth(cgimg);
    CGFloat height = CGImageGetHeight(cgimg);
    CFDataRef cfdata = CGDataProviderCopyData(CGImageGetDataProvider(cgimg));
    GLubyte *imageData = (GLubyte *)CFDataGetBytePtr(cfdata);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    stickerTexWidth = width;
    stickerTexHeight = height;
    
}

- (void)setupWithLandmarks {
    FaceModel *oneFace = [FaceDetector shareInstance].oneFace;
    NSArray *landmarks = oneFace.landmarks;
    
    if (!landmarks.count) {
        [self setInteger:0 forUniform:enableSticker program:secondFilterProgram];
        
        GLKMatrix4 mvp = GLKMatrix4Identity;
        [self setMatrix4f:[self matrixFromGLKMatrix4:mvp] forUniform:stickerTexMatrix program:filterProgram];
        return;
    }
    //在这种情况下，face++识别的图片和实际图片中的脸部水平方向镜像
    //    BOOL isFrontMirr = [FaceDetector shareInstance].sampleBufferOrientation == FaceDetectorSampleBufferOrientationCameraFrontAndHorizontallyMirror;
    
    //以像素-宽为基准
    //贴纸长宽
    CGFloat stickTexAspect = stickerTexWidth / stickerTexHeight;
    CGFloat aspect = inputTextureSize.width / inputTextureSize.height;
    
    //    CGFloat ndcStickerWidth = GLKVector2Distance(GLKVector2Make([landmarks[4] CGPointValue].x, [landmarks[4] CGPointValue].y / aspect), GLKVector2Make([landmarks[28] CGPointValue].x, [landmarks[28] CGPointValue].y / aspect)) * projectionScale;
    //    CGFloat ndcStickerHeight = ndcStickerWidth / stickTexAspect;
    //
    //    //贴纸中心点
    //    GLKVector2 stickerCenter = GLKVector2Make([landmarks[16] CGPointValue].x, [landmarks[16] CGPointValue].y);
    //    stickerCenter = GLKVector2Make((stickerCenter.x * 2 - 1) * projectionScale, ((stickerCenter.y) * 2 - 1) / aspect * projectionScale);
    //    GLKVector2 offset = GLKVector2Make(0, -ndcStickerWidth/aspect*3/2);
    
    GLKVector2 point4 = GLKVector2Make([landmarks[4] CGPointValue].x, [landmarks[4] CGPointValue].y / aspect);
    GLKVector2 point28 = GLKVector2Make([landmarks[28] CGPointValue].x, [landmarks[28] CGPointValue].y / aspect);
    CGFloat ndcStickerWidth = GLKVector2Distance(point4, point28);
    CGFloat ndcStickerHeight = ndcStickerWidth / stickTexAspect;
    
    //贴纸中心点
    GLKVector2 rotationCenter = GLKVector2Make([landmarks[16] CGPointValue].x * 2 - 1, [landmarks[16] CGPointValue].y * 2 -1);
    GLKVector2 point16 = GLKVector2Make([landmarks[16] CGPointValue].x * 2 - 1, [landmarks[16] CGPointValue].y * 2 -1);
    GLKVector2 stickerCenter = GLKVector2Make(point16.x , point16.y/aspect - ndcStickerWidth/aspect*1.7);
    //     rotationCenter = GLKVector2Make([landmarks[45] CGPointValue].x * 2 - 1, [landmarks[45] CGPointValue].y * 2 -1);
    //欧拉角
    CGFloat pitchAngle = oneFace.pitchAngle;
    CGFloat yawAngle = oneFace.yawAngle;
    CGFloat rollAngle = oneFace.rollAngle;
    if (fabs(yawAngle) > M_PI/180.0*50.0) {
        yawAngle = (yawAngle / fabs(yawAngle)) * M_PI/180.0*50.0;
    }
    if (fabs(pitchAngle) > M_PI/180.0*30.0) {
        pitchAngle = (pitchAngle / fabs(pitchAngle)) * M_PI/180.0*30.0;
    }
    
    CGFloat projectionScale = 2;
    GLKMatrix4 projection = GLKMatrix4MakeFrustum(-1/projectionScale, 1/projectionScale, -1/aspect/projectionScale, 1/aspect/projectionScale, 5 , 100);
    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(0, 0, 10, 0, 0, -1, 0, 1, 0);
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    
    //围绕rotationCenter旋转
    modelMatrix = GLKMatrix4Translate(modelMatrix, rotationCenter.x, rotationCenter.y, 0);
    modelMatrix = GLKMatrix4RotateZ(modelMatrix, rollAngle);
    modelMatrix = GLKMatrix4RotateY(modelMatrix, yawAngle);
    modelMatrix = GLKMatrix4RotateX(modelMatrix, pitchAngle);
    modelMatrix = GLKMatrix4Translate(modelMatrix, -rotationCenter.x, -rotationCenter.y, 0);
    
    //移动贴图到目标位置
    modelMatrix = GLKMatrix4Translate(modelMatrix, stickerCenter.x, stickerCenter.y, 0);
    modelMatrix = GLKMatrix4Scale(modelMatrix, ndcStickerWidth, ndcStickerHeight, 1);
    
    GLKMatrix4 modelViewMatrix =GLKMatrix4Multiply(viewMatrix, modelMatrix);
    GLKMatrix4 mvp = GLKMatrix4Multiply(projection, modelViewMatrix);
    
    [self setMatrix4f:[self matrixFromGLKMatrix4:mvp] forUniform:stickerTexMatrix program:filterProgram];
    [self setInteger:1 forUniform:enableSticker program:secondFilterProgram];
    
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    [self setupWithLandmarks];
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    
    [self setUniformsForProgramAtIndex:0];
    
    glEnable(GL_BLEND);
    glBlendEquation(GL_FUNC_ADD);
    glBlendFuncSeparate(GL_ONE, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE);
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, stickerTexId);
    glUniform1i(filterInputTextureUniform, 2);
    
    glVertexAttribPointer(filterPositionAttribute, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GL_FLOAT), vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //     Run the second stage of the two-pass filter
    secondOutputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [secondOutputFramebuffer activateFramebuffer];
    [GPUImageContext setActiveShaderProgram:secondFilterProgram];
    if (usingNextFrameForImageCapture)
    {
        [secondOutputFramebuffer lock];
    }
    [self setUniformsForProgramAtIndex:1];
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(secondFilterInputTextureUniform, 3);
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [outputFramebuffer texture]);
    glUniform1i(secondFilterInputTextureUniform2, 4);
    
    glVertexAttribPointer(secondFilterPositionAttribute, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GL_FLOAT), vertices);
    glVertexAttribPointer(secondFilterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:kGPUImageNoRotation]);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [outputFramebuffer unlock];
    outputFramebuffer = nil;
    [firstInputFramebuffer unlock];
    firstInputFramebuffer = nil;
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f, 0,
        1.0f, -1.0f, 0,
        -1.0f,  1.0f, 0,
        1.0f,  1.0f, 0
    };
    
    [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation]];
    
    [self informTargetsAboutNewFrameAtTime:frameTime];
}


- (GPUMatrix4x4)matrixFromGLKMatrix4:(GLKMatrix4)M {
    GPUMatrix4x4 newM = {
        M.m00, M.m01, M.m02, M.m03,
        M.m10, M.m11, M.m12, M.m13,
        M.m20, M.m21, M.m22, M.m23,
        M.m30, M.m31, M.m32, M.m33,
    };
    return newM;
}

- (void)getImageFromFrameBuffer {
    CGFloat width = inputTextureSize.width;
    CGFloat height = inputTextureSize.height;
    GLubyte *rawImagePixels = (GLubyte *)malloc(width * height * 4);
    glReadPixels(0, 0, (int)width, (int)height, GL_RGBA, GL_UNSIGNED_BYTE, rawImagePixels);
    NSLog(@"%p", rawImagePixels);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rawImagePixels, width * height * 4, nil);
    CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImageFromBytes = CGImageCreate((int)width, (int)height, 8, 32, 4 * (int)width, defaultRGBColorSpace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    
    UIImage *img = [UIImage imageWithCGImage:cgImageFromBytes];
    NSLog(@"%p", img);
    
    CGImageRelease(cgImageFromBytes);
    CGDataProviderRelease(dataProvider);
    free(rawImagePixels);
    
}

@end
