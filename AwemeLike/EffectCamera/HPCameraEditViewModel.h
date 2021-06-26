//
//  HPCameraEditViewModel.h
//  AwemeLike
//
//  Created by w22543 on 2019/11/26.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPCameraEditMusicItem : NSObject
@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) BOOL selected;
@property(nonatomic, readonly) NSString *thumbPath;

@property(nonatomic, copy) NSString *path;
@end

@interface HPCameraEditViewModel : NSObject

@property(nonatomic, copy) NSString *videoPath;
@property(nonatomic, readonly) NSString *musicPath;
@property(nonatomic, copy) NSArray<HPCameraEditMusicItem*> *musicItems;
- (void)initPlayerIfNeed:(UIView *)preview;
- (void)setPreview:(UIView *)preview;

- (void)play;
- (void)pause;
- (void)playWithMusic:(NSString *)music;

- (CGFloat)musicVolume;
- (CGFloat)originVolume;
- (void)changeVolume:(CGFloat)volume isMusic:(CGFloat)isMusic;

- (void)saveMovieWithProgressHandle:(void(^)(CGFloat progress))progressHandle;

@end


