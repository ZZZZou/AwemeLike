//
//  HPAudioOutput.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/15.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPAudioOutput.h"
#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>
#import "ELAudioSession.h"

static OSStatus InputRenderCallback(void *inRefCon,
                                    AudioUnitRenderActionFlags *ioActionFlags,
                                    const AudioTimeStamp *inTimeStamp,
                                    UInt32 inBusNumber,
                                    UInt32 inNumberFrames,
                                    AudioBufferList *ioData);
static OSStatus mixerRenderNotify(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData);
static void CheckStatus(OSStatus status, NSString *message, BOOL fatal);

@interface HPAudioOutput(){
    SInt16* _outData;
}

@property(nonatomic, assign) Float64 sampleRate;
@property(nonatomic, assign) Float64 channels;

@property(nonatomic, assign) AUGraph auGraph;

@property (readwrite, weak) id<FillDataDelegate> fillAudioDataDelegate;
@property(nonatomic, assign) NSString *musicFilePath;

@property(nonatomic, assign) AUNode musicFileNode;
@property(nonatomic, assign) AudioUnit musicFileUnit;
@property(nonatomic, assign) AUNode mixerNode;
@property(nonatomic, assign) AudioUnit mixerUnit;
@property(nonatomic, assign) AUNode convertNode;
@property(nonatomic, assign) AudioUnit convertUnit;
@property(nonatomic, assign) AUNode ioNode;
@property(nonatomic, assign) AudioUnit ioUnit;

@property(nonatomic, assign) AudioStreamBasicDescription clientFormat32float;
@property(nonatomic, assign) AudioStreamBasicDescription clientFormat16int;
@end

@implementation HPAudioOutput

