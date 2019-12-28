//
//  HPPlayerViewController.m
//  AwemeLike
//
//  Created by w22543 on 2019/10/9.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPPlayerSynchronizer.h"
#import "HPAudioOutput.h"
#import "HPVideoOutput.h"
#import "HPPlayer.h"

@interface HPPlayer ()<FillDataDelegate, PlayerStateDelegate>
{
    HPPlayerSynchronizer* synchronizer;
    HPVideoOutput* videoOutput;
    HPAudioOutput* audioOutput;
    
    GPUImageMovieWriter *movieWriter;
    
    BOOL isPlaying;
    BOOL savedIsPlaying;
    BOOL isPlayFinished;

    
    NSString * videoFilePath;
    
    __weak id<PlayerStateDelegate> playerStateDelegate;
    
    id observer1;
    id observer2;
}
@end

@implementation HPPlayer

- (instancetype)initWithFilePath:(NSString *)path playerStateDelegate:(id<PlayerStateDelegate>)delegate {
    return [self initWithFilePath:path preview:nil playerStateDelegate:delegate];
}

- (instancetype)initWithFilePath:(NSString *)path preview:(UIView *)preview playerStateDelegate:(id<PlayerStateDelegate>)delegate {
    NSAssert(path.length > 0, @"empty path");
    self = [super init];
    if (self) {
        self.preview = preview;
        self->videoFilePath = path;
        self->playerStateDelegate = delegate;
        [self initializePlayer];
        [self addNotification];
    }
    return self;
}

- (void)initializePlayer {
    
    synchronizer = [[HPPlayerSynchronizer alloc] initWithPlayerStateDelegate:self];
//    __weak typeof(self) wself = self;
//    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0) , ^{
//        __strong typeof(wself) self = wself;
    
        if (self) {
            BOOL bl = [self->synchronizer openFile:self->videoFilePath];
            if(bl){
//                dispatch_async(dispatch_get_main_queue(), ^{
                    self->videoOutput = [[HPVideoOutput alloc] initWithFrame:self.preview.bounds orientation:self->synchronizer.orientation];
                    self->videoOutput.filters = self.filters;
                    self->videoOutput.enableFaceDetector = self.enableFaceDetector;
                    [self.preview insertSubview:self->videoOutput.preview atIndex:0];
//                });
                NSInteger audioChannels = [self->synchronizer channels];
                NSInteger audioSampleRate = [self->synchronizer sampleRate];
                self->audioOutput = [[HPAudioOutput alloc] initWithChannels:audioChannels sampleRate:audioSampleRate filleDataDelegate:self];
            }
        }
//    });
}

- (void)destoryPlayer {
    
    if(audioOutput){
        [audioOutput stop];
        audioOutput = nil;
    }
    if(synchronizer){
        [synchronizer closeFile];
        synchronizer = nil;
    }
    if(videoOutput){
        if ([NSThread isMainThread]) {
            [self->videoOutput.preview removeFromSuperview];
            self->videoOutput = nil;
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self->videoOutput.preview removeFromSuperview];
                self->videoOutput = nil;
            });
        }
    }
    isPlaying = false;
}

- (void)addNotification {
    __weak typeof(self) wself = self;
    observer1 = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(wself) self = wself;
        
        self->savedIsPlaying = self.isPlaying;
        [self pause];
    }];
    
    observer2 = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(wself) self = wself;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self->savedIsPlaying) {
                [self play];
            }
        });
        
    }];
}

#pragma mark - Control

- (void)play {
    
//    NSLog(@"playing : %@", [NSThread currentThread]);
    if (isPlaying)
        return;
    if(audioOutput){
        if (isPlayFinished) {
            [synchronizer seekToTime:kCMTimeZero isLast:true completion:^(CMSampleBufferRef sample) {
                
                [self->audioOutput playWithMusicFile:self.musicFilePath startOffset:CMTimeGetSeconds(self->synchronizer.currentTime)];
                self->isPlaying = true;
                self->isPlayFinished = false;
            }];
        } else {
            [audioOutput playWithMusicFile:self.musicFilePath startOffset:CMTimeGetSeconds(synchronizer.currentTime)];
            isPlaying = true;
        }
    }
}

- (void)pause;
{
//    NSLog(@"pausing : %@", [NSThread currentThread]);
    if (!isPlaying)
        return;
    if(audioOutput){
        [audioOutput stop];
        isPlaying = false;
    }
}

- (void)playWithMusic:(NSString *)musicFilePath {
    _musicFilePath = musicFilePath;
    [self pause];
    [synchronizer seekToTime:kCMTimeZero isLast:true completion:^(CMSampleBufferRef sample) {
        
        [self->audioOutput playWithMusicFile:self.musicFilePath startOffset:CMTimeGetSeconds(self->synchronizer.currentTime)];
        self->isPlaying = true;
        self->isPlayFinished = false;
    }];
}

- (void)changeVolume:(CGFloat)volume isMusic:(CGFloat)isMusic {
    if (isMusic) {
        audioOutput.musicVolume = volume;
    } else {
        audioOutput.originVolume = volume;
    }
}

