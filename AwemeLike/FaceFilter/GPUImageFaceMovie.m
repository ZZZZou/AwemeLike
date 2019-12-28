//
//  GPUImageFaceMovie.m
//  AwemeLike
//
//  Created by w22543 on 2019/11/25.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "GPUImageMovieWriter.h"
#import "FaceDetector.h"
#import "GPUImageFaceMovie.h"

@interface GPUImageFaceMovie()
@end
@implementation GPUImageFaceMovie

- (AVAssetReader*)createAssetReader {
    NSError *error = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:self.asset error:&error];
    
    NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
    [outputSettings setObject:@(kCVPixelFormatType_32BGRA) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    // Maybe set alwaysCopiesSampleData to NO on iOS 5.0 for faster video decoding
    AVAssetReaderTrackOutput *readerVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[[self.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] outputSettings:outputSettings];
    readerVideoTrackOutput.alwaysCopiesSampleData = NO;
    [assetReader addOutput:readerVideoTrackOutput];
    
    NSArray *audioTracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
    BOOL shouldRecordAudioTrack = (([audioTracks count] > 0) && (self.audioEncodingTarget != nil) );
    AVAssetReaderTrackOutput *readerAudioTrackOutput = nil;
    
    if (shouldRecordAudioTrack)
    {
        [self.audioEncodingTarget setShouldInvalidateAudioSampleWhenDone:YES];
        
        NSMutableDictionary *setting = @{AVFormatIDKey: @(kAudioFormatLinearPCM), AVLinearPCMIsFloatKey: @(false), AVLinearPCMBitDepthKey: @(16), AVLinearPCMIsNonInterleaved: @(false), AVLinearPCMIsBigEndianKey: @(false)}.mutableCopy;
        if (self.sampleRate) {
            setting[AVSampleRateKey] = @(self.sampleRate);
        }
        if (self.channels) {
            setting[AVNumberOfChannelsKey] = @(self.channels);
        }
        
        AVAssetTrack* audioTrack = [audioTracks objectAtIndex:0];
        readerAudioTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:setting];
        readerAudioTrackOutput.alwaysCopiesSampleData = NO;
        [assetReader addOutput:readerAudioTrackOutput];
    }
    
    [self setupFaceDetector];
    return assetReader;
}

- (void)processMovieFrame:(CVPixelBufferRef)movieFrame withSampleTime:(CMTime)currentSampleTime
{
    int bufferHeight = (int) CVPixelBufferGetHeight(movieFrame);
    int bufferWidth = (int) CVPixelBufferGetWidth(movieFrame);
    
    [GPUImageContext useImageProcessingContext];
    
    CVPixelBufferLockBaseAddress(movieFrame, 0);
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(bufferWidth, bufferHeight) textureOptions:self.outputTextureOptions onlyTexture:YES];
    
    glBindTexture(GL_TEXTURE_2D, [outputFramebuffer texture]);
    
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 self.outputTextureOptions.internalFormat,
                 bufferWidth,
                 bufferHeight,
                 0,
                 self.outputTextureOptions.format,
                 self.outputTextureOptions.type,
                 CVPixelBufferGetBaseAddress(movieFrame));
    
    for (id<GPUImageInput> currentTarget in targets)
    {
        NSInteger indexOfObject = [targets indexOfObject:currentTarget];
        NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
        [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight) atIndex:targetTextureIndex];
        [currentTarget setInputFramebuffer:outputFramebuffer atIndex:targetTextureIndex];
    }
    
    [outputFramebuffer unlock];
    
    for (id<GPUImageInput> currentTarget in targets)
    {
        NSInteger indexOfObject = [targets indexOfObject:currentTarget];
        NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
        [currentTarget newFrameReadyAtTime:currentSampleTime atIndex:targetTextureIndex];
    }
    CVPixelBufferUnlockBaseAddress(movieFrame, 0);
}

- (void)processMovieFrame:(CMSampleBufferRef)movieSampleBuffer {
    [self faceDetect:movieSampleBuffer];
    [super processMovieFrame:movieSampleBuffer];
}

- (void)setupFaceDetector {
    NSInteger orientation = self.orientation;
    FaceDetectorSampleBufferOrientation sampleOrientation = FaceDetectorSampleBufferOrientationNoRatation;
    if (orientation == 90) {
        sampleOrientation = FaceDetectorSampleBufferOrientationRatation90;
    } else if (orientation == 180) {
        sampleOrientation = FaceDetectorSampleBufferOrientationRatation180;
    } else if (orientation == 270) {
        sampleOrientation = FaceDetectorSampleBufferOrientationRatation270;
    }
    [FaceDetector shareInstance].sampleBufferOrientation = sampleOrientation;
    [FaceDetector shareInstance].faceOrientation = (int)orientation;
    [FaceDetector shareInstance].sampleType = FaceDetectorSampleTypeMovieFile;
    [[FaceDetector shareInstance] auth];
}


- (void)faceDetect:(CMSampleBufferRef)sampleBuffer {
    if (![FaceDetector shareInstance].isWorking) {
        CMSampleBufferRef detectSampleBufferRef = NULL;
        CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &detectSampleBufferRef);
        [[FaceDetector shareInstance] getLandmarksFromSampleBuffer:detectSampleBufferRef];
        CFRelease(detectSampleBufferRef);
    }
}

- (NSInteger)orientation {
    NSInteger degree = 0;
    NSArray *tracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
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
    return degree;
}

@end
