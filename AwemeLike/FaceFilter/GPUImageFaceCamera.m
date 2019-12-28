//
//  GPUImageFaceCamera.m
//  AwemeLike
//
//  Created by w22543 on 2019/8/21.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <CoreMotion/CoreMotion.h>
#import "FaceDetector.h"
#import "GPUImageDrawLandmarksFilter.h"
#import "GPUImageFaceCamera.h"

@interface GPUImageFaceCamera()<GPUImageVideoCameraDelegate>
{
    int sampleBufferWidth;
    int sampleBufferHeight;
    AVCaptureDevicePosition devicePosition;
    
    GPUImageDrawLandmarksFilter *landmarksFilter;
    
    GLuint bgraTexture;
    GLProgram *bgraRotateProgram;
    GLint bgraPositionAttribute;
    GLint bgraTextureCoordinateAttribute;
    GLint bgraInputTextureUniform;
}

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) int orientation;

@end
@implementation GPUImageFaceCamera

- (instancetype)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition;
{
    if (!(self = [super initWithSessionPreset:sessionPreset cameraPosition:cameraPosition]))
    {
        return nil;
    }
    self.delegate = self;
    [self startMotion];
    self.drawLandmarks = false;
    self->devicePosition = [self cameraPosition];
    [self setupFacepp];
    
    [videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    runSynchronouslyOnVideoProcessingQueue(^{
        self->bgraRotateProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
        if (!self->bgraRotateProgram.initialized)
        {
            [self->bgraRotateProgram addAttribute:@"position"];
            [self->bgraRotateProgram addAttribute:@"inputTextureCoordinate"];
            
            if (![self->bgraRotateProgram link])
            {
                NSString *progLog = [self->bgraRotateProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [self->bgraRotateProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [self->bgraRotateProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                self->bgraRotateProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        self->bgraPositionAttribute = [self->bgraRotateProgram attributeIndex:@"position"];
        self->bgraTextureCoordinateAttribute = [self->bgraRotateProgram attributeIndex:@"inputTextureCoordinate"];
        self->bgraInputTextureUniform = [self->bgraRotateProgram uniformIndex:@"inputImageTexture"];
        
        
        [GPUImageContext setActiveShaderProgram:self->bgraRotateProgram];
        glEnableVertexAttribArray(self->bgraPositionAttribute);
        glEnableVertexAttribArray(self->bgraTextureCoordinateAttribute);
    });
    return self;
}

- (void)startMotion {
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0.3f;
    NSOperationQueue *motionQueue = [[NSOperationQueue alloc] init];
    [motionQueue setName:@"com.megvii.gryo"];
    __weak typeof(self) weakSelf = self;
    [self.motionManager startAccelerometerUpdatesToQueue:motionQueue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        
        __strong typeof(weakSelf) self = weakSelf;
        if (fabs(accelerometerData.acceleration.z) > 0.7) {
            self.orientation = 90;
        }else{
            if (AVCaptureDevicePositionBack == self->devicePosition) {
                if (fabs(accelerometerData.acceleration.x) < 0.4) {
                    self.orientation = 90;
                }else if (accelerometerData.acceleration.x > 0.4){
                    self.orientation = 180;
                }else if (accelerometerData.acceleration.x < -0.4){
                    self.orientation = 0;
                }
            }else{
                if (fabs(accelerometerData.acceleration.x) < 0.4) {
                    self.orientation = 90;
                }else if (accelerometerData.acceleration.x > 0.4){
                    self.orientation = 0;
                }else if (accelerometerData.acceleration.x < -0.4){
                    self.orientation = 180;
                }
            }
            
            if (accelerometerData.acceleration.y > 0.6) {
                self.orientation = 270;
            }
            
            
        }
        //        NSLog(@"%f, %f, %f", accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z);
    }];
}

- (void)setupFacepp {
    
    FaceDetectorSampleBufferOrientation orientation = self->devicePosition == AVCaptureDevicePositionFront ? FaceDetectorSampleBufferOrientationCameraFrontAndHorizontallyMirror : FaceDetectorSampleBufferOrientationCameraBack;
    [FaceDetector shareInstance].sampleBufferOrientation = orientation;
    [FaceDetector shareInstance].faceOrientation = self.orientation;
    [FaceDetector shareInstance].sampleType = FaceDetectorSampleTypeCamera;
    [[FaceDetector shareInstance] auth];
}

- (void)setDrawLandmarks:(BOOL)drawLandmarks {
    _drawLandmarks = drawLandmarks;
    if (drawLandmarks) {
        [self addLandmarksFilter];
    }
}
- (void)addLandmarksFilter {
    landmarksFilter = [[GPUImageDrawLandmarksFilter alloc] init];
    [super addTarget:landmarksFilter];
}

#pragma mark - Override

- (NSArray*)targets;
{
    if (self.drawLandmarks) {
        return landmarksFilter.targets;
    } else {
        return [super targets];
    }
}

- (void)addTarget:(id<GPUImageInput>)newTarget;
{
    if (self.drawLandmarks) {
        [landmarksFilter addTarget:newTarget];
    } else {
        [super addTarget:newTarget];
    }
}

- (void)removeTarget:(id<GPUImageInput>)targetToRemove;
{
    if (self.drawLandmarks) {
        [landmarksFilter removeTarget:targetToRemove];
    } else {
        [super removeTarget:targetToRemove];
    }
}

- (void)rotateCamera {
    [super rotateCamera];
    
    self->devicePosition = [self cameraPosition];
    [self setupFacepp];
    
}

- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
{
    if (capturePaused)
    {
        return;
    }
    
    CVImageBufferRef cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
    int bufferWidth = (int) CVPixelBufferGetWidth(cameraFrame);
    int bufferHeight = (int) CVPixelBufferGetHeight(cameraFrame);
    
    CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    
    [GPUImageContext useImageProcessingContext];
    
    CVPixelBufferLockBaseAddress(cameraFrame, 0);
    
    int bytesPerRow = (int) CVPixelBufferGetBytesPerRow(cameraFrame);
    
    CVOpenGLESTextureRef bgraTextureRef = NULL;
    
    bufferWidth = bytesPerRow / 4;
    if ( (sampleBufferWidth != bufferWidth) && (sampleBufferHeight != bufferHeight) )
    {
        sampleBufferWidth = bufferWidth;
        sampleBufferHeight = bufferHeight;
    }
    CVReturn err;
    glActiveTexture(GL_TEXTURE4);
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], cameraFrame, NULL, GL_TEXTURE_2D, GL_RGBA, bufferWidth, bufferHeight, GL_BGRA, GL_UNSIGNED_BYTE, 0, &bgraTextureRef);
    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    bgraTexture = CVOpenGLESTextureGetName(bgraTextureRef);
    glBindTexture(GL_TEXTURE_2D, bgraTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    [self rotateBGRImageBuffer];
    
    int rotatedImageBufferWidth = bufferWidth, rotatedImageBufferHeight = bufferHeight;
    
    if (GPUImageRotationSwapsWidthAndHeight(internalRotation))
    {
        rotatedImageBufferWidth = bufferHeight;
        rotatedImageBufferHeight = bufferWidth;
    }
    
    [self updateTargetsForVideoCameraUsingCacheTextureAtWidth:rotatedImageBufferWidth height:rotatedImageBufferHeight time:currentTime];
    
    CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
    CFRelease(bgraTextureRef);
    
}

- (void)rotateBGRImageBuffer;
{
    [GPUImageContext setActiveShaderProgram:bgraRotateProgram];
    
    int rotatedImageBufferWidth = sampleBufferWidth, rotatedImageBufferHeight = sampleBufferHeight;
    
    if (GPUImageRotationSwapsWidthAndHeight(internalRotation))
    {
        rotatedImageBufferWidth = sampleBufferHeight;
        rotatedImageBufferHeight = sampleBufferWidth;
    }
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(rotatedImageBufferWidth, rotatedImageBufferHeight) textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, bgraTexture);
    glUniform1i(bgraInputTextureUniform, 4);
    
    glVertexAttribPointer(bgraPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(bgraTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [GPUImageFilter textureCoordinatesForRotation:internalRotation]);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
}


- (void)updateTargetsForVideoCameraUsingCacheTextureAtWidth:(int)bufferWidth height:(int)bufferHeight time:(CMTime)currentTime;
{
    // First, update all the framebuffers in the targets
    for (id<GPUImageInput> currentTarget in targets)
    {
        if ([currentTarget enabled])
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            if (currentTarget != self.targetToIgnoreForUpdates)
            {
                [currentTarget setInputRotation:outputRotation atIndex:textureIndexOfTarget];
                [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight) atIndex:textureIndexOfTarget];
                
                if ([currentTarget wantsMonochromeInput] && captureAsYUV)
                {
                    [currentTarget setCurrentlyReceivingMonochromeInput:YES];
                    // TODO: Replace optimization for monochrome output
                    [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
                }
                else
                {
                    [currentTarget setCurrentlyReceivingMonochromeInput:NO];
                    [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
                }
            }
            else
            {
                [currentTarget setInputRotation:outputRotation atIndex:textureIndexOfTarget];
                [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
            }
        }
    }
    
    // Then release our hold on the local framebuffer to send it back to the cache as soon as it's no longer needed
    [outputFramebuffer unlock];
    outputFramebuffer = nil;
    
    // Finally, trigger rendering as needed
    for (id<GPUImageInput> currentTarget in targets)
    {
        if ([currentTarget enabled])
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            if (currentTarget != self.targetToIgnoreForUpdates)
            {
                [currentTarget newFrameReadyAtTime:currentTime atIndex:textureIndexOfTarget];
            }
        }
    }
}

#pragma mark - GPUImageVideoCameraDelegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    if (![FaceDetector shareInstance].isWorking) {
        CMSampleBufferRef detectSampleBufferRef = NULL;
        CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &detectSampleBufferRef);

//        dispatch_async(detectImageQueue, ^{
        
            if ([FaceDetector shareInstance].faceOrientation != self.orientation) {
                [FaceDetector shareInstance].faceOrientation = self.orientation;
            }
            [[FaceDetector shareInstance] getLandmarksFromSampleBuffer:detectSampleBufferRef];
        
            CFRelease(detectSampleBufferRef);
//        });
    }
    
}

#pragma mark - Torch

- (BOOL)torchAvailable {
    return _inputCamera.torchAvailable;
}

- (void)switchTorch {
    BOOL isActive = _inputCamera.isTorchActive;
    
    NSError *error;
    [_inputCamera lockForConfiguration:&error];
    if (isActive) {
        if ([_inputCamera isTorchModeSupported:AVCaptureTorchModeOff]) {
            [_inputCamera setTorchMode:AVCaptureTorchModeOff];
        }
    } else {
        if ([_inputCamera isTorchModeSupported:AVCaptureTorchModeOn]) {
            [_inputCamera setTorchMode:AVCaptureTorchModeOn];
        }
    }
    [_inputCamera unlockForConfiguration];
}

- (void)dealloc {
    
    [self.motionManager stopAccelerometerUpdates];
}

@end
