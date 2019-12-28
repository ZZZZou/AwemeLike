//
//  HPVideoDecoder.m
//  AwemeLike
//
//  Created by w22543 on 2019/10/9.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "HPVideoDecoder.h"

#define AUDIO_BUFFER_DURATION 5
#define VIDEO_BUFFER_DURATION 3
@implementation HPVideoDecoder
{
    BOOL audioEncodingIsFinished, videoEncodingIsFinished;
    NSURL *url;
    AVAsset *asset;
    AVAssetReader *reader;
    AVAssetReaderTrackOutput *readerVideoTrackOutput;
    AVAssetReaderTrackOutput *readerAudioTrackOutput;
    
    NSUInteger sampleRate;
    NSUInteger channels;
    
    dispatch_semaphore_t semaphore;
    
    CMTime audioLastTime;
    CMTime audioLastDuration;
    CMTime videoLastTime;
    
    CMTime audioBufferDuration;
    CMTime videoBufferDuration;
    
    CMTime minVideoStartTime;
    CMTime maxVideoEndTime;
    
    NSLock *lock;
    
    BOOL isActive;
    
    id observer1;
    id observer2;
}

- (id)initWithURL:(NSURL *)url;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    self->isActive = true;
    self.audioDuration = AUDIO_BUFFER_DURATION;
    self.videoDuration = VIDEO_BUFFER_DURATION;
    self->url = url;
    self->audioLastTime = kCMTimeInvalid;
    self->videoLastTime = kCMTimeInvalid;
    self->semaphore = dispatch_semaphore_create(0);
    self->lock = [[NSLock alloc] init];
    [self addNotification];
    return self;
}

- (void)addNotification {
    __weak typeof(self) wself = self;
   observer1 = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(wself) self = wself;
       
       [self->lock lock];
       self->isActive = false;
       [self->lock unlock];
       
    }];
    observer2 = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(wself) self = wself;
        [self->lock lock];
        self->isActive = true;
        BOOL opened = [self openFile];
        [self->lock unlock];
        if (opened) {
            CMTime nextTime = CMTimeAdd(self->audioLastTime, self->audioLastDuration);
            [self seekToTime:nextTime];
        }
        
    }];
}

- (BOOL)openFile {
    
    if (url == nil) {
        return false;
    }
    
    [self createAsset];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
    BOOL ret = dispatch_semaphore_wait(semaphore, time);
    
    AVAssetTrack *track = [[self->asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    CMAudioFormatDescriptionRef audioFromat = (__bridge CMAudioFormatDescriptionRef)(track.formatDescriptions.firstObject);
    const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(audioFromat);
    self->sampleRate = asbd->mSampleRate;
    self->channels = asbd->mChannelsPerFrame;
    
    self->audioBufferDuration = CMTimeMake(self.audioDuration * sampleRate, (int32_t)sampleRate);
    self->videoBufferDuration = CMTimeMake(self.videoDuration * sampleRate, (int32_t)sampleRate);
    
    self->minVideoStartTime = CMTimeMake(5, 100);
    self->maxVideoEndTime = CMTimeSubtract(self.duration, CMTimeMake(10, 100));
    
    self->reader.timeRange = CMTimeRangeMake(CMTimeMake(0, 1), CMTimeMake(1 * sampleRate, (int32_t)sampleRate));
    if (ret == 0 && asset != nil) {
        return [self->reader startReading];
    }
    return false;
}

- (void)createAsset
{
    asset = nil;
    reader = nil;
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [[AVURLAsset alloc] initWithURL:self->url options:inputOptions];
    
    [inputAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler: ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
            if (tracksStatus != AVKeyValueStatusLoaded)
            {
                NSLog(@"open file fail, %@", error);
                dispatch_semaphore_signal(self->semaphore);
                return;
            }
            self->asset = inputAsset;
            self->reader = [self createAssetReader];
            
            dispatch_semaphore_signal(self->semaphore);
        });
    }];
}

- (AVAssetReader*)createAssetReader {
    NSError *error = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:self->asset error:&error];
    
    NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
