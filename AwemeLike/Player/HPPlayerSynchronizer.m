//
//  HPPlayerSynchronizer.m
//  AwemeLike
//
//  Created by apple on 16/8/25.
//  Copyright © 2016年 xiaokai.zhan. All rights reserved.
//

#import "HPPlayerSynchronizer.h"
#import "HPVideoDecoder.h"
#import <UIKit/UIDevice.h>
#import <pthread.h>

#define LOCAL_MIN_BUFFERED_DURATION                     0.5
#define LOCAL_MAX_BUFFERED_DURATION                     1.0
#define NETWORK_MIN_BUFFERED_DURATION                   2.0
#define NETWORK_MAX_BUFFERED_DURATION                   4.0
#define LOCAL_AV_SYNC_MAX_TIME_DIFF                     0.05
#define FIRST_BUFFER_DURATION                           0.5

NSString * const kMIN_BUFFERED_DURATION = @"Min_Buffered_Duration";
NSString * const kMAX_BUFFERED_DURATION = @"Max_Buffered_Duration";

@interface HPPlayerSynchronizer () {
    
    HPVideoDecoder*                                     decoder;
    BOOL                                                isOnDecodeThread;
    BOOL                                                isInitializeDecodeThread;
    BOOL                                                isStopDecoding;
    NSLock*                                             decodeLock;
    
    
    BOOL                                                completion;
    
    /** 解码第一段buffer的控制变量 **/
    pthread_mutex_t                                     decodeFirstBufferLock;
    pthread_cond_t                                      decodeFirstBufferCondition;
    pthread_t                                           decodeFirstBufferThread;
    /** 是否正在解码第一段buffer **/
    BOOL                                                isDecodingFirstBuffer;
    pthread_mutex_t                                     videoDecoderLock;
    pthread_cond_t                                      videoDecoderCondition;
    pthread_t                                           videoDecoderThread;
    
    /** 分别是当外界需要音频数据和视频数据的时候, 全局变量缓存数据 **/
    NSLock*                                             bufferlock;
    NSMutableArray*                                     videoBuffers;
    NSMutableArray*                                     audioBuffers;
    CMSampleBufferRef                                   currentAudioBuffer;
    NSUInteger                                          currentAudioBufferPos;
    CMTime                                              audioPosition;
    
    
    /** 控制何时该解码 **/
    BOOL                                                buffering;
    CGFloat                                             bufferedDuration;
    CGFloat                                             minBufferedDuration;
    CGFloat                                             maxBufferedDuration;
    CGFloat                                             syncMaxTimeDiff;
    
    NSTimeInterval                                      bufferedBeginTime;
    
    //seek time
    NSOperationQueue                                    *seekOperationQueue;
    dispatch_semaphore_t                                newDataSemaphore;
    NSTimeInterval                                      lastSeekTime;
    NSTimeInterval                                      lastSeekVideoTime;
    NSTimeInterval                                      minSeekTimeInterval;
    NSTimeInterval                                      minSeekVideoTimeInterval;
    
    //progress
    NSTimeInterval                                      lastProgress;
    NSTimeInterval                                      minProgressInterval;
}

@end

@implementation HPPlayerSynchronizer

- (id)initWithPlayerStateDelegate:(id<PlayerStateDelegate>) playerStateDelegate {
    self = [super init];
    if (self) {
        _playerStateDelegate = playerStateDelegate;
    }
    return self;
}


#pragma mark - Decode Thread

- (void)stopDecoderThread {
    
    [decodeLock lock];
    isStopDecoding = true;
    [decodeLock unlock];
}

- (void)resumeDecoderThread {
    [decodeLock lock];
    if(NULL == decoder || !isOnDecodeThread) {
        return;
    }
    isStopDecoding = false;
    pthread_mutex_lock(&videoDecoderLock);
    pthread_cond_signal(&videoDecoderCondition);
    pthread_mutex_unlock(&videoDecoderLock);
    
    [decodeLock unlock];
}

static void* runDecoderThread(void* ptr) {
    HPPlayerSynchronizer* synchronizer = (__bridge HPPlayerSynchronizer*)ptr;
    [synchronizer run];
    return NULL;
}

