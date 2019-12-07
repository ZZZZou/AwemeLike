//
//  HPVideoEditViewController.m
//  AwemeLike
//
//  Created by wang on 2019/10/20.
//  Copyright © 2019 Hytera. All rights reserved.
//

#import "HPVideoEffectChooseViewController.h"
#import "HPCameraEditViewModel.h"
#import "HPVideoEditViewController.h"

@interface HPMusicListViewCell : UICollectionViewCell
@property(nonatomic, weak) IBOutlet UILabel *name;
@property(nonatomic, weak) IBOutlet UIImageView *thumb;
@end
@implementation HPMusicListViewCell
@end

@interface HPMusicListView : UIView<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, weak) IBOutlet UIView *musicListView;
@property(nonatomic, weak) IBOutlet UIView *volumeView;
@property(nonatomic, weak) IBOutlet UIButton *musicListBtn;
@property(nonatomic, weak) IBOutlet UIButton *volumeBtn;
@property(nonatomic, weak) IBOutlet UISlider *originSlide;
@property(nonatomic, weak) IBOutlet UISlider *musicSlide;
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property(nonatomic, copy) NSArray<HPCameraEditMusicItem*> *items;
@property(nonatomic, strong) HPCameraEditMusicItem *selectedItem;

@property(nonatomic, copy) void(^didChangeVolumeBlock)(CGFloat volume, BOOL isMusic);
@property(nonatomic, copy) void(^didSelectedBlock)(HPCameraEditMusicItem *musicItem);

@end


@implementation HPMusicListView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flow.minimumLineSpacing = 0;
    flow.minimumInteritemSpacing = 0;
    flow.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.itemSize = CGSizeMake(70, 80);
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)selectIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedItem.selected = false;
    
    HPCameraEditMusicItem *item;
    if (indexPath) {
        item = self.items[indexPath.row];
        item.selected = true;
    }
    self.selectedItem = item;
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
    [self.collectionView reloadData];
}

- (IBAction)musicListClick:(id)sender {
    self.musicListView.hidden = false;
    self.volumeView.hidden = true;
    
    self.musicListBtn.selected = false;
    self.volumeBtn.selected = true;
}

- (IBAction)volumeClick:(id)sender {
    
    self.musicListView.hidden = true;
    self.volumeView.hidden = false;
    
    self.musicListBtn.selected = true;
    self.volumeBtn.selected = false;
}

- (IBAction)originVolumeDidChange:(UISlider *)sender {
    if (self.didChangeVolumeBlock) {
        self.didChangeVolumeBlock(sender.value, false);
    }
}

- (IBAction)musicVolumeDidChange:(UISlider *)sender {
    if (self.didChangeVolumeBlock) {
        self.didChangeVolumeBlock(sender.value, true);
    }
}

- (IBAction)filterBGViewClick:(id)sender {
    self.hidden = true;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HPCameraEditMusicItem *item = self.items[indexPath.row];
    
    HPMusicListViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    cell.thumb.image = [UIImage imageWithContentsOfFile:item.thumbPath];
    cell.name.text = item.name;
    
    if (item.selected) {
        UIColor *color = [UIColor colorWithRed:0xfa/256.0 green:0xce/256.0 blue:0x15/256.0 alpha:1];
        cell.thumb.layer.borderWidth = 2;
        cell.thumb.layer.borderColor = color.CGColor;
        cell.name.textColor = color;
    } else {
        cell.thumb.layer.borderWidth = 0;
        cell.name.textColor = UIColor.whiteColor;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:false];
    
    [self selectIndexPath:indexPath];
    
    if (self.didSelectedBlock) {
        self.didSelectedBlock(self.selectedItem);
    }
    
}

@end


@interface HPVideoEditViewController ()<UIViewControllerTransitioningDelegate>


@property(nonatomic, weak) IBOutlet UIView *preview;
@property(nonatomic, strong) IBOutlet HPMusicListView *musicView;
@property(nonatomic, weak) IBOutlet UIView *hudView;
@property(nonatomic, weak) IBOutlet UILabel *handleProgressLabel;

@end

@implementation HPVideoEditViewController

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.vm play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.vm pause];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.bounds = [UIScreen mainScreen].bounds;
    self.preview.frame = self.view.bounds;
    self.hudView.frame = self.view.bounds;
    self.hudView.hidden = true;
    [self.view addSubview:self.hudView];
    self.musicView.frame = self.view.bounds;
    self.musicView.hidden = true;
    [self.view addSubview:self.musicView];
    
    
    [self setupMusicAction];
    [self.vm setPreview:self.preview];
    self.musicView.items = self.vm.musicItems;
    [self.musicView reloadData];
}

- (void)setHandleProgress:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hudView.hidden = false;
        self.handleProgressLabel.text = [NSString stringWithFormat:@"%.2f%@", progress*100, @"%"];
        
        if (progress == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.hudView.hidden = true;
            });
        }
    });
}

#pragma mark - Action

- (void)setupMusicAction {
    
    __weak typeof(self) wself = self;
    self.musicView.didSelectedBlock = ^(HPCameraEditMusicItem *musicItem) {
        __strong typeof(wself) self = wself;
        [self.vm playWithMusic:musicItem.path];
    };
    
    [self.vm changeVolume:self.musicView.originSlide.value isMusic:false];
    [self.vm changeVolume:self.musicView.musicSlide.value isMusic:true];
    self.musicView.didChangeVolumeBlock = ^(CGFloat volume, BOOL isMusic) {
        __strong typeof(wself) self = wself;
        [self.vm changeVolume:volume isMusic:isMusic];
    };
}

- (IBAction)musicClick:(id)sender {
    
    self.musicView.hidden = false;
}

- (IBAction)effectClick:(id)sender {
    
    UIGraphicsBeginImageContext(self.preview.bounds.size);
    [self.preview drawViewHierarchyInRect:self.preview.bounds afterScreenUpdates:false];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    HPVideoEffectChooseViewModel *vm = [[HPVideoEffectChooseViewModel alloc] initWithVideoFilePath:self.vm.videoPath musicFilePath:self.vm.musicPath];
    vm.musicVolume = self.vm.musicVolume;
    vm.originVolume = self.vm.originVolume;
    UIStoryboard *sd = [UIStoryboard storyboardWithName:@"Aweme" bundle:nil];
    HPVideoEffectChooseViewController *effect = (HPVideoEffectChooseViewController *)[sd instantiateViewControllerWithIdentifier:NSStringFromClass(HPVideoEffectChooseViewController.class)];
    effect.transitioningDelegate = effect;
    effect.vm = vm;
    effect.transitionImage = img;
    [self presentViewController:effect animated:true completion:nil];
    
}

- (IBAction)wordClick:(id)sender {
    
}

- (IBAction)stickerClick:(id)sender {
    
}

- (IBAction)nextClick:(id)sender {
   
    __weak typeof(self) wself = self;
    [self.vm saveMovieWithProgressHandle:^(CGFloat progress){
        __strong typeof(wself) self = wself;
       [self setHandleProgress:progress];
    }];
}

- (IBAction)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)dealloc {
    [[HPRangeEffectManager shareInstance] clear];
    NSLog(@"HPVideoEditViewController dealloc");
}

@end