- (id)initWithChannels:(NSInteger)channels sampleRate:(NSInteger)sampleRate filleDataDelegate:(id<FillDataDelegate>)fillAudioDataDelegate {
    
    self = [super init];
    if (self) {
        [[ELAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord];
        [[ELAudioSession sharedInstance] setPreferredSampleRate:sampleRate];
        [[ELAudioSession sharedInstance] setActive:YES];
        [[ELAudioSession sharedInstance] addRouteChangeListener];
//        [self addAudioSessionInterruptedObserver];
        _outData = (SInt16 *)calloc(8192, sizeof(SInt16));
        _fillAudioDataDelegate = fillAudioDataDelegate;
        _sampleRate = sampleRate;
        _channels = channels;
        
        [self configPCMDataFromat];
        [self createAudioUnitGraph];
    }
    return self;
}

- (void)configPCMDataFromat {
    
    Float64 sampleRate = _sampleRate;
    UInt32 channels = _channels;
    UInt32 bytesPerSample = sizeof(Float32);
    
    AudioStreamBasicDescription clientFormat32float;
    bzero(&clientFormat32float, sizeof(clientFormat32float));
    clientFormat32float.mSampleRate = sampleRate;
    clientFormat32float.mFormatID = kAudioFormatLinearPCM;
    clientFormat32float.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    clientFormat32float.mBitsPerChannel = 8 * bytesPerSample;
    clientFormat32float.mBytesPerFrame = bytesPerSample;
    clientFormat32float.mBytesPerPacket = bytesPerSample;
    clientFormat32float.mFramesPerPacket = 1;
    clientFormat32float.mChannelsPerFrame = channels;
    self.clientFormat32float = clientFormat32float;
    
    bytesPerSample = sizeof(SInt16);
    AudioStreamBasicDescription clientFormat16int;
    bzero(&clientFormat16int, sizeof(clientFormat16int));
    clientFormat16int.mFormatID = kAudioFormatLinearPCM;
    clientFormat16int.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    clientFormat16int.mBytesPerPacket = bytesPerSample * channels;
    clientFormat16int.mFramesPerPacket = 1;
    clientFormat16int.mBytesPerFrame= bytesPerSample * channels;
    clientFormat16int.mChannelsPerFrame = channels;
    clientFormat16int.mBitsPerChannel = 8 * bytesPerSample;
    clientFormat16int.mSampleRate = sampleRate;
    self.clientFormat16int = clientFormat16int;
}

- (void)createAudioUnitGraph {
    
    OSStatus status = noErr;
    
    status = NewAUGraph(&_auGraph);
    CheckStatus(status, @"Could not create a new AUGraph", YES);
    
    [self addAudioUnitNodes];
    
    status = AUGraphOpen(_auGraph);
    CheckStatus(status, @"Could not open AUGraph", YES);
    
    [self getUnitsFromNodes];
    
    [self setAudioUnitProperties];
    
    [self makeNodeConnections];
    
    CAShow(_auGraph);
    
    status = AUGraphInitialize(_auGraph);
    CheckStatus(status, @"Could not initialize AUGraph", YES);
}

- (void)addAudioUnitNodes {
    
    OSStatus status = noErr;
    AudioComponentDescription description;
    
    bzero(&description, sizeof(description));
    description.componentManufacturer = kAudioUnitManufacturer_Apple;
    description.componentType = kAudioUnitType_Generator;
    description.componentSubType = kAudioUnitSubType_AudioFilePlayer;
    status = AUGraphAddNode(_auGraph, &description, &_musicFileNode);
    CheckStatus(status, @"Could not add Player node to AUGraph", YES);
    
    bzero(&description, sizeof(description));
    description.componentManufacturer = kAudioUnitManufacturer_Apple;
    description.componentType = kAudioUnitType_Mixer;
    description.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    status = AUGraphAddNode(_auGraph, &description, &_mixerNode);
    CheckStatus(status, @"Could not add VocalMixer node to AUGraph", YES);
    
    bzero(&description, sizeof(description));
    description.componentManufacturer = kAudioUnitManufacturer_Apple;
    description.componentType = kAudioUnitType_FormatConverter;
    description.componentSubType = kAudioUnitSubType_AUConverter;
    status = AUGraphAddNode(_auGraph, &description, &_convertNode);
    CheckStatus(status, @"Could not add Convert node to AUGraph", YES);
    
    bzero(&description, sizeof(description));
    description.componentManufacturer = kAudioUnitManufacturer_Apple;
    description.componentType = kAudioUnitType_Output;
    description.componentSubType = kAudioUnitSubType_RemoteIO;
    status = AUGraphAddNode(_auGraph, &description, &_ioNode);
    CheckStatus(status, @"Could not add I/O node to AUGraph", YES);
    
}

- (void)getUnitsFromNodes {
    
    OSStatus status = noErr;
    
    status = AUGraphNodeInfo(_auGraph, _musicFileNode, NULL, &_musicFileUnit);
    CheckStatus(status, @"Could not retrieve node info for music file node", YES);
    
    status = AUGraphNodeInfo(_auGraph, _mixerNode, NULL, &_mixerUnit);
    CheckStatus(status, @"Could not retrieve node info for mixer node", YES);
    
    status = AUGraphNodeInfo(_auGraph, _convertNode, NULL, &_convertUnit);
    CheckStatus(status, @"Could not retrieve node info for Convert node", YES);
    
    status = AUGraphNodeInfo(_auGraph, _ioNode, NULL, &_ioUnit);
    CheckStatus(status, @"Could not retrieve node info for I/O node", YES);

}

- (void)setAudioUnitProperties {
    
    OSStatus status = noErr;
    
    status = AudioUnitSetProperty(_musicFileUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &_clientFormat32float, sizeof(_clientFormat32float));
    status = AudioUnitSetProperty(_mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &_clientFormat32float, sizeof(_clientFormat32float));
    
    // spectial format for converter
    status = AudioUnitSetProperty(_convertUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &_clientFormat16int, sizeof(_clientFormat16int));
    CheckStatus(status, @"augraph recorder normal unit set client format error", YES);
    status = AudioUnitSetProperty(_convertUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &_clientFormat32float, sizeof(_clientFormat32float));
    CheckStatus(status, @"augraph recorder normal unit set client format error", YES);
    
    //audio file input
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = &InputRenderCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)self;
    
    status = AudioUnitSetProperty(_convertUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackStruct, sizeof(callbackStruct));
    CheckStatus(status, @"Could not set render callback on mixer input scope, element 1", YES);
    
    //audio data output notify
    AudioUnitAddRenderNotify(_mixerUnit, &mixerRenderNotify, (__bridge void *)self);
    
}

/*
AURenderCallback --> convertNode_16iTo32f -->
                                              \
                                                 --> mixerNode --> IONode
                                              /
                  AudioFile --> musicNode -->
 */
- (void)makeNodeConnections {
    OSStatus status = noErr;
    
    status = AUGraphConnectNodeInput(_auGraph, _convertNode, 0, _mixerNode, 0);
    CheckStatus(status, @"Could not connect I/O node input to mixer node input", YES);
    
    //music file input
    status = AUGraphConnectNodeInput(_auGraph, _musicFileNode, 0, _mixerNode, 1);
    CheckStatus(status, @"Could not connect I/O node input to mixer node input", YES);
    
    //output
    status = AUGraphConnectNodeInput(_auGraph, _mixerNode, 0, _ioNode, 0);
    CheckStatus(status, @"Could not connect I/O node input to mixer node input", YES);
}

