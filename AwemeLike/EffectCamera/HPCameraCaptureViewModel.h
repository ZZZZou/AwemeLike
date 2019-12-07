//
//  HPCameraCaptureViewModel.h
//  AwemeLike
//
//  Created by wang on 2019/11/17.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPModelEffect.h"
#import <Foundation/Foundation.h>

@interface HPCameraCaptureViewFilterItem : NSObject
@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) BOOL selected;

@property(nonatomic, readonly) NSString *thumbPath;
@property(nonatomic, readonly) CGFloat intensity;

@property(nonatomic, strong) HPModelEffect *effect;

@end

@interface HPCameraCaptureViewModel : NSObject

@property(nonatomic, readonly) NSString *outputVideoFilePath;
@property(nonatomic, strong) NSIndexPath *filterIndexPath;
@property(nonatomic, copy) NSArray<NSArray<HPCameraCaptureViewFilterItem*>*> *filterItems;

- (instancetype)init;
- (void)setupFilter:(UIView *)preview;
- (void)startCameraCapture;
- (void)stopCameraCapture;
- (void)startRecording;
- (void)stopRecording:(void(^)(void))completion;

- (BOOL)isRecording;
- (BOOL)torchAvailable;

- (void)setupFacepp;
- (void)rotateCamera;
- (void)lightingSwitch;
- (void)updateSmooth:(CGFloat)percent;
- (void)updateThinFace:(CGFloat)percent;
- (void)updateBigEye:(CGFloat)percent;
- (void)updateLipstick:(CGFloat)percent;
- (void)updateBlusher:(CGFloat)percent;

- (void)beginTwoLutFilter:(NSIndexPath *)firstIndexPath secondIndexPath:(NSIndexPath *)secondIndexPath split:(CGFloat)split;
- (void)updateTwoLutFilter:(CGFloat)split;
- (void)endTwoLutFilter:(NSIndexPath *)indexPath;

- (void)switchFilterTo:(NSIndexPath *)indexPath;
@end


