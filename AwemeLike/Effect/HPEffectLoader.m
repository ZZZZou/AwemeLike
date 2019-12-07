//
//  HPEffectLoader.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/6.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPEffectLoader.h"

@implementation HPEffectLoader

#pragma mark - LUT Effect

+ (NSDictionary *)loadLUTEffectModelFromLocal {
    
    NSString *rootPath = [[NSBundle mainBundle] pathForResource:@"effect.bundle/filter" ofType:nil];
    
    NSMutableDictionary *temp = @{}.mutableCopy;
    NSArray *categoryList = @[@"人像", @"风景", @"美食",@"新锐"];
    for (NSString *category in categoryList) {
        NSString *categoryRootPath = [NSString stringWithFormat:@"%@/%@", rootPath, category];
        NSDictionary *effects = [self loadLUTEffectModelsFrom:categoryRootPath];
        temp[category] = effects;
    }
    
    return temp;
}

+ (NSDictionary<NSString*, HPModelEffect*> *)loadLUTEffectModelsFrom:(NSString *)rootPath {

    NSMutableDictionary *effectDic = @{}.mutableCopy;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *effectNameList = [fm contentsOfDirectoryAtPath:rootPath error:nil];
    
    for (NSString *effectName in effectNameList) {
        //get config json
        NSString *effectRootPath = [NSString stringWithFormat:@"%@/%@", rootPath, effectName];
        NSString *configPath = [NSString stringWithFormat:@"%@/config.json", effectRootPath];
        NSDictionary *config = [self loadJsonObjectFrom:configPath];
        
        NSString *lutName = [config[@"content"] allKeys][0];
        CGFloat intensity = [config[@"content"][lutName][@"intensity"] floatValue];
        NSString *lutPath = [NSString stringWithFormat:@"%@/%@/%@.png", effectRootPath, lutName, lutName];
        NSString *thumbPath = [NSString stringWithFormat:@"%@/thumbnail.jpg", effectRootPath];
        
        HPModelEffectFeatureLUT *feature = [HPModelEffectFeatureLUT new];
        feature.name = lutName;
        feature.enable = true;
        feature.lutPath = lutPath;
        feature.intensity = intensity;
        feature.thumbPath = thumbPath;
        
        HPModelEffect *effect = [HPModelEffect new];
        effect.featureList = @[@[feature]];
        effect.name = effectName;
        
        effectDic[effectName] = effect;
    }
    return effectDic;
}

#pragma mark -
#pragma mark - Effect

+ (Class)effectClass:(NSString *)name {
    NSDictionary *clsMap = @{
                             @"人鱼滤镜": @"HPModelEffect_Mermaid",
                             @"闪屏": @"HPModelEffect_FlashScreen",
                             @"窗格": @"HPModelEffect_Pane",
                             @"幻觉": @"HPModelEffect_Vision",
                             @"迷离": @"HPModelEffect_Mili",
                             @"轻颤": @"HPModelEffect_Tremble",
//                             @"Bling": @"HPModelEffect_Bling",
//                             @"爱心bling": @"HPModelEffect_LoveBling",
//                             @"粒子": @"HPModelEffect_Point",
//                             @"线性": @"HPModelEffect_Line",
                             
                             @"光斑模糊变清晰": @"HPModelEffect_FaculaBlur",
                             @"倒计时": @"HPModelEffect_Countdown",
                             @"模糊变清晰": @"HPModelEffect_Blur",
                             @"开场": @"HPModelEffect_Open",
                             @"缩放转场": @"HPModelEffect_Scale",
                             @"电视开机": @"HPModelEffect_Startup",
                             @"电视关机": @"HPModelEffect_Shutdown",
                             };
    Class cls = NSClassFromString(clsMap[name]);
    if (cls == nil) {
        cls = HPModelEffect.class;
    }
    return cls;
}

+ (NSDictionary *)loadEffectModelFromLocal {
    
    NSString *rootPath = [[NSBundle mainBundle] pathForResource:@"effect.bundle" ofType:nil];
    
    NSMutableDictionary *temp = @{}.mutableCopy;
    NSArray *categoryList = @[@"滤镜", @"识别", @"转场",@"分屏"];
    for (NSString *category in categoryList) {
        NSString *categoryRootPath = [NSString stringWithFormat:@"%@/%@", rootPath, category];
        NSDictionary *effects = [self loadEffectModelsFrom:categoryRootPath];
        temp[category] = effects;
    }
    
    return temp;
}

