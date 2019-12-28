//
//  HPVideoOutput.h
//  AwemeLike
//
//  Created by w22543 on 2019/10/11.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "GPUImage.h"
#import <UIKit/UIKit.h>

@interface HPVideoOutput : NSObject
@property(nonatomic, readonly) UIView *preview;

@property(nonatomic, copy) NSArray<GPUImageOutput<GPUImageInput> *> *filters;
@property(nonatomic, assign) BOOL enableFaceDetector;

- (instancetype)initWithFrame:(CGRect)frame orientation:(CGFloat)orientation;

- (void)presentVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

