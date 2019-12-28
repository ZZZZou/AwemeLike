//
//  HPVideoOutput.m
//  AwemeLike
//
//  Created by w22543 on 2019/10/11.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "GPUImageRotateFilter.h"
#import "FaceDetector.h"
#import "HPVideoOutput.h"

@implementation GPUImageRawDataInput (FixBug)

- (void)processDataForTimestamp:(CMTime)frameTime {
    if (dispatch_semaphore_wait(dataUpdateSemaphore, DISPATCH_TIME_NOW) != 0)
    {
        return;
    }
    
    runAsynchronouslyOnVideoProcessingQueue(^{
        
        CGSize pixelSizeOfImage = [self outputImageSize];
        
        for (id<GPUImageInput> currentTarget in targets)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
            [currentTarget setInputSize:pixelSizeOfImage atIndex:textureIndexOfTarget];
            [currentTarget newFrameReadyAtTime:frameTime atIndex:textureIndexOfTarget];
        }
        
        dispatch_semaphore_signal(dataUpdateSemaphore);
    });
}

@end

@interface HPVideoOutput()

@property(nonatomic, strong) GPUImageRawDataInput *input;
@property(nonatomic, strong) GPUImageView *output;
@property(nonatomic, strong) GPUImageRotateFilter *rotateFilter;
@property (nonatomic, assign) CGFloat orientation;
@end

@implementation HPVideoOutput

- (instancetype)initWithFrame:(CGRect)frame orientation:(CGFloat)orientation {
    self = [super init];
    
    if (self) {
        self.input = [[GPUImageRawDataInput alloc] initWithBytes:nil size:CGSizeZero];
        self.output = [[GPUImageView alloc] initWithFrame:frame];
        self.orientation = orientation;
        self.rotateFilter = [GPUImageRotateFilter new];
        self.rotateFilter.rotateDegree = orientation;
        self.filters = nil;
        
        if (self.enableFaceDetector) {
            [self setupFaceDetector];
        }
    }
    return self;
}

- (void)setEnableFaceDetector:(BOOL)enableFaceDetector {
    _enableFaceDetector = enableFaceDetector;
    if (enableFaceDetector) {
        [self setupFaceDetector];
    }
}

- (void)setupFaceDetector {
    FaceDetectorSampleBufferOrientation sampleOrientation = FaceDetectorSampleBufferOrientationNoRatation;
    if (_orientation == 90) {
        sampleOrientation = FaceDetectorSampleBufferOrientationRatation90;
    } else if (_orientation == 180) {
        sampleOrientation = FaceDetectorSampleBufferOrientationRatation180;
    } else if (_orientation == 270) {
        sampleOrientation = FaceDetectorSampleBufferOrientationRatation270;
    }
    [FaceDetector shareInstance].sampleBufferOrientation = sampleOrientation;
    [FaceDetector shareInstance].faceOrientation = _orientation;
    [FaceDetector shareInstance].sampleType = FaceDetectorSampleTypeMovieFile;
    [[FaceDetector shareInstance] auth];
}

- (void)setFilters:(NSArray *)filters {
    _filters = filters;
    
    [self _refreshFilters];
}

- (void)_refreshFilters {
    runAsynchronouslyOnVideoProcessingQueue(^{
        [self.input removeAllTargets];
        [self.input addTarget:self.rotateFilter];
        
        GPUImageOutput *prevFilter = self.rotateFilter;
        GPUImageOutput<GPUImageInput> *theFilter = nil;
        
        for (int i = 0; i < [self.filters count]; i++) {
            theFilter = [self.filters objectAtIndex:i];
            [prevFilter removeAllTargets];
            [prevFilter addTarget:theFilter];
            prevFilter = theFilter;
        }
        
        [prevFilter removeAllTargets];
        
        if (self.output != nil) {
            [prevFilter addTarget:self.output];
        }
    });
}

- (void)presentVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    if (!sampleBuffer) {
        return;
    }
    
    runAsynchronouslyOnVideoProcessingQueue(^{
        if (self.enableFaceDetector) {
            [self faceDetect:sampleBuffer];
        }
        
        CVImageBufferRef cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
        int bufferWidth = (int) CVPixelBufferGetBytesPerRow(cameraFrame) / 4;
        int bufferHeight = (int) CVPixelBufferGetHeight(cameraFrame);
        CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CVPixelBufferLockBaseAddress(cameraFrame, 0);
        
        void *bytes = CVPixelBufferGetBaseAddress(cameraFrame);
        [self.input updateDataFromBytes:bytes size:CGSizeMake(bufferWidth, bufferHeight)];
        CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
        CFRelease(sampleBuffer);
        [self.input processDataForTimestamp:currentTime];

    });

}

- (void)faceDetect:(CMSampleBufferRef)sampleBuffer {
    if (![FaceDetector shareInstance].isWorking) {
        CMSampleBufferRef detectSampleBufferRef = NULL;
        CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &detectSampleBufferRef);
        [[FaceDetector shareInstance] getLandmarksFromSampleBuffer:detectSampleBufferRef];
        CFRelease(detectSampleBufferRef);
    }
}

- (UIView *)preview {
    return self.output;
}

@end
