//
//  HPCameraCaptureViewModel.m
//  AwemeLike
//
//  Created by wang on 2019/11/17.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPTwoLookupFilter.h"
#import "GPUImageThinFaceFilter.h"
#import "GPUImageStickerFilter.h"
#import "GPUImageDrawLandmarksFilter.h"
#import "GPUImageBeautyFaceFilter.h"
#import "GPUImageFaceCamera.h"
#import "GPUImage.h"
#import "HPEffectLoader.h"
#import "HPCameraCaptureViewModel.h"

@implementation HPCameraCaptureViewFilterItem

- (NSString *)thumbPath {
    HPModelEffectFeatureLUT *feature = (HPModelEffectFeatureLUT *)self.effect.featureList.firstObject.firstObject;
    return feature.thumbPath;
}

- (CGFloat)intensity  {
    HPModelEffectFeatureLUT *feature = (HPModelEffectFeatureLUT *)self.effect.featureList.firstObject.firstObject;
    return feature.intensity;
}
@end

@interface HPCameraCaptureViewModel()
@property(nonatomic, copy) NSString *outputVideoFilePath;
@end
@implementation HPCameraCaptureViewModel
{
    GPUImageFaceCamera *videoCamera;
    GPUImageBeautyFaceFilter *beautyFilter;
    GPUImageThinFaceFilter *faceFilter;
    HPModelEffect *lipsFilter;
    HPModelEffect *blushFilter;
    GPUImageView *gpuView;
    GPUImageMovieWriter *movieWriter;
    
    HPModelEffect *oneLutFilter;
    HPTwoLookupFilter *twoLutFilter;
    GPUImageOutput *lastFilter;

    UIView *preview;
    
    BOOL recording;
}

- (instancetype)init{
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

- (void)initData {
    [self getFilterItemsFromLocal];
    
}

- (void)getFilterItemsFromLocal {
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    
    NSDictionary *effectDic = [HPEffectLoader loadLUTEffectModelFromLocal];
    NSArray *categorys = @[@"人像", @"风景", @"美食", @"新锐"];
    NSArray *titles = @[@[@"自然", @"白皙", @"慕斯", @"初恋", @"日系", @"鲜嫩", @"奶茶", @"曙光", @"告白", @"初心", @"素净", @"清纯", @"非凡", @"动人", @"活泼", @"蔷薇", @"白雪", @"曲奇"], @[@"海棠", @"仲夏", @"琥珀", @"城市", @"纯净", @"沛蓝", @"纯真", @"清新", @"蔚蓝", @"罗密欧"], @[@"可口", @"美味", @"蜜桃粉", @"西柚", @"摩卡", @"清凉", @"芝士", @"酸奶", @"焦糖"], @[@"日杂", @"年华", @"反差色", @"岛屿", @"乌托邦", @"闪酷橘", @"独角兽", @"拍立得", @"茶灰", @"单色", @"红色", @"过往", @"深黑"]];
    for (NSString *categoryName in categorys) {
        NSInteger section = [categorys indexOfObject:categoryName];
        NSDictionary *effects = effectDic[categoryName];
        NSMutableArray *subTmp = @[].mutableCopy;
        [titles[section] enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
            HPCameraCaptureViewFilterItem *item = [HPCameraCaptureViewFilterItem new];
            item.name = title;
            item.effect = effects[title];
            [subTmp addObject:item];
            
        }];
        [tmp addObject:subTmp];
    }
    self.filterItems = tmp;
}

- (void)setupFacepp {
    [videoCamera setupFacepp];
}

- (void)setupFilter:(UIView *)preview {
    self->preview = preview;
    [gpuView removeFromSuperview];
    gpuView = [[GPUImageView alloc] initWithFrame:preview.bounds];
    [preview addSubview:gpuView];
    
    videoCamera = [[GPUImageFaceCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition: AVCaptureDevicePositionFront];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = true;
    [videoCamera addAudioInputsAndOutputs];
//    videoCamera.drawLandmarks = true;
    
    beautyFilter = [GPUImageBeautyFaceFilter new];
    faceFilter = [GPUImageThinFaceFilter new];
    lipsFilter = [self generateLipsFilter];
    blushFilter = [self generateBlushFilter];

    [videoCamera addTarget:lipsFilter];
    [lipsFilter addTarget:blushFilter];
    [blushFilter addTarget:faceFilter];
    [faceFilter addTarget:beautyFilter];
    lastFilter = beautyFilter;
    
    [lastFilter addTarget:gpuView];
    [videoCamera startCameraCapture];
}

- (HPModelEffect *)generateLipsFilter {
    HPModelEffectFeatureFaceMarkup *markup = [HPModelEffectFeatureFaceMarkup new];
    markup.enable = true;
    markup.blendmode = 15;
    markup.intensity = 0.5 * 0.5;
    markup.imageBounds = CGRectMake(502.5, 710, 262.5, 167.5);
    markup.image = [UIImage imageNamed:@"mouth.png"];
    markup.zorder = 0;
    
    HPModelEffect *effect = [HPModelEffect new];
    effect.featureList = @[@[markup]];
    effect.name = @"Lips";
    
    return effect;
}

- (HPModelEffect *)generateBlushFilter {
    HPModelEffectFeatureFaceMarkup *markup = [HPModelEffectFeatureFaceMarkup new];
    markup.enable = true;
    markup.blendmode = 0;
    markup.intensity = 0.5 * 0.3;
    markup.imageBounds = CGRectMake(395, 520, 489, 209);
    markup.image = [UIImage imageNamed:@"blusher.png"];
    markup.zorder = 0;
    
    HPModelEffect *effect = [HPModelEffect new];
    effect.featureList = @[@[markup]];
    effect.name = @"Blush";
    return effect;
}

- (void)resetMovieWriter {
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/movie.mp4"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToMovie isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:pathToMovie error:nil];
    }
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720, 1280)];
    movieWriter.encodingLiveVideo = YES;
    
    if (oneLutFilter) {
        [oneLutFilter addTarget:movieWriter];
    } else {
        [lastFilter addTarget:movieWriter];
    }
    videoCamera.audioEncodingTarget = movieWriter;
    self.outputVideoFilePath = pathToMovie;
}

