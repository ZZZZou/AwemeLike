//
//  HPVideoDecoder.h
//  AwemeLike
//
//  Created by w22543 on 2019/10/9.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HPVideoDecoder : NSObject

@property(nonatomic, assign) CGFloat audioDuration;
@property(nonatomic, assign) CGFloat videoDuration;

- (id)initWithURL:(NSURL *)url;
- (BOOL)openFile;
/**
    [[audio], [video]]
 */
- (NSArray *)decodeSampleBuffers;
- (CMSampleBufferRef)decodeSingleVideoSampleBufferAtTime:(CMTime)time;

- (CMTime)seekToBegin;
- (CMTime)seekToTime:(CMTime)time;

/**
 0, 90. 180. 270, 逆时针
 */
- (CGFloat)orientation;
- (CMTime)duration;
- (NSUInteger)sampleRate;
- (NSUInteger)channels;
- (BOOL)isEOF;

@end

NS_ASSUME_NONNULL_END
