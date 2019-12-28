//
//  HPAudioMix.h
//  AwemeLike
//
//  Created by w22543 on 2019/11/15.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>

@interface HPAudioMix : NSObject

@property (nonatomic, assign) Float32 originVolume;
@property (nonatomic, assign) Float32 musicVolume;
//origin's channels and sampleRate
- (id)initWithChannels:(NSInteger)channels sampleRate:(NSInteger)sampleRate musicFile:(NSString *)filePath;
- (void)start;
- (void)stop;
- (void)mixAudioData:(SInt16 *)audioData numAudioFrame:(NSUInteger)numAudioFrame;
@end