#pragma mark -

- (void)startCameraCapture {
    [videoCamera startCameraCapture];
}

- (void)stopCameraCapture {
    [videoCamera stopCameraCapture];
}

- (void)startRecording {
    recording = true;
    [self resetMovieWriter];
    [movieWriter startRecording];
}

- (void)stopRecording:(void(^)(void))completion {
    
    [movieWriter finishRecordingWithCompletionHandler:^{
        self->recording = false;
        completion();
    }];
}

#pragma mark -

- (BOOL)isRecording {
    return recording;
}

- (BOOL)torchAvailable {
    return videoCamera.torchAvailable;
}

- (void)rotateCamera {
    [videoCamera rotateCamera];
}

- (void)lightingSwitch {
    [videoCamera switchTorch];
}

- (void)updateSmooth:(CGFloat)percent {
    CGFloat min = 0;
    CGFloat max = 1;
    beautyFilter.blurAlpha = (max - min) * percent + min;
    beautyFilter.white = 0.1 * percent;
}

- (void)updateThinFace:(CGFloat)percent {
    
    CGFloat min = 0;
    CGFloat max = 0.05;
    faceFilter.thinFaceDelta = (max - min) * percent + min;
}

- (void)updateBigEye:(CGFloat)percent {
    CGFloat min = 0;
    CGFloat max = 0.3;
    faceFilter.bigEyeDelta = (max - min) * percent + min;
}

- (void)updateLipstick:(CGFloat)percent {
    HPModelEffectFeatureFaceMarkup *markup = (HPModelEffectFeatureFaceMarkup *)lipsFilter.featureList.firstObject.firstObject;
    markup.intensity = percent * 0.5;
}

- (void)updateBlusher:(CGFloat)percent {
    HPModelEffectFeatureFaceMarkup *markup = (HPModelEffectFeatureFaceMarkup *)blushFilter.featureList.firstObject.firstObject;
    markup.intensity = percent * 0.3;
}

#pragma mark -

- (void)switchFilterTo:(NSIndexPath *)indexPath {
    if (indexPath) {
        self.filterIndexPath = indexPath;
    }
    runAsynchronouslyOnVideoProcessingQueue(^{
        [self->lastFilter removeAllTargets];
        if (indexPath) {
            HPCameraCaptureViewFilterItem *item = self.filterItems[indexPath.section][indexPath.row];
            HPModelEffect *effect = item.effect;
            [effect removeAllTargets];
            [self->lastFilter addTarget:effect];
            [effect addTarget:self->gpuView];
            self->oneLutFilter = effect;
        } else {
            [self->lastFilter addTarget:self->gpuView];
            self->oneLutFilter = nil;
        }
    });
}

- (void)beginTwoLutFilter:(NSIndexPath *)firstIndexPath secondIndexPath:(NSIndexPath *)secondIndexPath split:(CGFloat)split {
    
    NSArray *filterItems = self.filterItems;
    
    HPCameraCaptureViewFilterItem *firstItem = filterItems[firstIndexPath.section][firstIndexPath.row];
    HPCameraCaptureViewFilterItem *secondItem = filterItems[secondIndexPath.section][secondIndexPath.row];
    
    HPModelEffectFeatureLUT *firstFeature = (HPModelEffectFeatureLUT *)firstItem.effect.featureList.firstObject.firstObject;
    
    HPModelEffectFeatureLUT *secondFeature = (HPModelEffectFeatureLUT *)secondItem.effect.featureList.firstObject.firstObject;
    twoLutFilter = [[HPTwoLookupFilter alloc] initWithLeftLUTPath:firstFeature.lutPath leftIntensity:firstFeature.intensity rightLUTPath:secondFeature.lutPath rightIntensity:secondFeature.intensity split:split];
    
    runAsynchronouslyOnVideoProcessingQueue(^{
        [self->lastFilter removeAllTargets];
        [self->lastFilter addTarget:self->twoLutFilter];
        [self->twoLutFilter addTarget:self->gpuView];
    });
}

- (void)updateTwoLutFilter:(CGFloat)split {
    [twoLutFilter updatesplit:split];
}

- (void)endTwoLutFilter:(NSIndexPath *)indexPath {
    runAsynchronouslyOnVideoProcessingQueue(^{
        [self->lastFilter removeAllTargets];
        [self switchFilterTo:indexPath];
    });
}

- (void)dealloc {
    [movieWriter cancelRecording];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
    });
}
@end
