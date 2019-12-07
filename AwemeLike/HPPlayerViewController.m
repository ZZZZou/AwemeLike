//
//  HPPlayerViewController.m
//  AwemeLike
//
//  Created by wang on 2019/10/14.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPPlayer.h"
#import "HPPlayerViewController.h"

@interface HPPlayerViewController ()<PlayerStateDelegate>
{
    HPPlayer *player;
    NSDictionary *effectDic;
    NSInteger index;
}
@property(nonatomic, weak) IBOutlet UILabel *hint;
@property(nonatomic, weak) IBOutlet UISlider *progressSlider;
@end

@implementation HPPlayerViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [player pause];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/finalMovie.mp4"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToMovie]) {
        self.filePath = pathToMovie;
        player = [[HPPlayer alloc] initWithFilePath:self.filePath preview:self.view playerStateDelegate:self];
        player.shouldRepeat = false;
        
        [self.progressSlider addTarget:self action:@selector(beginSeekTime) forControlEvents:UIControlEventTouchDown];
        [self.progressSlider addTarget:self action:@selector(endSeekTime) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        self.hint.hidden = true;
        self.progressSlider.hidden = false;
    } else {
        self.hint.hidden = false;
        self.progressSlider.hidden = true;
    }
    
    
}

- (IBAction)sliderDidChange:(UISlider *)sender {
    
    CGFloat time = self.progressSlider.value * CMTimeGetSeconds(player.duration);
    [player seekToTime:CMTimeMake(time * 1000000, 1000000) status:HPPlayerSeekTimeStatusUpdate];
}

- (void)beginSeekTime {
    CGFloat time = self.progressSlider.value * CMTimeGetSeconds(player.duration);
    [player seekToTime:CMTimeMake(time * 1000000, 1000000) status:HPPlayerSeekTimeStatusBegin];
}

- (void)endSeekTime {
    CGFloat time = self.progressSlider.value * CMTimeGetSeconds(player.duration);
    [player seekToTime:CMTimeMake(time * 1000000, 1000000) status:HPPlayerSeekTimeStatusEnd];
}

- (IBAction)dissmis:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (player.isPlaying) {
        [player pause];
    } else {
        [player play];
    }
}

#pragma mark - PlayerStateDelegate

- (void)progressDidChange:(CGFloat)progress {
    self.progressSlider.value = progress;
}

@end
