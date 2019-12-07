//
//  HPEffectModel.m
//  AwemeLike
//
//  Created by wang on 2019/11/2.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "HPFaceData.h"
#import "FaceDetector.h"
#import "GPUImageFaceMarkupFilter.h"
#import "GPUImageLUTFilter.h"
#import "GPUImageGeneralFilter.h"
#import "GPUImageBlendFilter.h"
#import "HPModelEffectFeature.h"

@implementation GLProgram (HPEffect)

- (GLuint)program {
    return self->program;
}

@end

@implementation HPModelEffectFeature

- (GPUImageFilter *)generateEffectFilter {
    return [[GPUImageFilter alloc] initWithFragmentShaderFromString:kGPUImagePassthroughFragmentShaderString];
}

- (GLfloat *)vertexCoordinates {
    static GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    return imageVertices;
}

- (GLfloat *)textureCoordinates {
    static GLfloat texCoordinate[] = {
        0.0, 0.0,
        1.0, 0.0,
        0.0, 1.0,
        1.0, 1.0
    };
    return texCoordinate;
}

- (void)setUniformAtProgram:(GLProgram *)program frameTime:(CMTime)frameTime {
    
}

- (void)clear {}
@end



@implementation HPModelEffectFeatureSticker
{
    NSUInteger picIndex;
    NSMutableDictionary *picFilters;
    CMTime beginFrameTime;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        picIndex = 0;
        picFilters = [NSMutableDictionary dictionary];
        beginFrameTime = kCMTimeIndefinite;
    }
    return self;
}

- (NSString *)blendFilterName {
    NSDictionary *filterNameMapper = @{
                                       @0: @"Normal",
                                       @4: @"Add",
                                       @17: @"Overlay",
                                       @1001: @"Add",
                                       @1004: @"ColorDodge",
                                       @1009: @"HardLight",
                                       @1015: @"Multiply",
                                       @1017: @"Overlay",
                                       @1019: @"PinLight",
                                       @1021: @"Screen",
                                       @1022: @"SoftLight",
                                       };
    NSString *filterName = filterNameMapper[@(self.blendmode)];
    if (filterName == nil) {
        filterName = @"Normal";
    }
    return filterName;
}

- (GPUImageFilter *)generateEffectFilter {
    
    GPUImageBlendFilter *filter;
    Class filterClass = NSClassFromString([NSString stringWithFormat:@"GPUImageBlendFilter%@", self.blendFilterName]);
    if (filterClass) {
        filter = [filterClass new];
        filter.stickerModel = self;
    }
    return filter;
}

- (BOOL)hasFace {
    FaceModel *oneFace = [FaceDetector shareInstance].oneFace;
    return oneFace != nil;
}

- (GPUMatrix4x4)vertexMatrix {
    return [self matrixFromGLKMatrix4:GLKMatrix4Identity];
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

- (void)setUniformAtProgram:(GLProgram *)program frameTime:(CMTime)frameTime {
    [GPUImageContext setActiveShaderProgram:program];
    GLuint alphaFactorUniform = [program uniformIndex:@"alphaFactor"];
    glUniform1f(alphaFactorUniform, self.alphaFactor);
}

- (GPUImageFramebuffer *)stickerFramebufferAtFrameTime:(CMTime)frameTime {
    
    NSUInteger count = self.stickerIdxList.count;
    NSUInteger index;
    if (self.fps == 0) {
        index = picIndex % count;
        picIndex += 1;
    } else {
        CGFloat duration = 0;
        if (CMTIME_IS_INDEFINITE(beginFrameTime)) {
            beginFrameTime = frameTime;
        } else {
            duration = CMTimeGetSeconds(CMTimeSubtract(frameTime, beginFrameTime));
        }
        index = (int)(duration * self.fps) % count;
    }
    
    NSUInteger finalIndex = [self.stickerIdxList[index] unsignedIntegerValue];
    NSString *imagePath = self.stickerPathList[finalIndex];
    GPUImagePicture *pic = picFilters[@(finalIndex)];
    if (pic == nil) {
        pic = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
        picFilters[@(finalIndex)] = pic;
    }
    return [pic framebufferForOutput];
}

- (void)clear {
    picIndex = 0;
    picFilters = [NSMutableDictionary dictionary];
    beginFrameTime = kCMTimeIndefinite;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"sticker,%@, %@, (%f,%f), %f", self.name, self.blendFilterName, self.width, self.height, self.alphaFactor];
}