- (void)run {
    while(isOnDecodeThread){
        pthread_mutex_lock(&videoDecoderLock);
//        NSLog(@"Before wait decode Buffer...");
        pthread_cond_wait(&videoDecoderCondition, &videoDecoderLock);
//        NSLog(@"After wait decode Buffer...");
        pthread_mutex_unlock(&videoDecoderLock);
        [self decodeFrames];
    }
    NSLog(@"Decode Thread Destroyed");
}

static void* decodeFirstBufferRunLoop(void* ptr) {
    HPPlayerSynchronizer* synchronizer = (__bridge HPPlayerSynchronizer*)ptr;
    [synchronizer decodeFirstBuffer];
    return NULL;
}

- (void)decodeFirstBuffer {
    double startDecodeFirstBufferTimeMills = CFAbsoluteTimeGetCurrent() * 1000;
    [self decodeFramesWithDuration:FIRST_BUFFER_DURATION];
    int wasteTimeMills = CFAbsoluteTimeGetCurrent() * 1000 - startDecodeFirstBufferTimeMills;
    NSLog(@"Decode First Buffer waste TimeMills is %d", wasteTimeMills);
    pthread_mutex_lock(&decodeFirstBufferLock);
    pthread_cond_signal(&decodeFirstBufferCondition);
    pthread_mutex_unlock(&decodeFirstBufferLock);
    isDecodingFirstBuffer = false;
}

- (void)decodeFrames {
    [self decodeFramesWithDuration:maxBufferedDuration];
}

- (void)decodeFramesWithDuration:(CGFloat)duration {
    BOOL good = YES;
    while (good) {
        [decodeLock lock];
        
        if (isStopDecoding) {
            [decodeLock unlock];
            break;
        }
        @autoreleasepool {
            if (decoder) {
                NSArray *samples = [decoder decodeSampleBuffers];
                good = [self addSampleBuffers:samples duration:duration];
            }
        }
        [decodeLock unlock];
    }
}

- (BOOL)addSampleBuffers:(NSArray *)sampleBuffers duration:(CGFloat)duration {
    NSArray *firstBuffer = sampleBuffers[0];
    NSArray *secondBuffer = sampleBuffers[1];
    BOOL bufferIsEmpty = firstBuffer.count == 0 && secondBuffer.count == 0;
    if (bufferIsEmpty) {//解码完毕时
        dispatch_semaphore_signal(newDataSemaphore);
        return false;
    }
    [bufferlock lock];
    if (firstBuffer.count) {
        for(int i = 0; i < firstBuffer.count; i++) {
            CMSampleBufferRef sample = (__bridge CMSampleBufferRef)firstBuffer[i];
            CMTime time = CMSampleBufferGetDuration(sample);
            [audioBuffers addObject:(__bridge id)(sample)];
            bufferedDuration += CMTimeGetSeconds(time);
        }
    }
    if (secondBuffer.count) {
        for(int i = 0; i < secondBuffer.count; i++) {
            CMSampleBufferRef sample = (__bridge CMSampleBufferRef)secondBuffer[i];
            [videoBuffers addObject:(__bridge id)(sample)];
        }
    }
    
    [bufferlock unlock];
    
    if (bufferedDuration) {
         dispatch_semaphore_signal(newDataSemaphore);
    }
    return bufferedDuration < duration;
}

#pragma mark - Open File

- (BOOL)openFile:(NSString *)path {
    decoder = [[HPVideoDecoder alloc] initWithURL:[NSURL fileURLWithPath:path]];
    BOOL ret = [decoder openFile];
    if (!ret) {
        if(self.playerStateDelegate && [self.playerStateDelegate respondsToSelector:@selector(openFileFail)]){
            [self.playerStateDelegate openFileFail];
        }
        return false;
    } else {
        if(self.playerStateDelegate && [self.playerStateDelegate respondsToSelector:@selector(openFileSucceed)]){
            [self.playerStateDelegate openFileSucceed];
        }
    }
    
    decodeLock = [[NSLock alloc] init];
    
    //缓存
    bufferedBeginTime = -1;
    bufferlock = [[NSLock alloc] init];
    audioBuffers = [NSMutableArray array];
    videoBuffers = [NSMutableArray array];
    currentAudioBufferPos = 0;

    minBufferedDuration = LOCAL_MIN_BUFFERED_DURATION;
    maxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION;
    syncMaxTimeDiff = LOCAL_AV_SYNC_MAX_TIME_DIFF;
    
    //seekTime
    seekOperationQueue = [[NSOperationQueue alloc] init];
    seekOperationQueue.maxConcurrentOperationCount = 1;
    seekOperationQueue.name = @"com.player.seektime";
    newDataSemaphore = dispatch_semaphore_create(0);
    minSeekTimeInterval = 0.1;
    minSeekVideoTimeInterval = CMTimeGetSeconds(self.duration) / 300 < 0.5 ? CMTimeGetSeconds(self.duration) / 300 : 0.5 ;
    
    //progress
    minProgressInterval = 0.01;

    [self startDecoderThread];
    [self startDecodeFirstBufferThread];
    return true;
}

