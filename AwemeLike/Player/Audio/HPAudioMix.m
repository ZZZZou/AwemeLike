//
//  HPAudioMix.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/15.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import "ELAudioSession.h"
#import "HPAudioMix.h"

static OSStatus InputRenderCallback(void *inRefCon,
                                    AudioUnitRenderActionFlags *ioActionFlags,
                                    const AudioTimeStamp *inTimeStamp,
                                    UInt32 inBusNumber,
                                    UInt32 inNumberFrames,
                                    AudioBufferList *ioData);
static void CheckStatus(OSStatus status, NSString *message, BOOL fatal);


@interface HPAudioMix()
{
    void *inputAudioData;
    AudioFileID musicFileID;
}

@property(nonatomic, assign) Float64 sampleRate;
@property(nonatomic, assign) Float64 channels;

@property(nonatomic, assign) AUGraph auGraph;
@property(nonatomic, assign) AUNode musicFileNode;
@property(nonatomic, assign) AudioUnit musicFileUnit;
@property(nonatomic, assign) AUNode mixerNode;
@property(nonatomic, assign) AudioUnit mixerUnit;
@property(nonatomic, assign) AUNode c16iTo32fNode;
@property(nonatomic, assign) AudioUnit c16iTo32fUnit;

@property(nonatomic, assign) AUNode c32fTo16iNode;
@property(nonatomic, assign) AudioUnit c32fTo16iUnit;

@property(nonatomic, assign) AUNode genericNode;
@property(nonatomic, assign) AudioUnit genericUnit;

@property(nonatomic, assign) AudioStreamBasicDescription clientFormat32float;
@property(nonatomic, assign) AudioStreamBasicDescription clientFormat16int;
@end
@implementation HPAudioMix