@end


@implementation HPModelEffectFeatureStickerTransformParams

- (BOOL)isFaceDetect {
    return [self.transformParams[@"relation"][@"face106"] integerValue] == 1;
}

- (GLKVector2)center:(CGFloat)aspect {
    GLKVector2 scale = [self scaleSize:aspect];
    NSDictionary *config = self.transformParams;
    if (self.isFaceDetect) {
        
        FaceModel *oneFace = [FaceDetector shareInstance].oneFace;
        NSArray *landmarks = oneFace.landmarks;
        
        NSDictionary *point0 = config[@"position"][@"point0"];
        GLKVector2 anchorPoint = GLKVector2Make([[point0[@"anchor"] firstObject] floatValue], [[point0[@"anchor"] lastObject] floatValue]);
        GLKVector2 anchorFacePoint = GLKVector2Make(0, 0);
        for (NSDictionary *facePointInfo in point0[@"point"]) {
            NSInteger faceIndex = [facePointInfo[@"idx"] integerValue];
            CGFloat weight = [facePointInfo[@"weight"] floatValue];
            GLKVector2 facePoint = GLKVector2Make([landmarks[faceIndex] CGPointValue].x, [landmarks[faceIndex] CGPointValue].y);
            anchorFacePoint = GLKVector2Add(anchorFacePoint, GLKVector2MultiplyScalar(facePoint, weight));
        }
        
        GLKVector2 center = GLKVector2Make(0.5, 0.5);
        center = GLKVector2Make(anchorFacePoint.x + (center.x-anchorPoint.x)*scale.x, anchorFacePoint.y + (center.y-anchorPoint.y)*scale.y);
        center = GLKVector2Make(center.x*2-1, center.y*2-1);
        return center;
    } else {
        return GLKVector2Make(0., 0.);
    }
}

- (GLKVector2)scaleSize:(CGFloat)aspect {
    NSDictionary *config = self.transformParams;
    if (self.isFaceDetect) {
        CGFloat scaleX = [config[@"scale"][@"scaleX"][@"factor"] floatValue];
        
        FaceModel *oneFace = [FaceDetector shareInstance].oneFace;
        NSArray *landmarks = oneFace.landmarks;
        
        GLKVector2 anchorFacePoint1 = GLKVector2Make([landmarks[4] CGPointValue].x, [landmarks[4] CGPointValue].y);
        GLKVector2 anchorFacePoint2 = GLKVector2Make([landmarks[28] CGPointValue].x, [landmarks[28] CGPointValue].y);
        CGFloat distance = GLKVector2Distance(anchorFacePoint1, anchorFacePoint2);
        return GLKVector2Make(scaleX * distance, scaleX * distance / aspect);
    } else {
        
        return GLKVector2Make(1, 1/aspect);
    }
}

@end


@implementation HPModelEffectFeatureStickerV3

