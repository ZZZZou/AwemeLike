//
//  HPPlayerViewController.h
//  AwemeLike
//
//  Created by w22543 on 2019/10/9.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "GPUImage.h"
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HPPlayerSeekTimeStatus) {
    HPPlayerSeekTimeStatusBegin,
    HPPlayerSeekTimeStatusUpdate,
    HPPlayerSeekTimeStatusEnd,
};

@protocol PlayerStateDelegate <NSObject>

@optional

- (void)openFileSucceed;

- (void)openFileFail;

- (void)progressDidChange:(CGFloat)progress;

- (void)bufferLoadingWillBegin;

- (void)bufferLoadingDidEnd;

- (void)bufferLoadingTimeout;

- (void)onCompletion;

@end

@interface HPPlayer : NSObject

- (instancetype)initWithFilePath:(NSString *)path preview:(UIView *)preview playerStateDelegate:(id<PlayerStateDelegate>)delegate;
- (instancetype)initWithFilePath:(NSString *)path playerStateDelegate:(id<PlayerStateDelegate>)delegate;

@property (nonatomic, strong) UIView *preview;

@property(nonatomic, copy) NSArray<GPUImageOutput<GPUImageInput> *> *filters;
@property (nonatomic, copy) NSString *musicFilePath;
@property(nonatomic, assign) BOOL shouldRepeat;
@property(nonatomic, assign) BOOL enableFaceDetector;

- (CMTime)currentTime;
- (CMTime)duration;
- (NSInteger)sampleRate;
- (NSUInteger)channels;

- (void)play;
- (void)pause;
- (BOOL)isPlaying;
- (void)playWithMusic:(NSString *)musicFilePath;

- (CGFloat)musicVolume;
- (CGFloat)originVolume;
- (void)changeVolume:(CGFloat)volume isMusic:(CGFloat)isMusic;

- (void)seekToTime:(CMTime)time;
- (void)seekToTime:(CMTime)time status:(HPPlayerSeekTimeStatus)status;

@end