- (id)initWithChannels:(NSInteger)channels sampleRate:(NSInteger)sampleRate {
    
    self = [super init];
    if (self) {
        [[ELAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord];
        [[ELAudioSession sharedInstance] setPreferredSampleRate:sampleRate];
        [[ELAudioSession sharedInstance] setActive:YES];
        [[ELAudioSession sharedInstance] addRouteChangeListener];
        //        [self addAudioSessionInterruptedObserver];
        _sampleRate = sampleRate;
        _channels = channels;
        
        [self configPCMDataFromat];
        [self createAudioUnitGraph];
    }
    return self;
}

- (id)initWithChannels:(NSInteger)channels sampleRate:(NSInteger)sampleRate musicFile:(NSString *)filePath {
    self = [self initWithChannels:channels sampleRate:sampleRate];
    if (self) {
        OSStatus status = noErr;
        CFURLRef songURL = (__bridge  CFURLRef)[NSURL URLWithString:filePath];;
        status = AudioFileOpenURL(songURL, kAudioFileReadPermission, 0, &musicFileID);
        CheckStatus(status, @"Open AudioFile... ", YES);
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
    clientFormat16int.mSampleRate = sampleRate;
    clientFormat16int.mFormatID = kAudioFormatLinearPCM;
    clientFormat16int.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    clientFormat16int.mBitsPerChannel = 8 * bytesPerSample;
    clientFormat16int.mBytesPerFrame= bytesPerSample * channels;
    clientFormat16int.mBytesPerPacket = bytesPerSample * channels;
    clientFormat16int.mFramesPerPacket = 1;
    clientFormat16int.mChannelsPerFrame = channels;
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
    status = AUGraphAddNode(_auGraph, &description, &_c16iTo32fNode);
    CheckStatus(status, @"Could not add Convert node to AUGraph", YES);
    
    bzero(&description, sizeof(description));
    description.componentManufacturer = kAudioUnitManufacturer_Apple;
    description.componentType = kAudioUnitType_Output;
    description.componentSubType = kAudioUnitSubType_GenericOutput;
    status = AUGraphAddNode(_auGraph, &description, &_genericNode);
    CheckStatus(status, @"Could not add I/O node to AUGraph", YES);
    
    
    bzero(&description, sizeof(description));
    description.componentManufacturer = kAudioUnitManufacturer_Apple;
    description.componentType = kAudioUnitType_FormatConverter;
    description.componentSubType = kAudioUnitSubType_AUConverter;
    status = AUGraphAddNode(_auGraph, &description, &_c32fTo16iNode);
    CheckStatus(status, @"Could not add Convert node to AUGraph", YES);
    
}

- (void)getUnitsFromNodes {
    
    OSStatus status = noErr;
    
    status = AUGraphNodeInfo(_auGraph, _musicFileNode, NULL, &_musicFileUnit);
    CheckStatus(status, @"Could not retrieve node info for music file node", YES);
    
    status = AUGraphNodeInfo(_auGraph, _mixerNode, NULL, &_mixerUnit);
    CheckStatus(status, @"Could not retrieve node info for mixer node", YES);
    
    status = AUGraphNodeInfo(_auGraph, _c16iTo32fNode, NULL, &_c16iTo32fUnit);
    CheckStatus(status, @"Could not retrieve node info for Convert node", YES);
    
    status = AUGraphNodeInfo(_auGraph, _genericNode, NULL, &_genericUnit);
    CheckStatus(status, @"Could not retrieve node info for I/O node", YES);
    
    
    status = AUGraphNodeInfo(_auGraph, _c32fTo16iNode, NULL, &_c32fTo16iUnit);
    CheckStatus(status, @"Could not retrieve node info for Convert node", YES);
    
}

- (void)setAudioUnitProperties {
    
    OSStatus status = noErr;
    
    status = AudioUnitSetProperty(_musicFileUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &_clientFormat32float, sizeof(_clientFormat32float));
    
    status = AudioUnitSetProperty(_mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &_clientFormat32float, sizeof(_clientFormat32float));
    UInt32 busCount = 2;
    AudioUnitSetProperty(_mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &busCount, sizeof(busCount));
    
    status = AudioUnitSetProperty(_c16iTo32fUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &_clientFormat16int, sizeof(_clientFormat16int));
    CheckStatus(status, @"augraph recorder normal unit set client format error", YES);
    status = AudioUnitSetProperty(_c16iTo32fUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &_clientFormat32float, sizeof(_clientFormat32float));
    CheckStatus(status, @"augraph recorder normal unit set client format error", YES);
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = &InputRenderCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)self;
    status = AudioUnitSetProperty(_c16iTo32fUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackStruct, sizeof(callbackStruct));
    CheckStatus(status, @"Could not set render callback on mixer input scope, element 1", YES);
    
    // spectial format for converter
    status = AudioUnitSetProperty(_c32fTo16iUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &_clientFormat32float, sizeof(_clientFormat32float));
    CheckStatus(status, @"augraph recorder normal unit set client format error", YES);
    status = AudioUnitSetProperty(_c32fTo16iUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &_clientFormat16int, sizeof(_clientFormat16int));
    CheckStatus(status, @"augraph recorder normal unit set client format error", YES);
    
    status = AudioUnitSetProperty(_genericUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &_clientFormat16int, sizeof(_clientFormat16int));
    CheckStatus(status, @"augraph recorder normal unit set client format error", YES);
    
}

/*
 videoFile(RenderCall) -> convertNode_16iTo32f ->
                                                 \
                                                    -> mixer -> convertNode_32fTo16i -> GenericOutput
                                                 /
                                     musicNode ->
 */
- (void)makeNodeConnections {
    OSStatus status = noErr;
    
    status = AUGraphConnectNodeInput(_auGraph, _c16iTo32fNode, 0, _mixerNode, 0);
    CheckStatus(status, @"Could not connect I/O node input to mixer node input", YES);
    
    //music file input
    status = AUGraphConnectNodeInput(_auGraph, _musicFileNode, 0, _mixerNode, 1);
    CheckStatus(status, @"Could not connect I/O node input to mixer node input", YES);
    
    
    //output
    status = AUGraphConnectNodeInput(_auGraph, _mixerNode, 0, _c32fTo16iNode, 0);
    CheckStatus(status, @"Could not connect I/O node input to mixer node input", YES);
    
    //output
    status = AUGraphConnectNodeInput(_auGraph, _c32fTo16iNode, 0, _genericNode, 0);
    CheckStatus(status, @"Could not connect I/O node input to mixer node input", YES);
}


#pragma mark - Control

- (void)setVolumeValue:(AudioUnitParameterValue)value forInput:(AudioUnitElement)inputNum {
    AudioUnitSetParameter(_mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, inputNum, value, 0);
}

- (void)destroyAudioUnitGraph {
    
    AUGraphStop(_auGraph);
    
    AUGraphUninitialize(_auGraph);
    AUGraphClose(_auGraph);
    AUGraphRemoveNode(_auGraph, _genericNode);
    DisposeAUGraph(_auGraph);
    _genericUnit = NULL;
    _genericNode = 0;
    _auGraph = NULL;
}

- (void)dealloc {
    [self destroyAudioUnitGraph];
}

- (void)setMusicFileOffset:(CGFloat)timeOffset {
    AudioFileID musicFile = musicFileID;
    OSStatus status;
    
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
    status = AudioFileGetProperty(musicFile, kAudioFilePropertyAudioDataPacketCount,
                                  &propsize, &nPackets);
    CheckStatus(status, @"get the Audio Data Packet Count... ", YES);
    // tell the file player AU to play the entire file
    ScheduledAudioFileRegion rgn;
    memset (&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
    rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    rgn.mTimeStamp.mSampleTime = 0;
    rgn.mCompletionProc = NULL;
    rgn.mCompletionProcUserData = NULL;
    rgn.mAudioFile = musicFile;
    rgn.mLoopCount = 0;
    rgn.mStartFrame = (SInt64)(timeOffset * fileASBD.mSampleRate);;
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

- (OSStatus)renderData:(AudioBufferList *)ioData
           atTimeStamp:(const AudioTimeStamp *)timeStamp
            forElement:(UInt32)element
          numberFrames:(UInt32)numFrames
                 flags:(AudioUnitRenderActionFlags *)flags {
    
    UInt32 length = ioData->mBuffers[0].mDataByteSize;
    memcpy(ioData->mBuffers[0].mData, inputAudioData, length);
    return noErr;
}

/**
    audioData‘s format is Sint16，Packed
 */
- (void)mixAudioData:(SInt16 *)audioData numAudioFrame:(NSUInteger)numAudioFrame {
    
    UInt32 maxInNumberFrames;
    UInt32 size = sizeof(maxInNumberFrames);
    AudioUnitGetProperty(_genericUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxInNumberFrames, &size);
    
    AudioTimeStamp inTimeStamp;
    memset(&inTimeStamp, 0, sizeof(inTimeStamp));
    inTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    inTimeStamp.mSampleTime = 0;
    
    UInt32 channelCount = self.channels;
    UInt32 bytesPerFrame = sizeof(SInt16) * channelCount;
    AudioBufferList *bufferlist = (AudioBufferList*)malloc(sizeof(AudioBufferList));
    bufferlist->mNumberBuffers = 1;
    AudioBuffer buffer = {0};
    buffer.mNumberChannels = channelCount;
    buffer.mDataByteSize = maxInNumberFrames * bytesPerFrame;
    buffer.mData = (void*)calloc(maxInNumberFrames, bytesPerFrame);
    bufferlist->mBuffers[0] = buffer;
    
    NSUInteger totalFrames = numAudioFrame;
    UInt32 offset = 0;
    while (totalFrames > 0) {
        NSUInteger inNumberFrames = 0;
        if (totalFrames < maxInNumberFrames) {
            inNumberFrames = totalFrames;
        } else {
            inNumberFrames = maxInNumberFrames;
        }
        totalFrames -= inNumberFrames;

        inputAudioData = (void*)audioData + offset*bytesPerFrame;
        inTimeStamp.mSampleTime = offset;
        AudioUnitRenderActionFlags flags = 0;
        OSStatus status = AudioUnitRender(_genericUnit, &flags, &inTimeStamp, 0, (UInt32)inNumberFrames, bufferlist);
        CheckStatus(status, @"Could not AudioUnitRender", YES);
        
        long data = *(long*)(bufferlist->mBuffers[0].mData);
        if (data != *(long*)(inputAudioData)) {
            NSLog(@"Changed");
        } else {
            NSLog(@"Not Changed");
        }
        memcpy((void *)inputAudioData, bufferlist->mBuffers[0].mData, inNumberFrames * bytesPerFrame);
        offset += inNumberFrames;
    }
    
    free(bufferlist->mBuffers[0].mData);
    free(bufferlist);
}

- (void)start {
    
    [self setVolumeValue:self.originVolume forInput:0];
    [self setVolumeValue:self.musicVolume forInput:1];
    
    [self setMusicFileOffset:0];
    
    OSStatus status = AUGraphStart(_auGraph);
    CheckStatus(status, @"Could not start AUGraph", YES);
}

- (void)stop {
    OSStatus status = AUGraphStop(_auGraph);
    CheckStatus(status, @"Could not stop AUGraph", YES);
}

@end

static OSStatus InputRenderCallback(void *inRefCon,
                                    AudioUnitRenderActionFlags *ioActionFlags,
                                    const AudioTimeStamp *inTimeStamp,
                                    UInt32 inBusNumber,
                                    UInt32 inNumberFrames,
                                    AudioBufferList *ioData) {
    HPAudioMix *audioMix = (__bridge id)inRefCon;
    return [audioMix renderData:ioData
                       atTimeStamp:inTimeStamp
                        forElement:inBusNumber
                      numberFrames:inNumberFrames
                             flags:ioActionFlags];
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