- (void)startDecodeFirstBufferThread {
    pthread_mutex_init(&decodeFirstBufferLock, NULL);
    pthread_cond_init(&decodeFirstBufferCondition, NULL);
    isDecodingFirstBuffer = true;
    
    pthread_create(&decodeFirstBufferThread, NULL, decodeFirstBufferRunLoop, (__bridge void*)self);
}

- (void)startDecoderThread {
    NSLog(@"HPPlayerSynchronizer::startDecoderThread ...");
    //    _dispatchQueue      = dispatch_queue_create("KxMovie", DISPATCH_QUEUE_SERIAL);
    
    isOnDecodeThread = true;
    pthread_mutex_init(&videoDecoderLock, NULL);
    pthread_cond_init(&videoDecoderCondition, NULL);
    isInitializeDecodeThread = true;
    pthread_create(&videoDecoderThread, NULL, runDecoderThread, (__bridge void*)self);
}

#pragma mark - Close File

- (void)closeFile {
   
    [self removeAllBuffer];
    [self destroyDecodeFirstBufferThread];
    [self destroyDecoderThread];
}

//目标：清除缓存之后的获取的数据都是可用的（不包含老数据）
//方法：首先停止解码线程，然后删除本地缓存，使用锁来保证线程同步
- (void)removeAllBuffer {
    
    [self stopDecoderThread];
    
    [bufferlock lock];
    
    [videoBuffers removeAllObjects];
    [audioBuffers removeAllObjects];
    
    if (currentAudioBuffer) {
        CFRelease(currentAudioBuffer);
    }
    currentAudioBuffer = nil;
    currentAudioBufferPos = 0;
    
    audioPosition = kCMTimeZero;
    bufferedDuration = 0;
    buffering = false;
    
    [bufferlock unlock];
}

- (void)destroyDecodeFirstBufferThread {
    
    if (isDecodingFirstBuffer) {
        NSLog(@"Begin Wait Decode First Buffer...");
        double startWaitDecodeFirstBufferTimeMills = CFAbsoluteTimeGetCurrent() * 1000;
        pthread_mutex_lock(&decodeFirstBufferLock);
        pthread_cond_wait(&decodeFirstBufferCondition, &decodeFirstBufferLock);
        pthread_mutex_unlock(&decodeFirstBufferLock);
        int wasteTimeMills = CFAbsoluteTimeGetCurrent() * 1000 - startWaitDecodeFirstBufferTimeMills;
        NSLog(@" Wait Decode First Buffer waste TimeMills is %d", wasteTimeMills);
    }
}

- (void)destroyDecoderThread {
    NSLog(@"HPPlayerSynchronizer::destroyDecoderThread ...");
    
    isOnDecodeThread = false;
    if (!isInitializeDecodeThread) {
        return;
    }
    if (videoDecoderThread) {
        void* status;
        pthread_mutex_lock(&videoDecoderLock);
        pthread_cond_signal(&videoDecoderCondition);
        pthread_mutex_unlock(&videoDecoderLock);
        pthread_join(videoDecoderThread, &status);
        videoDecoderThread = nil;
        pthread_mutex_destroy(&videoDecoderLock);
        pthread_cond_destroy(&videoDecoderCondition);
    }
}


#pragma mark - Fill Audio And Get Video

