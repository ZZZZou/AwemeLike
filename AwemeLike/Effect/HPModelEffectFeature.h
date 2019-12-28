//
//  HPModelEffectFeature.h
//  AwemeLike
//
//  Created by wang on 2019/11/2.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "GPUImage.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HPModelEffectFeature : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL enable;

- (GPUImageFilter *)generateEffectFilter;
- (GLfloat *)vertexCoordinates;
- (GLfloat *)textureCoordinates;
- (void)setUniformAtProgram:(GLProgram *)program frameTime:(CMTime)frameTime;

- (void)clear;
@end

@interface HPModelEffectFeatureStickerTransformParams : NSObject
@property(nonatomic, strong) NSDictionary *transformParams;
@end

@interface HPModelEffectFeatureSticker : HPModelEffectFeature
/**
 17==1009==1017
 1001=4
 */
@property(nonatomic, assign) NSInteger blendmode;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) NSUInteger fps;
@property(nonatomic, assign) CGFloat alphaFactor;
@property(nonatomic, assign) NSUInteger zorder;
@property(nonatomic, copy) NSArray<NSNumber*> *stickerIdxList;
@property(nonatomic, copy) NSArray<NSString*> *stickerPathList;

@property(nonatomic, assign) BOOL faceDetect;
@property(nonatomic, readonly) BOOL hasFace;
@property(nonatomic, assign) CGFloat inputAspect;

- (GPUMatrix4x4)vertexMatrix;
- (GPUImageFramebuffer *)stickerFramebufferAtFrameTime:(CMTime)frameTime;
@end

@interface HPModelEffectFeatureStickerV3 : HPModelEffectFeatureSticker

@property(nonatomic, strong) HPModelEffectFeatureStickerTransformParams *transformParams;
@end

@interface HPModelEffectFeatureStickerFace : HPModelEffectFeatureSticker

@property(nonatomic, assign) CGPoint anchorStickerPoint1;
@property(nonatomic, assign) NSInteger anchorFaceIndex1;
@property(nonatomic, assign) CGPoint anchorStickerPoint2;
@property(nonatomic, assign) NSInteger anchorFaceIndex2;
@property(nonatomic, assign) CGPoint scaleStickerPoint1;
@property(nonatomic, assign) NSInteger scaleFaceIndex1;
@property(nonatomic, assign) CGPoint scaleStickerPoint2;
@property(nonatomic, assign) NSInteger scaleFaceIndex2;
@property(nonatomic, assign) CGPoint rotateCenter;
@end

typedef NS_ENUM(NSUInteger, HPModelEffectFeatureGeneralUniformType) {
    HPModelEffectFeatureGeneralUniformTypeSample2D = 1,
    HPModelEffectFeatureGeneralUniformTypeBoolean = 2,
    HPModelEffectFeatureGeneralUniformTypeFloat = 3,
    HPModelEffectFeatureGeneralUniformTypePoint = 4,
    HPModelEffectFeatureGeneralUniformTypeVec3 = 5,
    HPModelEffectFeatureGeneralUniformTypeMatrix4x4 = 8,
    HPModelEffectFeatureGeneralUniformTypeInputTexture = 100,
    HPModelEffectFeatureGeneralUniformTypeInputTextureLast = 101,//buffer
    HPModelEffectFeatureGeneralUniformTypeImageWidth = 200,
    HPModelEffectFeatureGeneralUniformTypeImageHeight = 201,
    HPModelEffectFeatureGeneralUniformTypeTexelWidthOffset = 300,
    HPModelEffectFeatureGeneralUniformTypeTexelHeightOffset = 301,
    HPModelEffectFeatureGeneralUniformTypeFrameTime = 302,
    HPModelEffectFeatureGeneralUniformTypeInputEffectIndex = 1000,
    HPModelEffectFeatureGeneralUniformTypeMattingTexture = 2000,//buffer
    HPModelEffectFeatureGeneralUniformTypeRenderCacheKey = 3000,//buffer
};

@interface HPModelEffectFeatureGeneralUniform : NSObject
@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) HPModelEffectFeatureGeneralUniformType type;
@property(nonatomic, strong) id value;

@end

@interface HPModelEffectFeatureGeneral : HPModelEffectFeature

@property(nonatomic, assign) NSInteger drawMode;//0/1/4
@property(nonatomic, assign) NSInteger drawCount;
@property(nonatomic, assign) NSInteger vertexStep;
@property(nonatomic, assign) NSInteger uvStep;
@property(nonatomic, copy) NSArray<NSNumber*> *vertexData;
@property(nonatomic, copy) NSArray<NSNumber*> *uvData;
@property(nonatomic, copy) NSArray<NSNumber*> *indexData;

@property(nonatomic, copy) NSString *vertexShader;
@property(nonatomic, copy) NSString *fragmentShader;
@property(nonatomic, copy) NSArray<HPModelEffectFeatureGeneralUniform*> *uniforms;

@property(nonatomic, assign) CGSize inputSize;

- (void)setUniformAtProgram:(GLProgram *)program frameTime:(CMTime)frameTime bufferedFilters:(NSDictionary *)bufferedFilters bufferedFramebuffer:(NSDictionary *)bufferedFramebuffers originInputFramebuffer:(GPUImageFramebuffer *)originInputFramebuffer;

- (void)setUniform:(NSString *)name value:(NSArray *)value;
@end


@interface HPModelEffectFeatureLUT : HPModelEffectFeature

@property(nonatomic, copy) NSString *lutPath;
@property (nonatomic, assign) CGFloat intensity;

@property(nonatomic, copy) NSString *thumbPath;
@end

@interface HPModelEffectFeatureFaceMarkup : HPModelEffectFeature

@property(nonatomic, assign) NSInteger blendmode;
@property (nonatomic, assign) CGFloat intensity;
@property (nonatomic, assign) CGRect imageBounds;
@property(nonatomic, copy) NSString *imagePath;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, assign) NSUInteger zorder;
- (GLuint *)elementIndexs;
- (GLsizei)elementCount;
- (GPUImageFramebuffer *)secondFramebuffer;
- (BOOL)hasFace;
@end

NS_ASSUME_NONNULL_END