- (GPUMatrix4x4)vertexMatrix {
    
    if (self.width == 0 || self.height == 0) {
        GLKMatrix4 mvp = GLKMatrix4Identity;
        return [self matrixFromGLKMatrix4:mvp];
    }
    
    CGFloat stickerAspect = self.width/self.height;
    CGFloat inputAspect = self.inputAspect;
    
    GLKVector2 center = [self.transformParams center:stickerAspect];
    GLKVector2 scale = [self.transformParams scaleSize:stickerAspect];
    
    CGFloat rollAngle = 0;
    GLKVector2 rotationCenter = GLKVector2Make(0, 0);
    if (self.transformParams.isFaceDetect) {
        FaceModel *oneFace = [FaceDetector shareInstance].oneFace;
        NSArray *landmarks = oneFace.landmarks;
        rotationCenter = GLKVector2Make([landmarks[16] CGPointValue].x * 2 - 1, [landmarks[16] CGPointValue].y * 2 -1);
        rollAngle = oneFace.rollAngle;
    }
    
    
    GLKMatrix4 projection = GLKMatrix4MakeOrtho(-1, 1, -1/inputAspect, 1/inputAspect, 0 , 100);
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    
    modelMatrix = GLKMatrix4Translate(modelMatrix, center.x, center.y, 0);
//    modelMatrix = GLKMatrix4Translate(modelMatrix, rotationCenter.x, rotationCenter.y, 0);
    modelMatrix = GLKMatrix4RotateZ(modelMatrix, rollAngle);
//    modelMatrix = GLKMatrix4Translate(modelMatrix, -rotationCenter.x, -rotationCenter.y, 0);
    
//    modelMatrix = GLKMatrix4Translate(modelMatrix, center.x, center.y, 0);
    modelMatrix = GLKMatrix4Scale(modelMatrix, scale.x, scale.y, 1);
    GLKMatrix4 mvp = GLKMatrix4Multiply(projection, modelMatrix);
    return [self matrixFromGLKMatrix4:mvp];
}

@end

@implementation HPModelEffectFeatureStickerFace

- (GPUMatrix4x4)vertexMatrix {
    
    FaceModel *oneFace = [FaceDetector shareInstance].oneFace;
    NSArray *landmarks = oneFace.landmarks;
    
    if (!landmarks.count) {
        GLKMatrix4 mvp = GLKMatrix4Identity;
        return [self matrixFromGLKMatrix4:mvp];
    }
    
    //以宽为基准
    CGFloat aspect = self.inputAspect;
    CGFloat stickTexAspect = self.width / self.height;
    
    GLKVector2 anchorFacePoint1 = GLKVector2Make([landmarks[self.anchorFaceIndex1] CGPointValue].x, [landmarks[self.anchorFaceIndex1] CGPointValue].y);
    GLKVector2 anchorFacePoint2 = GLKVector2Make([landmarks[self.anchorFaceIndex2] CGPointValue].x, [landmarks[self.anchorFaceIndex2] CGPointValue].y);
    CGFloat distance1 = GLKVector2Distance(anchorFacePoint1, anchorFacePoint2);
    CGFloat distance2 = fabs(self.anchorStickerPoint1.x - self.anchorStickerPoint2.x);
    CGFloat ratio = distance1 / distance2;
    GLKVector2 stickerCenter = GLKVector2Make(0.5, 0.5);
    stickerCenter = GLKVector2Make(anchorFacePoint2.x + (stickerCenter.x-self.anchorStickerPoint2.x)*ratio, anchorFacePoint2.y + (stickerCenter.y-self.anchorStickerPoint2.y)/stickTexAspect*ratio);
    stickerCenter = GLKVector2Make(stickerCenter.x*2-1, stickerCenter.y*2-1);
    
    
    //贴纸长宽
    GLKVector2 scaleFacePoint1 = GLKVector2Make([landmarks[self.scaleFaceIndex1] CGPointValue].x, [landmarks[self.scaleFaceIndex1] CGPointValue].y);
    GLKVector2 scaleFacePoint2 = GLKVector2Make([landmarks[self.scaleFaceIndex2] CGPointValue].x, [landmarks[self.scaleFaceIndex2] CGPointValue].y);
    distance1 = GLKVector2Distance(scaleFacePoint1, scaleFacePoint2);
    distance2 = fabs(self.scaleStickerPoint1.x - self.scaleStickerPoint2.x);
    CGFloat ndcStickerWidth = distance1 / distance2;
    CGFloat ndcStickerHeight = ndcStickerWidth / stickTexAspect;
    
    //    GLKVector2 rotationCenter = GLKVector2Make(self.rotateCenter.x, self.rotateCenter.y);
    //    rotationCenter = GLKVector2Make(anchorFacePoint2.x + (rotationCenter.x-self.anchorStickerPoint2.x)*ndcStickerWidth, anchorFacePoint2.y + (rotationCenter.y-self.anchorStickerPoint2.y)/stickTexAspect*ndcStickerWidth);
    //    rotationCenter = GLKVector2Make(rotationCenter.x*2-1, rotationCenter.y*2-1);
    
    GLKVector2 rotationCenter = GLKVector2Make([landmarks[43] CGPointValue].x * 2 - 1, [landmarks[43] CGPointValue].y * 2 -1);

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
    
    return [self matrixFromGLKMatrix4:mvp];
}

