//
//  HPPlayerSynchronizer.h
//  AwemeLike
//
//  Created by apple on 16/8/25.
//  Copyright © 2016年 xiaokai.zhan. All rights reserved.
//

#import "HPPlayer.h"
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

#define TIMEOUT_DECODE_ERROR            20
#define TIMEOUT_BUFFER                  10

extern NSString * const kMIN_BUFFERED_DURATION;
extern NSString * const kMAX_BUFFERED_DURATION;

@interface HPPlayerSynchronizer : NSObject

@property (nonatomic, weak) id<PlayerStateDelegate> playerStateDelegate;

- (id)initWithPlayerStateDelegate:(id<PlayerStateDelegate>)playerStateDelegate;
- (BOOL)openFile:(NSString *)path;
- (void)closeFile;

- (void)audioCallbackFillData:(SInt16 *)outData
                     numFrames:(UInt32)numFrames
                   numChannels:(UInt32)numChannels;
- (CMSampleBufferRef)getCorrectVideoSampleBuffer;

- (void)seekToTime:(CMTime)time isLast:(BOOL)isLast completion:(void(^)(CMSampleBufferRef))completion;

- (CMTime)duration;
- (CMTime)currentTime;
- (NSInteger)sampleRate;
- (NSUInteger)channels;
- (CGFloat)orientation;
- (BOOL)isPlayCompleted;

@end