static float lastPosition = -1.0;
- (CMSampleBufferRef)getCorrectVideoSampleBuffer {
    CMSampleBufferRef sample = NULL;
    CMTime position;
    
    [bufferlock lock];
    while (videoBuffers.count > 0) {
        sample = (__bridge CMSampleBufferRef)videoBuffers[0];
        position = CMSampleBufferGetPresentationTimeStamp(sample);
        CGFloat delta =  CMTimeGetSeconds(CMTimeSubtract(audioPosition, position));
        if (delta < (0 - syncMaxTimeDiff)) {//视频太快了
            sample = NULL;
            break;
        }
        CFRetain(sample);
        [videoBuffers removeObjectAtIndex:0];
        if (delta > syncMaxTimeDiff) {//视频太慢了
            CFRelease(sample);
            sample = NULL;
            continue;
        }
        break;
    }
    [bufferlock unlock];
    
    if(sample &&  fabs(CMTimeGetSeconds(audioPosition) - lastPosition) > 0.01f){
        lastPosition = CMTimeGetSeconds(audioPosition);
        return sample;
    } else {
        return nil;
    }
}

- (void)audioCallbackFillData:(SInt16 *)aOutData
                    numFrames:(UInt32)aNumFrames
                  numChannels:(UInt32)numChannels {
    void *outData = aOutData;
    UInt32 numFrames = aNumFrames;
    [self checkPlayState];
    if (buffering) {
        memset(outData, 0, numFrames * numChannels * sizeof(SInt16));
        return;
    }
    @autoreleasepool {
        [bufferlock lock];
        while (numFrames > 0) {
            if (!currentAudioBuffer) {
                NSUInteger count = audioBuffers.count;
                if (count > 0) {
                    CMSampleBufferRef sample = (CMSampleBufferRef)CFBridgingRetain(audioBuffers[0]);
                    [audioBuffers removeObjectAtIndex:0];
                    audioPosition =  CMSampleBufferGetPresentationTimeStamp(sample);
                    bufferedDuration -= CMTimeGetSeconds(CMSampleBufferGetDuration(sample));
                    currentAudioBuffer = sample;
                    currentAudioBufferPos = 0;
                }
            }
            if (currentAudioBuffer) {
                CMBlockBufferRef buffer = CMSampleBufferGetDataBuffer(currentAudioBuffer);
                AudioBufferList audioBufferList;
                CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(currentAudioBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &buffer);
    
                NSUInteger usedAudioSize = currentAudioBufferPos;
                const void *bytes = audioBufferList.mBuffers[0].mData + usedAudioSize;
                UInt32 size = audioBufferList.mBuffers[0].mDataByteSize;
                NSUInteger bytesLeft = (size - usedAudioSize);
                NSUInteger bytesPerFrame = numChannels * sizeof(SInt16);
                NSUInteger bytesToCopy = numFrames * bytesPerFrame;
                if (bytesToCopy <= bytesLeft) {
                    memcpy(outData, bytes, bytesToCopy);
                    numFrames = 0;
                    usedAudioSize += bytesToCopy;
                } else {
                    memcpy(outData, bytes, bytesLeft);
                    outData = outData + bytesLeft;
                    numFrames -= bytesLeft/bytesPerFrame;
                    usedAudioSize += bytesLeft;
                }
                
                CGFloat totalAudioSize = size;
                CMTime duration = CMSampleBufferGetDuration(currentAudioBuffer);
                audioPosition = CMTimeAdd(CMSampleBufferGetPresentationTimeStamp(currentAudioBuffer), CMTimeMultiplyByFloat64(duration, currentAudioBufferPos/totalAudioSize));
                currentAudioBufferPos = usedAudioSize;
                
                CFRelease(buffer);
                if (usedAudioSize == totalAudioSize) {
                    currentAudioBufferPos = 0;
                    CFRelease(currentAudioBuffer);
                    currentAudioBuffer = nil;
                }
            } else {
                memset(outData, 0, numFrames * numChannels * sizeof(SInt16));
                break;
            }
        }
        
        [bufferlock unlock];
    }
    
    CGFloat progress = CMTimeGetSeconds(audioPosition) / CMTimeGetSeconds(self.duration);
    if (completion) {
        audioPosition = self.duration;
        progress = 1;
    }
    lastProgress = progress;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.playerStateDelegate respondsToSelector:@selector(progressDidChange:)]) {
            [self.playerStateDelegate progressDidChange:progress];
        }
    });
}

