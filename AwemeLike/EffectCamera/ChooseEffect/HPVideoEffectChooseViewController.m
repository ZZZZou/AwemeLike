//
//  HPVideoEffectChooseViewController.m
//  AwemeLike
//
//  Created by wang on 2019/10/20.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPRangeEffectManager.h"
#import "HPVideoEffectTimeLineView.h"
#import "HPVideoDecoder.h"
#import "HPPlayer.h"
#import "HPVideoEffectChooseViewController.h"

@interface HPVideoEffectChooseCell : UICollectionViewCell
{
    UILongPressGestureRecognizer *longPress;
    UITapGestureRecognizer *tap;
}

@property(nonatomic, weak) IBOutlet UIImageView *icon;
@property(nonatomic, weak) IBOutlet UILabel *name;
@property(nonatomic, copy) void(^longPressBlock)(UIGestureRecognizerState state);
@property(nonatomic, copy) void(^singleTapBlock)(void);
@end
@implementation HPVideoEffectChooseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.contentView addGestureRecognizer:longPress];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.contentView addGestureRecognizer:tap];
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture {
    if (self.longPressBlock) {
        self.longPressBlock(gesture.state);
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        if (self.singleTapBlock) {
            self.singleTapBlock();
        }
    }
}

- (void)enableTapGesture {
    tap.enabled = true;
    longPress.enabled = false;
}

- (void)enableLongPressGesture {
    tap.enabled = false;
    longPress.enabled = true;
}

@end

@interface HPVideoEffectChooseViewController ()

@property(nonatomic, weak) IBOutlet UIView *preview;
@property(nonatomic, weak) IBOutlet UIButton *playBtn;

@property(nonatomic, weak) IBOutlet UIView *bottomView;
@property(nonatomic, weak) IBOutlet UIButton *undoBtn;
@property(nonatomic, weak) IBOutlet HPVideoEffectTimeLineView *timeLine;
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property(nonatomic, strong) IBOutletCollection(UIButton) NSArray *effectTypeBtns;
@property(nonatomic, copy) NSArray<HPVideoEffectChooseEffectItem *> *effectItems;

@end

@implementation HPVideoEffectChooseViewController

- (UIView *)bottomView {
    return _bottomView;
}

- (UIView *)videoView {
    return self.preview;
}

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.vm.preview = self.preview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) wself = self;
    self.vm.progressDidChange = ^(CGFloat progress) {
        __strong typeof(wself) self = wself;
        [self changeTimelineProgress:progress];
    };
    [self.vm presentFirstFrameBuffer];
    
    [self setupView];
    [self switchEffectDataTo:0];
}

- (void)setupView {
    
    self.playBtn.selected = !self.vm.isPlaying;
    //flow
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flow.minimumLineSpacing = 0;
    flow.minimumInteritemSpacing = 0;
    flow.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.itemSize = CGSizeMake(68, 106);
    //timeline
    [self setupTimeLine];
}

- (void)setupTimeLine {
    self.timeLine.numOfBackgroundImage = 12;
    __weak typeof(self) wself = self;
    self.timeLine.progressDidChange = ^(CGFloat progress, HPSliderState state) {
        __strong typeof(wself) self = wself;
        [self seekTo:progress state:(HPPlayerSeekTimeStatus)state];
    };
    
    CGFloat num = self.timeLine.numOfBackgroundImage;
    CGFloat targetWidth = (UIScreen.mainScreen.bounds.size.width - 16*2) / num;
    
    [self.vm decodeImage:num scaleToWidth:targetWidth completion:^(UIImage *img, NSInteger index) {
        [self.timeLine setBackgroundImage:img at:index];
    }];
}

- (void)resetUndoBtn {
    self.undoBtn.hidden = !self.vm.currentRangeEffects.count;
}

- (void)resetTimeLineRangeEffect {
    CGFloat duration = self.vm.duration;
    NSMutableArray *tmp = @[].mutableCopy;
    [self.vm.currentRangeEffects enumerateObjectsUsingBlock:^(HPModelRangeEffect * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HPVideoEffectTimeLineRangeModel *model = [HPVideoEffectTimeLineRangeModel new];
        model.startPosition = CMTimeGetSeconds(obj.sequenceIn) / duration;
        model.length = CMTimeGetSeconds(CMTimeSubtract(obj.sequenceOut, obj.sequenceIn)) / duration;
        model.color = obj.color;
        [tmp addObject:model];
    }];
    self.timeLine.rangeModelList = tmp;
}

#pragma mark - Action

- (IBAction)playClick:(id)sender {
    BOOL isPlaying = self.vm.isPlaying;
    if (isPlaying) {
        [self.vm pause];
    } else {
        [self.vm play];
    }
    
    self.playBtn.selected = isPlaying;
}

- (IBAction)effectTypeClick:(UIButton *)sender {
    NSInteger index = sender.tag - 100;
    
    [self.effectTypeBtns setValue:@(true) forKeyPath:@"selected"];
    sender.selected = false;
    
    [self switchEffectDataTo:index];
}