@end


@interface HPModelEffectFeatureGeneralUniform()

@property(nonatomic, assign) GLint textureUnitIndex;
@property(nonatomic, assign) CGSize inputSize;

- (void)setUniformAtProgram:(GLuint)program frameTime:(CMTime)frameTime bufferedFilters:(NSDictionary *)bufferedFilters bufferedFramebuffer:(NSDictionary *)bufferedFramebuffers originInputFramebuffer:(GPUImageFramebuffer*)originInputFramebuffer;

@end

@implementation HPModelEffectFeatureGeneralUniform
{
    NSUInteger counter;
    NSMutableDictionary *picFilters;
    
    GLuint program;
    CMTime frameTime;
    GLuint location;
}

- (void)clear {
    counter = 0;
    picFilters = [NSMutableDictionary dictionary];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        counter = 0;
        picFilters = [NSMutableDictionary dictionary];
        frameTime = kCMTimeIndefinite;
    }
    return self;
}

- (void)loadImageIfNeed {
    
    if (self.type != HPModelEffectFeatureGeneralUniformTypeSample2D) {
        return;
    }
    NSArray *imagePaths = self.value;
    NSUInteger index = counter;
    NSString *imagePath = imagePaths[index];
    GPUImagePicture *pic = picFilters[@(index)];
    if (pic == nil) {
        pic = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
        picFilters[@(index)] = pic;
    }
}

- (BOOL)needTextureUnit {
    return self.type == HPModelEffectFeatureGeneralUniformTypeSample2D || self.type == HPModelEffectFeatureGeneralUniformTypeInputTexture || self.type == HPModelEffectFeatureGeneralUniformTypeInputTextureLast || self.type == HPModelEffectFeatureGeneralUniformTypeRenderCacheKey || self.type == HPModelEffectFeatureGeneralUniformTypeMattingTexture || self.type == HPModelEffectFeatureGeneralUniformTypeInputEffectIndex;
}

- (BOOL)isBufferedFramebuffer {
    return self.type == HPModelEffectFeatureGeneralUniformTypeRenderCacheKey || self.type == HPModelEffectFeatureGeneralUniformTypeMattingTexture;
}