- (void)checkPlayState;
{
    if (NULL == decoder) {
        return;
    }
    const NSUInteger leftAudioFrames = audioBuffers.count;
    if (leftAudioFrames == 0 && currentAudioBuffer == nil && decoder.isEOF) {
        completion = true;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self->_playerStateDelegate && [self->_playerStateDelegate respondsToSelector:@selector(onCompletion)]){
                [self->_playerStateDelegate onCompletion];
            }
        });
        return;
    }
    
    if (buffering && ((bufferedDuration > minBufferedDuration) || decoder.isEOF)) {
        buffering = false;
        bufferedBeginTime = -1;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self->_playerStateDelegate && [self->_playerStateDelegate respondsToSelector:@selector(bufferLoadingDidEnd)]){
                [self->_playerStateDelegate bufferLoadingDidEnd];
            }
        });
    }
    if (leftAudioFrames == 0 && !decoder.isEOF) {
        if (!buffering) {
            if (isStopDecoding) {
                NSLog(@"buffering When isStopDecoding");
            }
            buffering = true;
            bufferedBeginTime = [[NSDate date] timeIntervalSince1970];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self->_playerStateDelegate && [self->_playerStateDelegate respondsToSelector:@selector(bufferLoadingWillBegin)]){
                    [self->_playerStateDelegate bufferLoadingWillBegin];
                }
            });
        } else {
            NSTimeInterval bufferedTotalTime = [[NSDate date] timeIntervalSince1970] - bufferedBeginTime;
            if (bufferedBeginTime != -1 && bufferedTotalTime > TIMEOUT_BUFFER) {
                bufferedBeginTime = -1;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self->_playerStateDelegate && [self->_playerStateDelegate respondsToSelector:@selector(bufferLoadingTimeout)]){
                        [self->_playerStateDelegate bufferLoadingTimeout];
                    }
                });
            }
        }
    }
    
    if (!isDecodingFirstBuffer && (!(bufferedDuration > minBufferedDuration))) {
        [self resumeDecoderThread];
    }
}

#pragma mark - Seek Time

- (void)seekToTime:(CMTime)time isLast:(BOOL)isLast completion:(void(^)(CMSampleBufferRef))completion {
    
    if (CMTIME_COMPARE_INLINE(time, <, kCMTimeZero)) {
        time = kCMTimeZero;
    }
    if (CMTIME_COMPARE_INLINE(time, >, self.duration)) {
        time = self.duration;
    }
    
    NSTimeInterval currSeekTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval currSeekVideoTime = CMTimeGetSeconds(time);
    if (!isLast && ((currSeekTime - lastSeekTime) < minSeekTimeInterval || fabs(currSeekVideoTime - lastSeekVideoTime) < minSeekVideoTimeInterval)) {
        completion(nil);
        return;
    }
    lastSeekTime = currSeekTime;
    lastSeekVideoTime = currSeekVideoTime;

    if (isLast) {
        [seekOperationQueue cancelAllOperations];
        lastSeekTime = 0;
        lastSeekVideoTime = 0;
    }
    __weak typeof(self) wself = self;
    [seekOperationQueue addOperationWithBlock:^{
        __strong typeof(wself) self = wself;
        [self removeAllBuffer];
        [self->decoder seekToTime:time];
        [self waitForNewDecodedData];
        
        [self->bufferlock lock];
        CMSampleBufferRef sample = (CMSampleBufferRef)CFBridgingRetain(self->videoBuffers.firstObject);
        [self->bufferlock unlock];
        
        self->audioPosition = time;
        self->completion = false;
        completion(sample);
    }];
}

- (void)waitForNewDecodedData {
    //必须唤醒解码线程
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.1);
    do{
        self->newDataSemaphore = dispatch_semaphore_create(0);
        [self resumeDecoderThread];
    } while (dispatch_semaphore_wait(self->newDataSemaphore, time) != 0);
}

#pragma mark - Accessor

- (BOOL)isPlayCompleted;
{
    return completion;
}

- (CMTime)currentTime {
//    if (currentAudioBuffer) {
//        return CMSampleBufferGetPresentationTimeStamp(currentAudioBuffer);
//    }
    return audioPosition;
}

- (CMTime)duration
{
    if (decoder) {
        return [decoder duration];
    }
    return kCMTimeZero;
}


- (NSInteger)sampleRate {
    if (decoder) {
        return [decoder sampleRate];
    }
    return 0;
}

- (NSUInteger)channels {
    if (decoder) {
        return [decoder channels];
    }
    return 0;
}

- (CGFloat)orientation {
    if (decoder) {
        return [decoder orientation];
    }
    return 0;
}

- (void)dealloc;
{
    [self closeFile];
    NSLog(@"HPPlayerSynchronizer Dealloc...");
}
@end
