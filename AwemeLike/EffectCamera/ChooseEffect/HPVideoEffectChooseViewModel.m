//
//  HPVideoEffectChooseViewModel.m
//  AwemeLike
//
//  Created by w22543 on 2019/10/25.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPRangeEffectFilter.h"
#import "HPEffectLoader.h"
#import "HPVideoDecoder.h"
#import "HPVideoEffectChooseViewModel.h"


@implementation HPVideoEffectChooseEffectItem

@end

@interface HPVideoEffectChooseViewModel()<PlayerStateDelegate>

@property(nonatomic, copy) NSString *videoFilePath;
@property(nonatomic, copy) NSString *musicFilePath;
@property(nonatomic, strong) HPPlayer *player;
@property(nonatomic, strong) NSMutableArray<NSArray<HPVideoEffectChooseEffectItem *> *> *allEffectItems;
@property(nonatomic, assign) BOOL faceppIsReseted;
@end
@implementation HPVideoEffectChooseViewModel


- (instancetype)initWithVideoFilePath:(NSString *)videoFilePath musicFilePath:(NSString *)musicFilePath {
    if (self = [super init]) {
        
        self.videoFilePath = videoFilePath;
        self.musicFilePath = musicFilePath;
        [self getAllEffectItems];
        [self resetPlayer];
    }
    return self;
}

- (NSArray<HPModelRangeEffect *> *)currentRangeEffects {
    HPEffectType type = self.currentSection;
    if (type == HPEffectTypeFilter) {
        
        return [HPRangeEffectManager shareInstance].filterEffects;
    } else if (type == HPEffectTypeFaceMarkup) {
        return [HPRangeEffectManager shareInstance].faceMarkupEffects;
    } else if (type == HPEffectTypeTransition) {
        
        return [HPRangeEffectManager shareInstance].transitionEffects;
    } else if (type == HPEffectTypeSplitScreen) {
        
        return [HPRangeEffectManager shareInstance].splitScreenEffects;
    }
    
    return nil;
}

- (NSArray<HPVideoEffectChooseEffectItem *> *)currentEffectItems {
    return self.allEffectItems[self.currentSection];
}

- (void)getAllEffectItems {
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    
    NSDictionary *effectDic = [HPEffectLoader loadEffectModelFromLocal];
    NSArray *categorys = @[@"滤镜", @"识别", @"分屏", @"转场", @"时间"];
    NSArray *titles = @[@[@"闪屏", @"人鱼滤镜", @"爱心泡泡", @"大雨", @"轻颤", @"炫彩", @"撒金粉", @"飘花瓣", @"迷幻烟雾", @"爱心光斑", @"蒸汽波", @"彩虹光斑", @"下雨", @"下雪", @"黑白电影", @"波纹", @"蝴蝶", @"流光", @"星光", @"羽毛", @"花火", @"灵魂出窍", @"抖动", @"幻觉", @"迷离", @"窗格", @"摇摆", @"斑驳", @"老电视", @"毛刺", @"缩放", @"闪白", @"霓虹", @"70s", @"X-Signal"], @[@"王妃", @"玫瑰眼妆", @"浓妆女王", @"飘落小猪猪", @"贴纸妆", @"飘落樱花"], @[@"模糊分屏", @"黑白三屏", @"两屏", @"三屏", @"四屏", @"六屏", @"九屏"], @[@"光斑模糊变清晰", @"开场", @"缩放转场", @"模糊变清晰", @"倒计时", @"电视开机", @"电视关机", @"横滑", @"卷动", @"横线", @"竖线", @"旋转", @"圆环"], @[@"时光倒流", @"反复", @"慢动作"]];
    NSDictionary *timeLoops = @{@"光斑模糊变清晰": @(3.0), @"开场": @(1.75), @"缩放转场": @(11/16.0), @"模糊变清晰": @(1.5), @"倒计时": @(1.75), @"电视开机": @(1.7), @"电视关机": @(1.2), @"横滑": @(0.6), @"卷动": @(0.6), @"竖线": @(0.5), @"横线": @(0.5), @"旋转": @(0.5), @"圆环": @(0.5)};
    for (NSString *categoryName in categorys) {
        NSInteger section = [categorys indexOfObject:categoryName];
        NSDictionary *effects = effectDic[categoryName];
        NSMutableArray *subTmp = @[].mutableCopy;
        [titles[section] enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
            HPVideoEffectChooseEffectItem *item = [HPVideoEffectChooseEffectItem new];
            item.name = title;
            item.color = [self colorWithSection:section item:idx];
            item.effect = effects[title];
            [subTmp addObject:item];
            
            if (section == 3) {
                item.timeLoop = [timeLoops[title] floatValue];
            }
        }];
        [tmp addObject:subTmp];
        self.allEffectItems = tmp;
    }
    
}