- (void)setUniformAtProgram:(GLuint)program frameTime:(CMTime)frameTime bufferedFilters:(NSDictionary *)bufferedFilters bufferedFramebuffer:(NSDictionary *)bufferedFramebuffers originInputFramebuffer:(GPUImageFramebuffer *)originInputFramebuffer {
    self->program = program;
    self->frameTime = frameTime;
    
    self->location = glGetUniformLocation(program, [self.name UTF8String]);
    
    switch (self.type) {
        case HPModelEffectFeatureGeneralUniformTypeInputTexture:{
            [self setTextureUnit:originInputFramebuffer.texture];
            break;
        }
        case HPModelEffectFeatureGeneralUniformTypeMattingTexture:
        case HPModelEffectFeatureGeneralUniformTypeInputTextureLast:{
            GPUImageFramebuffer *framebuffer = bufferedFramebuffers[@(HPModelEffectFeatureGeneralUniformTypeInputTextureLast).description];
            [self setTextureUnit:framebuffer.texture];
            break;
        }
        case HPModelEffectFeatureGeneralUniformTypeInputEffectIndex:{
            NSString *key = self.value;
            GPUImageFilter *filter = bufferedFilters[key];
            [self setTextureUnit:filter.framebufferForOutput.texture];
            break;
        }
        case HPModelEffectFeatureGeneralUniformTypeRenderCacheKey:
        {
            GPUImageFramebuffer *framebuffer = bufferedFramebuffers[self.value];
            [self setTextureUnit:framebuffer.texture];
            break;
        }
        case HPModelEffectFeatureGeneralUniformTypeSample2D:
            [self setSample2D:self.value];
            break;
        case HPModelEffectFeatureGeneralUniformTypeBoolean:
            [self setBoolean:self.value];
            break;
        case HPModelEffectFeatureGeneralUniformTypeFloat:
            [self setFloat:self.value];
            break;
        case HPModelEffectFeatureGeneralUniformTypePoint:
            [self setPoint:self.value];
            break;
        case HPModelEffectFeatureGeneralUniformTypeVec3:
            [self setVec3:self.value];
            break;
        case HPModelEffectFeatureGeneralUniformTypeMatrix4x4:
            [self setMatrix4f:self.value];
            break;
        case HPModelEffectFeatureGeneralUniformTypeImageWidth:
            glUniform1i(location, (GLint)self.inputSize.width);
            break;
        case HPModelEffectFeatureGeneralUniformTypeImageHeight:
            glUniform1i(location, (GLint)self.inputSize.height);
            break;
        case HPModelEffectFeatureGeneralUniformTypeTexelWidthOffset:
            glUniform1f(location, 1.0/self.inputSize.width);
            break;
        case HPModelEffectFeatureGeneralUniformTypeTexelHeightOffset:
            glUniform1f(location, 1.0/self.inputSize.height);
            break;
        case HPModelEffectFeatureGeneralUniformTypeFrameTime:
            glUniform1f(location, CMTimeGetSeconds(frameTime));
            break;
        default:
            break;
    }
}

- (void)setTextureUnit:(GLuint)texture {
    
    GLenum target = GL_TEXTURE3 + self.textureUnitIndex;
    glActiveTexture(target);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(location, self.textureUnitIndex+3);
}

- (void)setSample2D:(NSArray<NSString*> *)imagePaths {
    
    NSUInteger index = counter;
    counter += 1;
    counter = counter % imagePaths.count;
    
    GPUImagePicture *pic = picFilters[@(index)];
    [self setTextureUnit:[pic.framebufferForOutput texture]];
}


- (void)setBoolean:(NSArray *)blValue {
    NSUInteger index = counter;
    counter += 1;
    counter = counter % blValue.count;
    
    BOOL bl  = [blValue[index] boolValue];
    glUniform1i(location, bl);
}

- (void)setFloat:(NSArray *)floatValue {
    NSUInteger index = counter;
    counter += 1;
    counter = counter % floatValue.count;
    GLfloat value = [floatValue[index] floatValue];
    glUniform1f(location, value);
}

- (void)setPoint:(NSArray *)pointValue {
    NSUInteger index = counter;
    counter += 1;
    counter = counter % (pointValue.count/2);
    GLfloat positionArray[2];
    positionArray[0] = [pointValue[index * 2 + 0] floatValue];
    positionArray[1] = [pointValue[index * 2 + 1] floatValue];
    
    glUniform2fv(location, 1, positionArray);
}

- (void)setVec3:(NSArray *)vectorValue {
    NSUInteger index = counter;
    counter += 1;
    counter = counter % (vectorValue.count/3);
    GPUVector3 vec3 = {[vectorValue[index * 3 + 0] floatValue], [vectorValue[index * 3 + 1] floatValue], [vectorValue[index * 3 + 2] floatValue]};
    glUniform3fv(location, 1, (GLfloat *)&vec3);
}