+ (NSDictionary<NSString*, HPModelEffect*> *)loadEffectModelsFrom:(NSString *)rootPath {
    
    
    NSMutableDictionary *effectDic = @{}.mutableCopy;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *effectNameList = [fm contentsOfDirectoryAtPath:rootPath error:nil];
    
    for (NSString *effectName in effectNameList) {
        //get config json
        NSString *effectRootPath = [NSString stringWithFormat:@"%@/%@", rootPath, effectName];
        NSString *configPath = [NSString stringWithFormat:@"%@/config.json", effectRootPath];
        NSDictionary *config = [self loadJsonObjectFrom:configPath];
        
        NSMutableArray *subEffectList = @[].mutableCopy;
        //sub effect list
        NSArray *subEffectInfoList = config[@"effect"][@"Link"];
        for (NSDictionary *subEffectInfo in subEffectInfoList) {
            
            NSMutableArray *featureList = @[].mutableCopy;
            //get sub effect content json
            BOOL enable = subEffectInfo[@"defaultEnable"] ? [subEffectInfo[@"defaultEnable"] boolValue] : true;
            NSString *subEffectType = subEffectInfo[@"type"];
            NSString *subEffectPath = subEffectInfo[@"path"];
            NSString *subEffectRootPath = [NSString stringWithFormat:@"%@/%@", effectRootPath, subEffectPath];
            
            if ([subEffectType isEqualToString:@"2DStickerV3"]) {
                
                NSString *contentPath = [NSString stringWithFormat:@"%@/content.json", subEffectRootPath];
                NSString *subconfigPath = [self getSubconfigPath:contentPath];
                NSDictionary *subconfig = [self loadJsonObjectFrom:subconfigPath];
                
                //1. get sticker file path list
                NSMutableArray *stickerList = @[].mutableCopy;
                [subconfig[@"texturefiles"] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *path = [NSString stringWithFormat:@"%@/%@", [subconfigPath stringByDeletingLastPathComponent], obj];
                    [stickerList addObject:path];
                }];
                
                //2. convert sticker config
                NSMutableArray *usedKeys = @[].mutableCopy;
                NSString *entityKey = [subconfig[@"parts"] allKeys].firstObject;
                NSDictionary *featureConfigList = subconfig[@"parts"][entityKey];
                for (NSString *featureKey in featureConfigList.allKeys) {
                    NSString *key = featureKey;
                    for (NSString *suffix in @[@"_widthAlign", @"_heightAlign", @"_Vertical"]) {
                        key = [key stringByReplacingOccurrencesOfString:suffix withString:@""];
                    }
                    if ([usedKeys containsObject:key]) {
                        continue;
                    }
                    [usedKeys addObject:key];
                    NSDictionary *effectConfig = featureConfigList[featureKey];
                    
                    HPModelEffectFeatureStickerV3 *featureModel = [self convertStickerConfig:effectConfig];
                    featureModel.name = key;
                    featureModel.enable = enable;
                    featureModel.stickerPathList = stickerList;
                    featureModel.faceDetect = false;
                    [featureList addObject:featureModel];
                }
                [featureList sortUsingComparator:^NSComparisonResult(HPModelEffectFeatureSticker *obj1, HPModelEffectFeatureSticker *obj2) {
                    return obj1.zorder > obj2.zorder;
                }];
                
            } else if ([subEffectType isEqualToString:@"2DSticker"]) {
                
                NSString *contentPath = [NSString stringWithFormat:@"%@/content.json", subEffectRootPath];
                NSString *subconfigPath = [self getSubconfigPath:contentPath];
                NSDictionary *subconfig = [self loadJsonObjectFrom:subconfigPath];
                
                NSDictionary *featureConfigList = subconfig[@"parts"];
                for (NSString *featureKey in featureConfigList.allKeys) {
                    NSDictionary *featureConfig = featureConfigList[featureKey];
                    HPModelEffectFeatureStickerFace *featureModel = [HPModelEffectFeatureStickerFace new];
                    featureModel.blendmode = [featureConfig[@"blendMode"] integerValue];
                    featureModel.width = [featureConfig[@"width"] floatValue];
                    featureModel.height = [featureConfig[@"height"] floatValue];
                    featureModel.fps = [featureConfig[@"fps"] unsignedIntegerValue];
                    featureModel.alphaFactor = [featureConfig[@"alphaFactor"] floatValue];
                    featureModel.zorder = [featureConfig[@"zorder"] unsignedIntegerValue];
                    featureModel.name = featureKey;
                    featureModel.enable = enable;
                    
                    //Face Detect
                    featureModel.faceDetect = true;
                    NSArray *anchorPoints = featureConfig[@"position"][@"positionX"];
                    featureModel.anchorStickerPoint1 = CGPointMake([anchorPoints.firstObject[@"x"] floatValue]/featureModel.width, [anchorPoints.firstObject[@"y"] floatValue]/featureModel.height);
                    featureModel.anchorFaceIndex1 = [anchorPoints.firstObject[@"index"] integerValue];
                    featureModel.anchorStickerPoint2 = CGPointMake([anchorPoints.lastObject[@"x"] floatValue]/featureModel.width, [anchorPoints.lastObject[@"y"] floatValue]/featureModel.height);
                    featureModel.anchorFaceIndex2 = [anchorPoints.lastObject[@"index"] integerValue];
                    
                    NSDictionary *scalePoint1 = [featureConfig[@"scale"][@"scaleX"][@"pointA"] firstObject];
                    featureModel.scaleStickerPoint1 = CGPointMake([scalePoint1[@"x"] floatValue]/featureModel.width, [scalePoint1[@"y"] floatValue]/featureModel.height);
                    featureModel.scaleFaceIndex1 = [scalePoint1[@"index"] integerValue];
                    NSDictionary *scalePoint2 = [featureConfig[@"scale"][@"scaleX"][@"pointB"] firstObject];
                    featureModel.scaleStickerPoint2 = CGPointMake([scalePoint2[@"x"] floatValue]/featureModel.width, [scalePoint2[@"y"] floatValue]/featureModel.height);
                    featureModel.scaleFaceIndex2 = [scalePoint2[@"index"] integerValue];
                    
                    NSDictionary *rotateCenter = [featureConfig[@"rotateCenter"] firstObject];
                    featureModel.rotateCenter = CGPointMake([rotateCenter[@"x"] floatValue]/featureModel.width, [rotateCenter[@"y"] floatValue]/featureModel.height);
                    
                    NSInteger frameCount = [featureConfig[@"frameCount"] integerValue];
                    NSMutableArray *stickerPathList = @[].mutableCopy;
                    NSMutableArray *stickerIdxList = @[].mutableCopy;
                    for (int i = 0; i < frameCount; i++) {
                        NSString *prefix;
                        if (i < 10) {
                            prefix = @"00";
                        } else if (i < 100) {
                            prefix = @"0";
                        }
                        NSString *path = [NSString stringWithFormat:@"%@/%@/%@_%@%d", [subconfigPath stringByDeletingLastPathComponent], featureKey, featureKey, prefix, i];
                        [stickerPathList addObject:path];
                        [stickerIdxList addObject:@(i)];
                    }
                    featureModel.stickerPathList = stickerPathList;
                    featureModel.stickerIdxList = stickerIdxList;
                    
                    [featureList addObject:featureModel];
                }
                [featureList sortUsingComparator:^NSComparisonResult(HPModelEffectFeatureSticker *obj1, HPModelEffectFeatureSticker *obj2) {
                    return obj1.zorder > obj2.zorder;
                }];
                
            } else if ([subEffectType isEqualToString:@"GeneralEffect"]) {
                
                NSString *contentPath = [NSString stringWithFormat:@"%@/content.json", subEffectRootPath];
                NSString *subconfigPath = [self getSubconfigPath:contentPath];
                NSDictionary *subconfig = [self loadJsonObjectFrom:subconfigPath];
                
                NSArray *filterList = subconfig[@"effect"];
                for (NSDictionary *filterConfig in filterList) {
                    HPModelEffectFeatureGeneral *featureModel = [self convertGeneralConfig:filterConfig resourceRootPath:[subconfigPath stringByDeletingLastPathComponent]];
                    featureModel.enable = enable;
                    if (featureModel.vertexShader.length && featureModel.fragmentShader.length) {
                        [featureList addObject:featureModel];
                    }
                }
                
            } else if([subEffectType isEqualToString:@"Filter"]) {
                NSString *configPath = [NSString stringWithFormat:@"%@/config.json", subEffectRootPath];
                NSDictionary *config = [self loadJsonObjectFrom:configPath];
                NSString *lutPath = [NSString stringWithFormat:@"%@/filter/filter.png", subEffectRootPath];
                HPModelEffectFeatureLUT *lut = [HPModelEffectFeatureLUT new];
                lut.lutPath = lutPath;
                lut.name = [subEffectRootPath lastPathComponent];
                lut.intensity = config ? [config[@"content"][@"filter"][@"intensity"] floatValue] : 1;
                lut.enable = enable;
                [featureList addObject:lut];
            } else if([subEffectType isEqualToString:@"FaceMakeupV2"]) {
                NSString *contentPath = [NSString stringWithFormat:@"%@/content.json", subEffectRootPath];
                NSString *subconfigPath = [self getSubconfigPath:contentPath];
                NSDictionary *subconfig = [self loadJsonObjectFrom:subconfigPath];
                
                for (NSDictionary *featureInfo in subconfig[@"filters"]) {
                    if ([featureInfo[@"filterType"] isEqualToString:@"brow"] || [featureInfo[@"filterType"] isEqualToString:@"pupil"]) {
                        continue;
                    }
                    HPModelEffectFeatureFaceMarkup *markup = [HPModelEffectFeatureFaceMarkup new];
                    markup.enable = enable;
                    markup.blendmode = [featureInfo[@"blendMode"] integerValue];
                    markup.intensity = [featureInfo[@"intensity"] floatValue];
                    NSDictionary *rect = featureInfo[@"rect"];
                    markup.imageBounds = CGRectMake([rect[@"x"] floatValue], [rect[@"y"] floatValue], [rect[@"width"] floatValue], [rect[@"height"] floatValue]);
                    NSString *path = featureInfo[@"2d_sequence_resources"][@"path"];
                    NSString *name = featureInfo[@"2d_sequence_resources"][@"name"];
                    if (!path.length || !name.length) {
                        continue;
                    }
                    markup.imagePath = [NSString stringWithFormat:@"%@/%@/%@000.png", [subconfigPath stringByDeletingLastPathComponent], path, name];
                    markup.zorder = [featureInfo[@"zPosition"] integerValue];
                    
                    [featureList addObject:markup];
                }
                [featureList sortUsingComparator:^NSComparisonResult(HPModelEffectFeatureSticker *obj1, HPModelEffectFeatureSticker *obj2) {
                    return obj1.zorder > obj2.zorder;
                }];
                
                
            } else {
                NSLog(@"未识别的effect：%@, %@", subEffectType, effectName);
            }
            
            [subEffectList addObject:featureList];
        }
        
        Class cls = [self effectClass:effectName];
        HPModelEffect *effect = [[cls alloc] init];
        effect.featureList = subEffectList;
        effect.name = effectName;
        
        effectDic[effectName] = effect;
    }
    
    return effectDic;
}