- (UIColor *)colorWithSection:(NSInteger)section item:(NSInteger)item {
    
    NSInteger count = 0;
    for (int i = 0; i < self.allEffectItems.count; i++) {
        if (i < section) {
            count = [self.allEffectItems[i] count];
        }
    }
    count += item + 1;
    NSInteger step = 4;
    NSInteger blueStep = step * step;
    NSInteger greenStep = step;
    NSInteger redStep = 1;

    NSInteger blue = count / blueStep;
    
    count = count % blueStep;
    NSInteger green = count / greenStep;
    
    count = count % greenStep;
    NSInteger red = count / redStep;
    
    UIColor *color = [UIColor colorWithRed:(red/(CGFloat)step) green:(green/(CGFloat)step) blue:(blue/(CGFloat)step) alpha:0.8];
    
    return color;
}

#pragma mark - Player

- (void)resetPlayer {
    self.player = [[HPPlayer alloc] initWithFilePath:self.videoFilePath playerStateDelegate:self];
    self.player.musicFilePath = self.musicFilePath;
    self.player.shouldRepeat = true;
    HPRangeEffectFilter *filter = [[HPRangeEffectManager shareInstance] generateFilter];
    self.player.filters = @[filter];
    
    self.player.enableFaceDetector = [HPRangeEffectManager shareInstance].faceMarkupEffects.count > 0;
}

- (void)setPreview:(UIView *)preview {
    _preview = preview;
    self.player.preview = preview;
}

- (void)setMusicVolume:(CGFloat)musicVolume {
    _musicVolume = musicVolume;
    [self.player changeVolume:musicVolume isMusic:true];
}

- (void)setOriginVolume:(CGFloat)originVolume {
    _originVolume = originVolume;
    [self.player changeVolume:originVolume isMusic:false];
}

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (BOOL)isPlaying {
    return self.player.isPlaying;
}

- (CGFloat)duration {
    return CMTimeGetSeconds(self.player.duration);
}

- (void)seekTimeToProgress:(CGFloat)progress {
    CGFloat pos = progress * CMTimeGetSeconds(self.player.duration);
    CMTime time = CMTimeMake(pos * 1000000, 1000000);
    [self.player seekToTime:time];
}

- (void)seekTimeToProgress:(CGFloat)progress state:(HPPlayerSeekTimeStatus)state {
    CGFloat pos = progress * CMTimeGetSeconds(self.player.duration);
    CMTime time = CMTimeMake(pos * 1000000, 1000000);
    [self.player seekToTime:time status:state];
}

- (void)presentFirstFrameBuffer {
    [self.player pause];
    [self.player seekToTime:kCMTimeZero status:HPPlayerSeekTimeStatusEnd];
    
}

#pragma mark - PlayerStateDelegate

- (void)progressDidChange:(CGFloat)progress {
//    if (progress == 1) {
//        NSLog(@"progress == %f", progress);
//    }
    if (self.progressDidChange) {
        self.progressDidChange(progress);
    }
}

#pragma mark - thumb Video Image