- (void)setMatrix4f:(NSArray *)matrixValue {
    NSUInteger index = counter;
    counter += 1;
    counter = counter % (matrixValue.count/16);
    GPUMatrix4x4 matrix = {
        [matrixValue[index * 16 + 0] floatValue], [matrixValue[index * 16 + 1] floatValue], [matrixValue[index * 16 + 2] floatValue], [matrixValue[index * 16 + 3] floatValue],
        [matrixValue[index * 16 + 4] floatValue], [matrixValue[index * 16 + 5] floatValue], [matrixValue[index * 16 + 6] floatValue], [matrixValue[index * 16 + 7] floatValue],
        [matrixValue[index * 16 + 8] floatValue], [matrixValue[index * 16 + 9] floatValue], [matrixValue[index * 16 + 10] floatValue], [matrixValue[index * 16 + 11] floatValue],
        [matrixValue[index * 16 + 12] floatValue], [matrixValue[index * 16 + 13] floatValue], [matrixValue[index * 16 + 14] floatValue], [matrixValue[index * 16 + 15] floatValue],
        
    };
    glUniformMatrix4fv(location, 1, GL_FALSE, (GLfloat *)&matrix);
}


@end

@implementation HPModelEffectFeatureGeneral
{
    CMTime beginFrameTime;
}

- (void)clear {
    beginFrameTime = kCMTimeIndefinite;
    [self.uniforms enumerateObjectsUsingBlock:^(HPModelEffectFeatureGeneralUniform * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj clear];
    }];
}

- (instancetype)init {
    if (self = [super init]) {
        [self setDefaultData];
    }
    
    return self;
}

- (void)setDefaultData {
    
    beginFrameTime = kCMTimeIndefinite;
    
    self.vertexStep = 2;
    self.uvStep = 2;
    self.drawCount = 4;
    self.vertexData = @[@-1, @-1,
                        @1, @-1,
                        @-1, @1,
                        @1, @1,
                        ];
    self.uvData = @[@0, @0,
                    @1, @0,
                    @0, @1,
                    @1, @1,
                    ];
}

- (GLfloat *)vertexCoordinates {
    
    NSUInteger count = self.vertexData.count;
    GLfloat *vertices = malloc(sizeof(GLfloat) * count);
    
    NSUInteger index = 0;
    while (index < count) {
        vertices[index] = [self.vertexData[index] floatValue];
        index += 1;
    }
    return vertices;
}

- (GLfloat *)textureCoordinates {
    NSUInteger count = self.uvData.count;
    GLfloat *texCoordinate = malloc(sizeof(GLfloat) * count);
    
    NSUInteger index = 0;
    while (index < count) {
        texCoordinate[index] = [self.uvData[index] floatValue];
        index += 1;
    }
    return texCoordinate;
}

- (GPUImageFilter *)generateEffectFilter {
    GPUImageGeneralFilter *filter = [[GPUImageGeneralFilter alloc] initWithVertexShaderFromString:self.vertexShader fragmentShaderFromString:self.fragmentShader];
    filter.generalModel = self;
    
    return filter;
}

- (void)setUniformAtProgram:(GLProgram *)program frameTime:(CMTime)frameTime bufferedFilters:(NSDictionary *)bufferedFilters bufferedFramebuffer:(NSDictionary *)bufferedFramebuffers originInputFramebuffer:(GPUImageFramebuffer *)originInputFramebuffer {
    
    [GPUImageContext setActiveShaderProgram:program];
    
    [self.uniforms enumerateObjectsUsingBlock:^(HPModelEffectFeatureGeneralUniform * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj loadImageIfNeed];
    }];
    
    if (CMTIME_IS_INDEFINITE(beginFrameTime)) {
        beginFrameTime = frameTime;
    }
    CMTime diffTime = CMTimeSubtract(frameTime, beginFrameTime);
    __block GLint textureUnitIndex = 0;
    [self.uniforms enumerateObjectsUsingBlock:^(HPModelEffectFeatureGeneralUniform *uniformModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (uniformModel.needTextureUnit) {
            uniformModel.textureUnitIndex = textureUnitIndex;
            textureUnitIndex += 1;
        }
        uniformModel.inputSize = self.inputSize;
        [uniformModel setUniformAtProgram:program.program frameTime:diffTime bufferedFilters:bufferedFilters bufferedFramebuffer:bufferedFramebuffers originInputFramebuffer:originInputFramebuffer];
    }];
    
}

- (void)setUniform:(NSString *)name value:(NSArray *)value {
    
    [self.uniforms enumerateObjectsUsingBlock:^(HPModelEffectFeatureGeneralUniform * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:name]) {
            obj.value = value;
            *stop = true;
        }
    }];
    
}