- (void)switchEffectDataTo:(NSInteger)section {
    
    self.vm.currentSection = section;
    self.effectItems = self.vm.currentEffectItems;
    [self.collectionView reloadData];
    
    [self resetTimeLineRangeEffect];
    [self resetUndoBtn];
    
    [self.collectionView scrollsToTop];
}

- (IBAction)cancelClick:(id)sender {
    UIGraphicsBeginImageContext(self.preview.bounds.size);
    [self.preview drawViewHierarchyInRect:self.preview.bounds afterScreenUpdates:false];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.transitionImage = img;
    
    [self.vm pause];
    [self.vm removeAllRangeEffect];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)saveClick:(id)sender {
    [self.vm pause];
    [self dismissViewControllerAnimated:true completion:nil];
    
}

- (IBAction)undoClick:(id)sender {
    [self.vm pause];
    HPModelRangeEffect *rangeEffect = [self.vm removeLastRangeEffect];
    CGFloat progress = CMTimeGetSeconds(rangeEffect.sequenceIn) / self.vm.duration;
    [self resetTimeLineRangeEffect];

    [self resetUndoBtn];
    self.timeLine.progress = progress;
    [self.vm seekTimeToProgress:progress];
    
    self.playBtn.selected = !self.vm.isPlaying;
}


- (void)reloadData {
    
}

#pragma mark - Progress

- (void)seekTo:(CGFloat)progress state:(HPPlayerSeekTimeStatus)state {
    [self.vm pause];
    [self.vm seekTimeToProgress:progress state:state];
    
    self.playBtn.selected = !self.vm.isPlaying;
}

- (void)changeTimelineProgress:(CGFloat)progress {
    
    self.timeLine.progress = progress;
    [self.timeLine updateTrackRangeView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.effectItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HPVideoEffectChooseEffectItem *item = self.effectItems[indexPath.row];
    
    HPVideoEffectChooseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    cell.icon.image = [UIImage imageNamed:item.imgName];
    cell.name.text = item.name;
    
    NSInteger section = self.vm.currentSection;
    if (section == 0 || section == 2) {
        [cell enableLongPressGesture];
    } else {
        [cell enableTapGesture];
    }
    
    __weak typeof(self) wself = self;
    cell.longPressBlock = ^(UIGestureRecognizerState state) {
        __strong typeof(wself) self = wself;
        if (state == UIGestureRecognizerStateBegan) {
            [self.vm beginLongPressAtIndex:indexPath.row];
            [self.timeLine beginTrackRangeView:item.color];
        } else if (state == UIGestureRecognizerStateChanged) {
            
        } else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled || state == UIGestureRecognizerStateFailed) {
            [self.timeLine endTrackRangeView];
            [self.vm endLongPress];
            [self resetUndoBtn];
            self.playBtn.selected = !self.vm.isPlaying;
        }
    };
    
    cell.singleTapBlock = ^{
        __strong typeof(wself) self = wself;
        [self.vm tapTransitionEffectAtIndex:indexPath.row];
        [self resetTimeLineRangeEffect];
        [self resetUndoBtn];
        self.playBtn.selected = !self.vm.isPlaying;
        if (self.vm.currentSection) {
            self.playBtn.selected = false;
        }
    };
    
    return cell;
}

- (void)dealloc {
    NSLog(@"HPVideoEffectChooseViewController dealloc");
}
@end


@implementation HPVideoEffectChooseViewController(Transitioning)

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    CGRect fromFrame;
    CGRect toFrame;
    BOOL isPresented = self == [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (isPresented) {
        CGRect bounds = UIScreen.mainScreen.bounds;
        CGFloat toY = 52;
        CGFloat toHeight = bounds.size.height - toY - 16 - 240;
        CGFloat toWidth = toHeight * (bounds.size.width / bounds.size.height);
        fromFrame = [UIScreen mainScreen].bounds;
        toFrame = CGRectMake((bounds.size.width-toWidth)/2, toY, toWidth, toHeight);
    } else {
        fromFrame = self.preview.frame;
        toFrame = [UIScreen mainScreen].bounds;
    }
    
    UIView *containerView = transitionContext.containerView;
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIImageView *tmpView = [[UIImageView alloc] initWithImage:self.transitionImage];
    tmpView.contentMode = UIViewContentModeScaleAspectFill;
    tmpView.frame = fromFrame;
    [containerView addSubview:toView];
    if (!isPresented) {
        [containerView addSubview:fromView];
    }
    [containerView addSubview:tmpView];
    
    CGRect bottomViewDesFrame;
    if (isPresented) {
        bottomViewDesFrame = self.bottomView.frame;
        CGRect originFrame = bottomViewDesFrame;
        originFrame.origin.y = UIScreen.mainScreen.bounds.size.height;
        self.bottomView.frame = originFrame;
    } else {
        bottomViewDesFrame = self.bottomView.frame;
        bottomViewDesFrame.origin.y = UIScreen.mainScreen.bounds.size.height;
    }
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        tmpView.frame = toFrame;
        self.bottomView.frame = bottomViewDesFrame;
    } completion:^(BOOL finished) {
        [tmpView removeFromSuperview];
        toView.hidden = false;
        BOOL wasCancelled = transitionContext.transitionWasCancelled;
        [transitionContext completeTransition:!wasCancelled];
    }];
    
}

@end