+ (HPModelEffectFeatureStickerV3 *)convertStickerConfig:(NSDictionary *)effectConfig {
    
    HPModelEffectFeatureStickerV3 *effectModel = [HPModelEffectFeatureStickerV3 new];
    effectModel.blendmode = [effectConfig[@"blendmode"] integerValue];
    effectModel.width = [effectConfig[@"width"] floatValue];
    effectModel.height = [effectConfig[@"height"] floatValue];
    effectModel.fps = [effectConfig[@"fps"] unsignedIntegerValue];
    effectModel.alphaFactor = [effectConfig[@"alphaFactor"] floatValue];
    effectModel.zorder = [effectConfig[@"zorder"] unsignedIntegerValue];
    
    effectModel.stickerIdxList = effectConfig[@"textureIdx"][@"idx"];
    HPModelEffectFeatureStickerTransformParams *transformParams = [HPModelEffectFeatureStickerTransformParams new];
    transformParams.transformParams = effectConfig[@"transformParams"];
    effectModel.transformParams = transformParams;
    return effectModel;
}

+ (HPModelEffectFeatureGeneral *)convertGeneralConfig:(NSDictionary *)filterConfig resourceRootPath:(NSString *)resourceRootPath {
    
    NSString *vertexPath = [NSString stringWithFormat:@"%@/%@", resourceRootPath, filterConfig[@"vertexShader"]];
    NSString *fragmentPath = [NSString stringWithFormat:@"%@/%@", resourceRootPath, filterConfig[@"fragmentShader"]];
    
    NSArray *inputEffects = filterConfig[@"inputEffect"];
    HPModelEffectFeatureGeneral *effectModel = [HPModelEffectFeatureGeneral new];
    
    effectModel.vertexShader = [NSString stringWithContentsOfFile:vertexPath encoding:NSUTF8StringEncoding error:nil];
    effectModel.fragmentShader = [NSString stringWithContentsOfFile:fragmentPath encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *drawParam = filterConfig[@"BRCDrawParam"];
    if (drawParam) {
        effectModel.drawMode = [drawParam[@"BRCDrawMode"] integerValue];
        effectModel.drawCount = [drawParam[@"BRCDrawCount"] integerValue];
        effectModel.vertexStep = [drawParam[@"BRCDrawVertexStep"] integerValue];
        effectModel.uvStep = [drawParam[@"BRCDrawUVStep"] integerValue];
        effectModel.vertexData = drawParam[@"BRCDrawVertexData"];
        effectModel.uvData = drawParam[@"BRCDrawUVData"];
        effectModel.indexData = drawParam[@"BRCDrawIndexData"];
    }
    
    NSMutableArray *uniformModelList = @[].mutableCopy;
    NSMutableArray *uniformList = @[].mutableCopy;
    [uniformList addObjectsFromArray:filterConfig[@"fUniforms"]];
    [uniformList addObjectsFromArray:filterConfig[@"vUniforms"]];
    [uniformList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HPModelEffectFeatureGeneralUniform *uniform = [HPModelEffectFeatureGeneralUniform new];
        uniform.name = obj[@"name"];
        uniform.type = [obj[@"type"] integerValue];
        uniform.value = obj[@"data"];
        
        [uniformModelList addObject:uniform];
        NSMutableArray *tempImgPaths = @[].mutableCopy;
        if (uniform.type == HPModelEffectFeatureGeneralUniformTypeSample2D) {
            [uniform.value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [tempImgPaths addObject:[NSString stringWithFormat:@"%@/%@", resourceRootPath, obj]];
            }];
            uniform.value = tempImgPaths;
        } else if (uniform.type == HPModelEffectFeatureGeneralUniformTypeInputEffectIndex) {
            NSInteger index = [obj[@"inputEffectIndex"] integerValue];
            uniform.value = inputEffects[index];
        } else if (uniform.type == HPModelEffectFeatureGeneralUniformTypeRenderCacheKey) {
            uniform.value = obj[@"renderCacheKey"];
        }
    }];
    [uniformModelList sortUsingComparator:^NSComparisonResult(HPModelEffectFeatureGeneralUniform *obj1, HPModelEffectFeatureGeneralUniform *obj2) {
        return obj1.type > obj2.type;
    }];
    effectModel.uniforms = uniformModelList;
    
    effectModel.name = filterConfig[@"name"];
    
    return effectModel;
}

+ (NSString *)getSubconfigPath:(NSString *)contentPath {
    
    NSDictionary *content = [self loadJsonObjectFrom:contentPath];
    NSString *subconfigPath = content[@"content"][@"path"];
    if (subconfigPath.length == 0) {
        return nil;
    }
    subconfigPath = [NSString stringWithFormat:@"%@/%@",[contentPath stringByDeletingLastPathComponent], subconfigPath];
    NSString *subconfigName = content[@"content"][@"config"];
    if (subconfigName.length) {
        subconfigPath = [NSString stringWithFormat:@"%@/%@", subconfigPath, subconfigName];
    }
    return subconfigPath;
}

+ (id)loadJsonObjectFrom:(NSString *)path {
    NSData *contentData = [NSData dataWithContentsOfFile:path];
    if (contentData) {
        id content = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingAllowFragments error:nil];
        
        return content;
    }
    return nil;
}

@end