//    [outputSettings setObject:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [outputSettings setObject:@(kCVPixelFormatType_32BGRA) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    readerVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[[self->asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] outputSettings:outputSettings];
    readerVideoTrackOutput.alwaysCopiesSampleData = false;
    readerVideoTrackOutput.supportsRandomAccess = true;
    [assetReader addOutput:readerVideoTrackOutput];
    
    NSArray *audioTracks = [self->asset tracksWithMediaType:AVMediaTypeAudio];
    BOOL shouldRecordAudioTrack = [audioTracks count] > 0;
    
    audioEncodingIsFinished = true;
    if (shouldRecordAudioTrack)
    {
        audioEncodingIsFinished = false;
        AVAssetTrack* audioTrack = [audioTracks objectAtIndex:0];
        readerAudioTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:@{AVFormatIDKey: @(kAudioFormatLinearPCM), AVLinearPCMIsFloatKey: @(false), AVLinearPCMBitDepthKey: @(16), AVLinearPCMIsNonInterleaved: @(false), AVLinearPCMIsBigEndianKey: @(false)}];
        readerAudioTrackOutput.alwaysCopiesSampleData = false;
        readerAudioTrackOutput.supportsRandomAccess = true;
        [assetReader addOutput:readerAudioTrackOutput];
    }
    
    return assetReader;
}

- (NSArray *)decodeSampleBuffers {
    
    [lock lock];
    
    if (!self->isActive) {
        [lock unlock];
        return @[@[], @[]];
    }
    NSMutableArray *audioResult = [NSMutableArray array];
    NSMutableArray *videoResult = [NSMutableArray array];
    CMTime audioPTS = kCMTimeZero;
    
    if (reader.status == AVAssetReaderStatusReading && readerAudioTrackOutput) {
        CMSampleBufferRef audioSample = [self readNextSampleFromOutput:readerAudioTrackOutput];
        if (audioSample) {
            CMTime duration = CMSampleBufferGetDuration(audioSample);
            CMTime pts = CMSampleBufferGetPresentationTimeStamp(audioSample);
            audioPTS = CMTimeAdd(pts, duration);
            [audioResult addObject:CFBridgingRelease(audioSample)];
        }
        
    }
    
    BOOL finished = false;
    while (!finished && reader.status == AVAssetReaderStatusReading) {
        
        CMSampleBufferRef videoSample = [self readNextSampleFromOutput:readerVideoTrackOutput];
        CMTime videoPTS = CMSampleBufferGetPresentationTimeStamp(videoSample);
        if (videoSample) {
            if (![self isValidVideoTime:videoPTS]) {
                CFRelease(videoSample);
            } else {
                [videoResult addObject:CFBridgingRelease(videoSample)];
            }
            
        }
        
        if (!videoSample || CMTIME_COMPARE_INLINE(audioPTS, <, videoPTS)) {
            finished = true;
        }

    }
    [lock unlock];
    return @[audioResult, videoResult];
}

- (BOOL)isValidVideoTime:(CMTime)time {
    return CMTIME_COMPARE_INLINE(time, >=, self->minVideoStartTime) && CMTIME_COMPARE_INLINE(time, <=, self->maxVideoEndTime);
}

- (CMSampleBufferRef)decodeSingleVideoSampleBufferAtTime:(CMTime)time {
    
    [self seekToTime:time];
    while (reader.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef videoSample = [self readNextSampleFromOutput:readerVideoTrackOutput];
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(videoSample);
        if ([self isValidVideoTime:pts]) {
            return videoSample;
        }
        if (videoSample) {
            CFRelease(videoSample);
        }
    }
    return nil;
}

