//
//  HPCameraEditViewModel.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/26.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPRangeEffectManager.h"
#import "GPUImageFaceMovie.h"
#import "HPAudioMix.h"
#import "HPRangeEffectFilter.h"
#import "GPUImageBeautyFaceFilter.h"
#import "HPPlayer.h"
#import "HPCameraEditViewModel.h"

@implementation HPCameraEditMusicItem

@end


@interface HPCameraEditViewModel()<PlayerStateDelegate>
{
    GPUImageFaceMovie *movieFile;
    GPUImageMovieWriter *movieWriter;
    NSString *musicPath;
}
@property(nonatomic, strong) HPPlayer *player;

@end
@implementation HPCameraEditViewModel

- (NSString *)musicPath {
    return self->musicPath;
}

- (CGFloat)musicVolume {
    return self.player.musicVolume;
}

- (CGFloat)originVolume {
    return self.player.originVolume;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)initData {
    
    NSString *rootPath = [[NSBundle mainBundle] pathForResource:@"music.bundle" ofType:nil];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *musicNameList = [fm contentsOfDirectoryAtPath:rootPath error:nil];
    
    NSMutableArray *tmp = @[].mutableCopy;
    for (NSString *musicName in musicNameList) {
        //get config json
        NSString *musicPath = [NSString stringWithFormat:@"%@/%@", rootPath, musicName];
        
        HPCameraEditMusicItem *item = [HPCameraEditMusicItem new];
        item.name = [musicName stringByDeletingPathExtension];
        item.path = musicPath;
        [tmp addObject:item];
    }
    
    [tmp sortUsingComparator:^NSComparisonResult(HPCameraEditMusicItem *obj1, HPCameraEditMusicItem *obj2) {
        return obj1.name.integerValue > obj2.name.integerValue;
    }];
    self.musicItems = tmp;
}

- (void)initPlayer {
    self.player = [[HPPlayer alloc] initWithFilePath:self.videoPath playerStateDelegate:self];
    self.player.shouldRepeat = true;
    HPRangeEffectFilter *filter = [[HPRangeEffectManager shareInstance] generateFilter];
    self.player.filters = @[filter];
}

- (void)setVideoPath:(NSString *)videoPath {
    _videoPath = videoPath;
    
    [self initPlayer];
    [self play];
}

- (void)setPreview:(UIView *)preview {
    self.player.preview = preview;
    
}

- (void)play {
    self.player.enableFaceDetector = [HPRangeEffectManager shareInstance].faceMarkupEffects.count > 0;
    [self.player play];
}

- (void)playWithMusic:(NSString *)music {
    self->musicPath = music;
    self.player.enableFaceDetector = [HPRangeEffectManager shareInstance].faceMarkupEffects.count > 0;
    [self.player playWithMusic:music];
}

- (void)pause {
    [self.player pause];
}

- (void)changeVolume:(CGFloat)volume isMusic:(CGFloat)isMusic {
    [self.player changeVolume:volume isMusic:isMusic];
}

- (void)saveMovieWithProgressHandle:(void(^)(CGFloat progress))progressHandle {
    
    [self.player pause];
    NSString *originVideoPath = self.videoPath;
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/finalMovie.mp4"];
    
    movieFile = [[GPUImageFaceMovie alloc] initWithURL:[NSURL fileURLWithPath:originVideoPath]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToMovie isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:pathToMovie error:nil];
    }
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720, 1280)];
    movieFile.audioEncodingTarget = movieWriter;
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    
    HPRangeEffectFilter *filter = [[HPRangeEffectManager shareInstance] generateFilter];
    [movieFile addTarget:filter];
    [filter addTarget:movieWriter];
    
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    NSInteger channels = self.player.channels;
    NSInteger sampleRate = self.player.sampleRate;
    movieFile.channels = channels;
    movieFile.sampleRate = sampleRate;
    CGFloat duration = CMTimeGetSeconds(self.player.duration);
    NSString *musicPath = self->musicPath;
    __block HPAudioMix *audioMix;
    if (musicPath.length) {
        audioMix = [[HPAudioMix alloc] initWithChannels:channels sampleRate:sampleRate musicFile:musicPath];
        audioMix.originVolume = self.player.originVolume;
        audioMix.musicVolume = self.player.musicVolume;
        [audioMix start];
        progressHandle(0);
        __block CMItemCount numOffset = 0;
        movieWriter.audioProcessingCallback = ^(SInt16 **samplesRef, CMItemCount numSamplesInBuffer) {
            [audioMix mixAudioData:*samplesRef numAudioFrame:numSamplesInBuffer];
            
            CGFloat progress = (CGFloat)numOffset/sampleRate/duration;
            progressHandle(progress);
            
            numOffset += numSamplesInBuffer;
        };
    }
    
    __weak typeof(self) wself = self;
    [movieWriter setCompletionBlock:^{
        [audioMix stop];
        audioMix = nil;
        NSLog(@"finished reading");
        __strong typeof(wself) self = wself;
        [self->movieWriter finishRecordingWithCompletionHandler:^{
            NSLog(@"finished recored");
            progressHandle(1);
            [self.player play];
        }];
    }];
}

- (void)dealloc {
    NSLog(@"HPCameraEditViewModel dealloc");
    [movieWriter cancelRecording];
    [movieFile cancelProcessing];
}
@end