- (CGFloat)musicVolume {
    return audioOutput.musicVolume;
}

- (CGFloat)originVolume {
    return audioOutput.originVolume;
}

- (void)seekToTime:(CMTime)time status:(HPPlayerSeekTimeStatus)status {
    isPlayFinished = false;
    if (status == HPPlayerSeekTimeStatusBegin) {
        self->savedIsPlaying = self.isPlaying;
        [self pause];
    }
    BOOL isLast = status == HPPlayerSeekTimeStatusEnd;
    [synchronizer seekToTime:time isLast:isLast completion:^(CMSampleBufferRef sample) {
        if (sample) {
            [self->videoOutput presentVideoSampleBuffer:sample];
        }
        if (isLast && self->savedIsPlaying) {
            [self play];
        }
    }];
}

- (void)seekToTime:(CMTime)time {
    [self seekToTime:time status:HPPlayerSeekTimeStatusBegin];
    [self seekToTime:time status:HPPlayerSeekTimeStatusEnd];
}

#pragma mark - VideoOutput

- (void)setFilters:(NSArray *)filters {
    _filters = filters;
    if (videoOutput) {
         videoOutput.filters = filters;
    }
}

- (void)setEnableFaceDetector:(BOOL)enableFaceDetector {
    _enableFaceDetector = enableFaceDetector;
    if (videoOutput) {
        videoOutput.enableFaceDetector = enableFaceDetector;
    }
}

#pragma mark - Accessor

- (NSUInteger)channels {
    return synchronizer.channels;
}

- (NSInteger)sampleRate {
    return synchronizer.sampleRate;
}

- (CMTime)currentTime {
    return [synchronizer currentTime];
}

- (CMTime)duration {
    return [synchronizer duration];
}

- (BOOL)isPlaying
{
    return isPlaying;
}

- (void)setPreview:(UIView *)preview {
    _preview = preview;
    if (videoOutput) {
        [videoOutput.preview removeFromSuperview];
        videoOutput.preview.frame = preview.bounds;
        [preview insertSubview:videoOutput.preview atIndex:0];
    }
}
#pragma mark - PlayerStateDelegate

- (void)openFileSucceed {
    if ([playerStateDelegate respondsToSelector:@selector(openFileSucceed)]) {
        [playerStateDelegate openFileSucceed];
    }
}

- (void)openFileFail {
    if ([playerStateDelegate respondsToSelector:@selector(openFileFail)]) {
        [playerStateDelegate openFileFail];
    }
}

- (void)progressDidChange:(CGFloat)progress {
    if ([playerStateDelegate respondsToSelector:@selector(progressDidChange:)]) {
        [playerStateDelegate progressDidChange:progress];
    }
}

- (void)bufferLoadingWillBegin {
    if ([playerStateDelegate respondsToSelector:@selector(bufferLoadingWillBegin)]) {
        [playerStateDelegate bufferLoadingWillBegin];
    }
}

- (void)bufferLoadingDidEnd {
    if ([playerStateDelegate respondsToSelector:@selector(bufferLoadingDidEnd)]) {
        [playerStateDelegate bufferLoadingDidEnd];
    }
}

- (void)bufferLoadingTimeout {
    [self pause];
    if ([playerStateDelegate respondsToSelector:@selector(bufferLoadingTimeout)]) {
        [playerStateDelegate bufferLoadingTimeout];
    }
}

- (void)onCompletion {
    
    if (self.shouldRepeat) {
        [self seekToTime:self.duration status:HPPlayerSeekTimeStatusBegin];
        [self seekToTime:kCMTimeZero status:HPPlayerSeekTimeStatusEnd];
    } else {
        [self pause];
        isPlayFinished = true;
        if ([playerStateDelegate respondsToSelector:@selector(onCompletion)]) {
            [playerStateDelegate onCompletion];
        }
    }
}

#pragma mark - FillDataDelegate

- (NSInteger)fillAudioData:(SInt16*)sampleBuffer numFrames:(NSInteger)frameNum numChannels:(NSInteger)channels;
{
    static NSTimeInterval lastTime = 0;
    
    NSTimeInterval currTime = [[NSDate date] timeIntervalSince1970];
//    NSLog(@"%f", currTime-lastTime);
    lastTime = currTime;
    
    if(synchronizer && ![synchronizer isPlayCompleted]) {
        
        [synchronizer audioCallbackFillData:sampleBuffer numFrames:(UInt32)frameNum numChannels:(UInt32)channels];
        CMSampleBufferRef videoSampleBuffer = [synchronizer getCorrectVideoSampleBuffer];
        if(videoSampleBuffer){
            [videoOutput presentVideoSampleBuffer:videoSampleBuffer];
        }
    } else {
        memset(sampleBuffer, 0, frameNum * channels * sizeof(SInt16));
    }
    
    
    
    return 1;
}

- (void)recordDidReceiveAudioBuffer:(AudioBufferList *)audioBuffer {
    
}



- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer1];
    [[NSNotificationCenter defaultCenter] removeObserver:observer2];
    [self destoryPlayer];
    NSLog(@"HPPlayer Dealloc...");
}

@end