- (void)decodeImage:(NSInteger)num scaleToWidth:(CGFloat)targetWidth completion:(void(^)(UIImage *img, NSInteger index))completion {
    NSURL *url = [NSURL fileURLWithPath:self.videoFilePath];
    HPVideoDecoder *decoder = [[HPVideoDecoder alloc] initWithURL:url];
    decoder.audioDuration = 0.1;
    decoder.videoDuration = 0.1;
    BOOL opened = [decoder openFile];
    if (opened) {
        UIImageOrientation orientation = UIImageOrientationUp;
        if (decoder.orientation == 90) {
            orientation = UIImageOrientationLeft;
        } else if (decoder.orientation == 180) {
            orientation = UIImageOrientationDown;
        } else if (decoder.orientation == 270) {
            orientation = UIImageOrientationRight;
        }
        CMTime duration = decoder.duration;
        CMTime step = CMTimeMake(duration.value, duration.timescale * ((int)num - 1));
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for (int i = 0; i < num; i++) {
                @autoreleasepool {
                    CMTime time = CMTimeMultiply(step, i);
                    CMSampleBufferRef sampleBuffer = [decoder decodeSingleVideoSampleBufferAtTime:time];
                    UIImage *img = [self imageFromSampleBuffer:sampleBuffer targetWidth:targetWidth orientation:orientation];
                    CFRelease(sampleBuffer);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        completion(img, i);
                    });
                    
                }
            }
        });
    }
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer targetWidth:(CGFloat)targetWidth orientation:(UIImageOrientation)orientation {
    
    CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CGFloat bufferWidth = CVPixelBufferGetBytesPerRow(imageBuffer)/4;
    CGFloat bufferHeight = CVPixelBufferGetHeight(imageBuffer);
    CGFloat scale = targetWidth / bufferWidth;
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *rawImagePixels = CVPixelBufferGetBaseAddress(imageBuffer);
    
    //不要使用下列被注释的方法来创建image，这种方法可能只是引用指向图片数据的地址，而不是复制；
    //假如使用这种方式创建了图片，然后赋值给CALayer的content，接着你释放CMSampleBuffer，也就是释放了内存中的图片数据，
    //则程序会在接下来渲染CALayer的时候崩溃（因为CALayer的content（CGImageRef）中的图片数据已经被释放）
    //    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rawImagePixels, bufferWidth * bufferHeight * 4, nil);
    //    CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();
    //    CGImageRef cgImageFromBytes = CGImageCreate((int)bufferWidth, (int)bufferHeight, 8, 32, 4 * (int)bufferWidth, defaultRGBColorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    //    UIImage *img = [UIImage imageWithCGImage:cgImageFromBytes scale:scale orientation:orientation];
    //
    //    CGImageRelease(cgImageFromBytes);
    //    CGDataProviderRelease(dataProvider);
    CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(rawImagePixels, bufferWidth, bufferHeight, 8, bufferWidth * 4, defaultRGBColorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    UIImage *img = [UIImage imageWithCGImage:newImage scale:scale orientation:orientation];
    CGImageRelease(newImage);
    CGColorSpaceRelease(defaultRGBColorSpace);
    CGContextRelease(newContext);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return img;
}

#pragma mark - LongPressAction

- (void)beginLongPressAtIndex:(NSInteger)index {
    self.player.shouldRepeat = false;
    [self.player play];
    
    HPVideoEffectChooseEffectItem *effectItem = self.currentEffectItems[index];
    HPModelRangeEffect *rangeEffect = [HPModelRangeEffect new];
    rangeEffect.type = self.currentSection;
    rangeEffect.sequenceIn = self.player.currentTime;
    rangeEffect.color = effectItem.color;
    rangeEffect.effect = effectItem.effect;
    
    [HPRangeEffectManager shareInstance].ongoingRangeEffect = rangeEffect;
    
}

- (void)endLongPress {
    [self.player pause];
    self.player.shouldRepeat = true;
    HPRangeEffectManager *manager = [HPRangeEffectManager shareInstance];
    manager.ongoingRangeEffect.sequenceOut = self.player.currentTime;
    [manager addEffect:manager.ongoingRangeEffect];
    manager.ongoingRangeEffect = nil;
}

#pragma mark - TapAction

- (void)tapTransitionEffectAtIndex:(NSInteger)index {
    
    if (self.currentSection == 3) {//转场
        HPVideoEffectChooseEffectItem *effectItem = self.currentEffectItems[index];
        CMTime timeLoop = CMTimeMake(effectItem.timeLoop * 1000000, 1000000);
        
        HPModelRangeEffect *rangeEffect = [HPModelRangeEffect new];
        rangeEffect.type = self.currentSection;
        rangeEffect.sequenceIn = self.player.currentTime;
        rangeEffect.color = effectItem.color;
        rangeEffect.effect = effectItem.effect;
        rangeEffect.sequenceOut = CMTimeAdd(self.player.currentTime, timeLoop);
        [[HPRangeEffectManager shareInstance] addEffect:rangeEffect];
        
        [self.player play];
    } else if (self.currentSection == 1){//识别
        [self pause];
        HPVideoEffectChooseEffectItem *effectItem = self.currentEffectItems[index];
        HPModelRangeEffect *rangeEffect = [HPModelRangeEffect new];
        rangeEffect.type = self.currentSection;
        rangeEffect.sequenceIn = kCMTimeZero;
        rangeEffect.color = effectItem.color;
        rangeEffect.effect = effectItem.effect;
        rangeEffect.sequenceOut = self.player.duration;
        [[HPRangeEffectManager shareInstance] removeLastEffectByType:HPEffectTypeFaceMarkup];
        [[HPRangeEffectManager shareInstance] addEffect:rangeEffect];
        
        self.player.enableFaceDetector = true;
        [self play];
        [self seekTimeToProgress:0];
    }
}

#pragma mark - RangeEffect

- (HPModelRangeEffect *)removeLastRangeEffect {
    
    HPModelRangeEffect *removed = [[HPRangeEffectManager shareInstance] removeLastEffectByType:self.currentSection];
    
    self.player.enableFaceDetector = [HPRangeEffectManager shareInstance].faceMarkupEffects.count > 0;
    return removed;
}

- (void)removeAllRangeEffect {
    [[HPRangeEffectManager shareInstance] clear];
}

@end