- (CMSampleBufferRef)readNextSampleFromOutput:(AVAssetReaderTrackOutput *)output {

    BOOL isAudio = output == readerAudioTrackOutput;
    BOOL finished = isAudio ? audioEncodingIsFinished : videoEncodingIsFinished;
    CMTime lastTime = isAudio ? audioLastTime : videoLastTime;
    CMTime lastDuration =isAudio ? audioLastDuration : kCMTimeZero;
    
    if (reader.status == AVAssetReaderStatusReading && !finished)
    {
        CMSampleBufferRef sampleBufferRef = [output copyNextSampleBuffer];
        if (!sampleBufferRef)
        {
            CMTime nextTime = CMTimeAdd(lastTime, lastDuration);
            sampleBufferRef = [self resetTimeRangeAndReturnNextSampleBuffer:output nextTime:nextTime];
            if (isAudio) {
//                NSLog(@"time: %f, duration: %f", CMTimeGetSeconds(lastTime), CMTimeGetSeconds(CMSampleBufferGetDuration(sampleBufferRef)));
            }
            
        }
        if (sampleBufferRef) {
            lastTime = CMSampleBufferGetPresentationTimeStamp(sampleBufferRef);
            lastDuration = CMSampleBufferGetDuration(sampleBufferRef);
//            NSLog(@"%@ time: %f, duration: %f",isAudio ? @"audio" : @"video", CMTimeGetSeconds(lastTime), CMTimeGetSeconds(CMSampleBufferGetDuration(sampleBufferRef)));
        } else {
            finished = true;
        }
        
        if (isAudio) {
            audioEncodingIsFinished = finished;
            audioLastTime = lastTime;
            audioLastDuration = lastDuration;
        } else {
            videoEncodingIsFinished = finished;
            videoLastTime = lastTime;
        }
        return sampleBufferRef;
    }
    return nil;
}

- (CMSampleBufferRef)resetTimeRangeAndReturnNextSampleBuffer:(AVAssetReaderTrackOutput *)output nextTime:(CMTime)nextTime {
    if (CMTIME_IS_INVALID(nextTime)) {
        return nil;
    }

    BOOL isVideo = output == readerVideoTrackOutput;
    
    CMTime bufferDuration = isVideo ? videoBufferDuration : audioBufferDuration;
    CMTimeRange nextTimeRange = CMTimeRangeMake(nextTime, bufferDuration);
    [output resetForReadingTimeRanges:@[[NSValue valueWithCMTimeRange:nextTimeRange]]];
    //ignore last buffer
    if (isVideo) {
        CMSampleBufferRef tempSample = [output copyNextSampleBuffer];
        if (tempSample) {
            CFRelease(tempSample);
        }
    }
    CMSampleBufferRef nextBuffer = [output copyNextSampleBuffer];

    return nextBuffer;
}

#pragma mark - Seek Time

- (CMTime)seekToBegin {
    return [self seekToTime:kCMTimeZero];
}

- (CMTime)seekToTime:(CMTime)time {
    
    [lock lock];
    CMTime maxTime = maxVideoEndTime;
    if (CMTIME_COMPARE_INLINE(time, >=, maxTime)) {
        time = maxTime;
    }
    CMSampleBufferRef buffer;
    while ((buffer = [readerVideoTrackOutput copyNextSampleBuffer])) {
        CFRelease(buffer);
    };
    while ((buffer = [readerAudioTrackOutput copyNextSampleBuffer])) {
        CFRelease(buffer);
    };
    audioEncodingIsFinished = false;
    videoEncodingIsFinished = false;
    
    NSValue *videoTimeValue = [NSValue valueWithCMTimeRange:CMTimeRangeMake(time, videoBufferDuration)];
    NSValue *audioTimeValue = [NSValue valueWithCMTimeRange:CMTimeRangeMake(time, audioBufferDuration)];
    [readerVideoTrackOutput resetForReadingTimeRanges:@[videoTimeValue]];
    [readerAudioTrackOutput resetForReadingTimeRanges:@[audioTimeValue]];
    
    
    [lock unlock];
    
    return time;
}

#pragma mark - Accessor

- (CMTime)duration {
    return reader.asset.duration;
}

- (BOOL)isEOF {
    return audioEncodingIsFinished && videoEncodingIsFinished;
}

- (NSUInteger)sampleRate {
    return self->sampleRate;
}

- (NSUInteger)channels {
    return self->channels;
    
}

/*
     a  c       cos   -sin
     =
     b  d       sin   cos
 */
- (CGFloat)orientation {
    CGFloat degree = 0;
    NSArray *tracks = [self->asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degree = 90;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degree = 270;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degree = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degree = 180;
        }
    }
    NSLog(@"degree %f", degree);
    return degree;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:observer1];
    [[NSNotificationCenter defaultCenter] removeObserver:observer2];
    
    [readerVideoTrackOutput markConfigurationAsFinal];
    [readerAudioTrackOutput markConfigurationAsFinal];
    [reader cancelReading];
#if !OS_OBJECT_USE_OBJC
    if (semaphore != NULL)
    {
        dispatch_release(semaphore);
    }
#endif
    NSLog(@"HPVideoDecoder Dealloc");
}
@end