- (void)setUpMusicFile:(NSString *)filePath startOffset:(NSTimeInterval)startOffset
{
    OSStatus status = noErr;
    AudioFileID musicFile;
    CFURLRef songURL = (__bridge  CFURLRef)[NSURL URLWithString:filePath];;
    // open the input audio file
    status = AudioFileOpenURL(songURL, kAudioFileReadPermission, 0, &musicFile);
    CheckStatus(status, @"Open AudioFile... ", YES);
    
    // tell the file player unit to load the file we want to play
    status = AudioUnitSetProperty(_musicFileUnit, kAudioUnitProperty_ScheduledFileIDs,
                                  kAudioUnitScope_Global, 0, &musicFile, sizeof(musicFile));
    CheckStatus(status, @"Tell AudioFile Player Unit Load Which File... ", YES);
    
    AudioStreamBasicDescription fileASBD;
    // get the audio data format from the file
    UInt32 propSize = sizeof(fileASBD);
    status = AudioFileGetProperty(musicFile, kAudioFilePropertyDataFormat, &propSize, &fileASBD);
    CheckStatus(status, @"get the audio data format from the file... ", YES);
    UInt64 nPackets;
    UInt32 propsize = sizeof(nPackets);
    AudioFileGetProperty(musicFile, kAudioFilePropertyAudioDataPacketCount,
                         &propsize, &nPackets);
    // tell the file player AU to play the entire file
    ScheduledAudioFileRegion rgn;
    memset (&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
    rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    rgn.mTimeStamp.mSampleTime = 0;
    rgn.mCompletionProc = NULL;
    rgn.mCompletionProcUserData = NULL;
    rgn.mAudioFile = musicFile;
    rgn.mLoopCount = 0;
    rgn.mStartFrame = (SInt64)(startOffset * fileASBD.mSampleRate);;
    rgn.mFramesToPlay = MAX(1, (UInt32)nPackets * fileASBD.mFramesPerPacket - (UInt32)rgn.mStartFrame);
    status = AudioUnitSetProperty(_musicFileUnit, kAudioUnitProperty_ScheduledFileRegion,
                                  kAudioUnitScope_Global, 0,&rgn, sizeof(rgn));
    CheckStatus(status, @"Set Region... ", YES);
    
    // prime the file player AU with default values
    UInt32 defaultVal = 0;
    status = AudioUnitSetProperty(_musicFileUnit, kAudioUnitProperty_ScheduledFilePrime,
                                  kAudioUnitScope_Global, 0, &defaultVal, sizeof(defaultVal));
    CheckStatus(status, @"Prime Player Unit With Default Value... ", YES);
    
    // tell the file player AU when to start playing (-1 sample time means next render cycle)
    AudioTimeStamp startTime;
    memset (&startTime, 0, sizeof(startTime));
    startTime.mFlags = kAudioTimeStampSampleTimeValid;
    startTime.mSampleTime = -1;
    status = AudioUnitSetProperty(_musicFileUnit, kAudioUnitProperty_ScheduleStartTimeStamp,
                                  kAudioUnitScope_Global, 0, &startTime, sizeof(startTime));
    CheckStatus(status, @"set Player Unit Start Time... ", YES);
}

- (void)destroyAudioUnitGraph {
    
    AUGraphStop(_auGraph);
    
    AUGraphUninitialize(_auGraph);
    AUGraphClose(_auGraph);
    AUGraphRemoveNode(_auGraph, _ioNode);
    DisposeAUGraph(_auGraph);
    _ioUnit = NULL;
    _ioNode = 0;
    _auGraph = NULL;
}

- (OSStatus)renderData:(AudioBufferList *)ioData
           atTimeStamp:(const AudioTimeStamp *)timeStamp
            forElement:(UInt32)element
          numberFrames:(UInt32)numFrames
                 flags:(AudioUnitRenderActionFlags *)flags {
    @autoreleasepool {
        for (int iBuffer=0; iBuffer < ioData->mNumberBuffers; ++iBuffer) {
            memset(ioData->mBuffers[iBuffer].mData, 0, ioData->mBuffers[iBuffer].mDataByteSize);
        }
        if(_fillAudioDataDelegate)
        {
            [_fillAudioDataDelegate fillAudioData:_outData numFrames:numFrames numChannels:_channels];
            
            UInt32 offset = 0;
            for (int iBuffer=0; iBuffer < ioData->mNumberBuffers; ++iBuffer) {
                UInt32 length = ioData->mBuffers[iBuffer].mDataByteSize;
                memcpy((SInt16 *)ioData->mBuffers[iBuffer].mData, _outData + offset, length);
                offset += length;
            }
        }
        return noErr;
    }
}


#pragma mark - Control

- (void)play {
    OSStatus status = AUGraphStart(_auGraph);
    CheckStatus(status, @"Could not start AUGraph", YES);
}

- (void)stop {
    OSStatus status = AUGraphStop(_auGraph);
    CheckStatus(status, @"Could not stop AUGraph", YES);
}

- (void)playWithMusicFile:(NSString *)filePath startOffset:(NSTimeInterval)startOffset;{
    _musicFilePath = filePath;
    if (filePath.length) {
        [self setUpMusicFile:filePath startOffset:startOffset];
    }
    [self setMuted:!self.musicFilePath.length forInput:1];
    OSStatus status = AUGraphStart(_auGraph);
    CheckStatus(status, @"Could not start AUGraph", YES);
}

- (void)resumeMusicPlay {
    [self setMuted:true forInput:1];
}

- (void)pauseMusicPlay {
    [self setMuted:false forInput:1];
}

- (void)setOriginVolume:(Float32)originVolume {
    _originVolume = originVolume;
    [self setVolumeValue:originVolume forInput:0];
}

- (void)setMusicVolume:(Float32)musicVolume {
    _musicVolume = musicVolume;
    [self setVolumeValue:musicVolume forInput:1];
}

- (void)setMuted:(BOOL)muted forInput:(AudioUnitElement)inputNum {
    AudioUnitParameterValue isEnableValue = muted ? 0 : 1 ;
    AudioUnitSetParameter(_mixerUnit, kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, inputNum, isEnableValue, 0);
}

- (BOOL)isMutedForInput:(AudioUnitElement)inputNum {
    AudioUnitParameterValue value = 0;
    AudioUnitGetParameter(_mixerUnit, kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, inputNum, &value);
    return value == 1 ? false : true;
}

- (void)setVolumeValue:(AudioUnitParameterValue)value forInput:(AudioUnitElement)inputNum {
    AudioUnitSetParameter(_mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, inputNum, value, 0);
}

- (AudioUnitParameterValue)volumeForInput:(AudioUnitElement)inputNum {
    AudioUnitParameterValue value = 0;
    AudioUnitGetParameter(_mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, inputNum, &value);
    return value;
}


#pragma mark - Notification
// AudioSession 被打断的通知
//- (void)addAudioSessionInterruptedObserver {
//    [self removeAudioSessionInterruptedObserver];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationAudioInterrupted:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
//}
//
//- (void)removeAudioSessionInterruptedObserver {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
//}
//
//- (void)onNotificationAudioInterrupted:(NSNotification *)sender {
//    AVAudioSessionInterruptionType interruptionType = [[[sender userInfo] objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
//    switch (interruptionType) {
//        case AVAudioSessionInterruptionTypeBegan:
////            [self stop];
//            break;
//        case AVAudioSessionInterruptionTypeEnded:
////            [self play];
//            break;
//        default:
//            break;
//    }
//}

- (void)dealloc {
    if (_outData) {
        free(_outData);
        _outData = NULL;
    }
    [self destroyAudioUnitGraph];
//    [self removeAudioSessionInterruptedObserver];
}

@end

static OSStatus InputRenderCallback(void *inRefCon,
                                    AudioUnitRenderActionFlags *ioActionFlags,
                                    const AudioTimeStamp *inTimeStamp,
                                    UInt32 inBusNumber,
                                    UInt32 inNumberFrames,
                                    AudioBufferList *ioData) {
    HPAudioOutput *audioOutput = (__bridge id)inRefCon;
    return [audioOutput renderData:ioData
                       atTimeStamp:inTimeStamp
                        forElement:inBusNumber
                      numberFrames:inNumberFrames
                             flags:ioActionFlags];
}

static OSStatus mixerRenderNotify(void *                            inRefCon,
                                  AudioUnitRenderActionFlags *    ioActionFlags,
                                  const AudioTimeStamp *            inTimeStamp,
                                  UInt32                            inBusNumber,
                                  UInt32                            inNumberFrames,
                                  AudioBufferList *                ioData)
{
    __unsafe_unretained HPAudioOutput *self = (__bridge HPAudioOutput *)inRefCon;
    OSStatus result = noErr;
    if (*ioActionFlags & kAudioUnitRenderAction_PostRender) {
        
        if ([self.fillAudioDataDelegate respondsToSelector:@selector(recordDidReceiveAudioBuffer:)])
        {
            [self.fillAudioDataDelegate recordDidReceiveAudioBuffer:ioData];
        }
    }
    return result;
}

static void CheckStatus(OSStatus status, NSString *message, BOOL fatal) {
    if(status != noErr)
    {
        char fourCC[16];
        *(UInt32 *)fourCC = CFSwapInt32HostToBig(status);
        fourCC[4] = '\0';
        
        if(isprint(fourCC[0]) && isprint(fourCC[1]) && isprint(fourCC[2]) && isprint(fourCC[3]))
            NSLog(@"%@: %s", message, fourCC);
        else
            NSLog(@"%@: %d", message, (int)status);
        
        if(fatal)
            exit(-1);
    }
}