- (NSString *)description {
    return [NSString stringWithFormat:@"general,%@", self.name];
}
@end

@implementation HPModelEffectFeatureLUT
{
    GPUImagePicture *pic;
}

- (void)clear {
    pic = nil;
}

- (GPUImageFilter *)generateEffectFilter {
    GPUImageLUTFilter *lut = [[GPUImageLUTFilter alloc] init];
    if (pic == nil) {
        pic = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:self.lutPath]];
    }

    [lut setInputFramebuffer:pic.framebufferForOutput atIndex:1];
    lut.intensity = self.intensity;

    return lut;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"LUT,%@", self.name];
}
@end


@implementation HPModelEffectFeatureFaceMarkup
{
    GPUImagePicture *pic;
}

- (GPUImageFilter *)generateEffectFilter {
    
    GPUImageFaceMarkupFilter *filter = [GPUImageFaceMarkupFilter new];
    filter.markupModel = self;
    return filter;
}

- (BOOL)hasFace {
    return [FaceDetector shareInstance].oneFace;
}

- (GLsizei)elementCount {
    if (!self.hasFace) {
        return 6;
    }
    return sizeof(faceIndexs) / sizeof(GLuint);
}

- (GLuint *)elementIndexs {
    if (!self.hasFace) {
        static GLuint elementIndexs[] = {
            0, 1, 2,
            2, 1, 3
        };
        return elementIndexs;
    }
    return faceIndexs;
}

- (GLfloat *)vertexCoordinates {
    
    if (!self.hasFace) {
        return [super vertexCoordinates];
    }
    
    static GLfloat vertexCoordinate[111 * 2];
    FaceModel *faceInfo = [FaceDetector shareInstance].oneFace;
    GLsizei pointCount = (GLsizei)faceInfo.landmarks.count;
    for (int i = 0; i < pointCount; i ++) {
        CGPoint pointer = [faceInfo.landmarks[i] CGPointValue];
        GLfloat x = pointer.x * 2 - 1;
        GLfloat y = pointer.y * 2 - 1;
        vertexCoordinate[i*2+0] = x;
        vertexCoordinate[i*2+1] = y;
    }
    return vertexCoordinate;
}

- (GLfloat *)textureCoordinates {
    if (!self.hasFace) {
        return [super textureCoordinates];
    }
    
    static GLfloat textureCoordinates[111 * 2];
    NSArray *faceTextureCoordinates = [faceTextureCoordinatesString componentsSeparatedByString:@" "];
    GLsizei pointCount = (GLsizei)faceTextureCoordinates.count / 2;
    for (int i = 0; i < pointCount; i ++) {
        
        textureCoordinates[i*2+0] = ([faceTextureCoordinates[i*2+0] floatValue] * 1280 - self.imageBounds.origin.x) / self.imageBounds.size.width;
        textureCoordinates[i*2+1] = ([faceTextureCoordinates[i*2+1] floatValue] * 1280 - self.imageBounds.origin.y) / self.imageBounds.size.height;
    }
    return textureCoordinates;
}

- (void)setUniformAtProgram:(GLProgram *)program frameTime:(CMTime)frameTime {
    [GPUImageContext setActiveShaderProgram:program];
    GLuint intensityUniform = [program uniformIndex:@"intensity"];
    if (self.hasFace) {
        glUniform1f(intensityUniform, self.intensity);
    } else {
        glUniform1i(intensityUniform, 0);
    }
    
    GLuint blendmodeUniform = [program uniformIndex:@"blendMode"];
    glUniform1i(blendmodeUniform, (GLint)self.blendmode);
    
}

- (GPUImageFramebuffer *)secondFramebuffer {
    
    if (pic == nil) {
        if (self.image) {
            pic = [[GPUImagePicture alloc] initWithImage:self.image];
        } else {
            pic = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:self.imagePath]];
        }
        
    }
    return [pic framebufferForOutput];
}

- (void)clear {
    
}

- (NSString *)name {
    return @(self.zorder).description;
}
@end
