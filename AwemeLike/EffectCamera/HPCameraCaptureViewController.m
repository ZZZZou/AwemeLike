//
//  HPCameraCaptureViewController.m
//  AwemeLike
//
//  Created by w22543 on 2019/7/24.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "HPCameraCaptureViewModel.h"
#import "HPVideoEditViewController.h"
#import "HPCameraCaptureViewController.h"

@interface HPProgressView : UIView
{
    NSMutableArray<UIView*> *cachedLineViews;
    NSMutableArray<UIView*> *usedLineViews;

}
@end

@implementation HPProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        cachedLineViews = @[].mutableCopy;
        usedLineViews = @[].mutableCopy;
        
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        view.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
        [self addSubview:view];
    }
    return self;
}

- (void)resetView:(NSArray<NSNumber*> *)points hasLastSplitLine:(BOOL)hasLastSplitLine {
    [usedLineViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [cachedLineViews addObjectsFromArray:usedLineViews];
    [usedLineViews removeAllObjects];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    __block CGFloat lastX = 0;
    [points enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *lineView = [self getLineView];
        lineView.backgroundColor = [UIColor orangeColor];
        [self addSubview:lineView];
        [self->usedLineViews addObject:lineView];
        
        lineView.frame = CGRectMake(lastX, 0, width * obj.floatValue - lastX, height);
        lastX = lastX + lineView.frame.size.width;
        
        if (hasLastSplitLine || idx != points.count-1) {
            UIView *splitView = [self getLineView];
            splitView.backgroundColor = [UIColor whiteColor];
            [self addSubview:splitView];
            [self->usedLineViews addObject:splitView];
            
            splitView.frame = CGRectMake(lastX-2, 0, 2, height);
        }
    }];
}

- (UIView *)getLineView {
    UIView *view = cachedLineViews.lastObject;
    if (view) {
        [cachedLineViews removeLastObject];
    } else {
        view = [UIView new];
    }
    return view;
}

@end

@interface HPFilterListViewCell : UICollectionViewCell
@property(nonatomic, weak) IBOutlet UILabel *name;
@property(nonatomic, weak) IBOutlet UIImageView *thumb;
@end
@implementation HPFilterListViewCell
@end

@interface HPFilterListView : UIView<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, weak) IBOutlet UIImageView *clearFilterIcon;
@property(nonatomic, strong) IBOutletCollection(UIButton) NSArray *filterSectionBtns;
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property(nonatomic, copy) NSArray<NSArray<HPCameraCaptureViewFilterItem*>*> *filterItems;
@property(nonatomic, strong) HPCameraCaptureViewFilterItem *selectedItem;

@property(nonatomic, copy) void(^didSelectedBlock)(NSIndexPath *indexPath);
@property(nonatomic, copy) void(^didClickBGViewBlock)(void);

@end


@implementation HPFilterListView

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

- (void)selectIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedItem.selected = false;
    
    HPCameraCaptureViewFilterItem *item;
    if (indexPath) {
        item = self.filterItems[indexPath.section][indexPath.row];
        item.selected = true;
    }
    self.selectedItem = item;
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
    [self.collectionView reloadData];
}


- (IBAction)clearFilter:(id)sender {
    [self selectIndexPath:nil];
    
    if (self.didSelectedBlock) {
        self.didSelectedBlock(nil);
    }
}

- (IBAction)sectionBtnClick:(UIButton *)sender {
    NSInteger section = sender.tag - 100;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section] atScrollPosition:UICollectionViewScrollPositionLeft animated:true];
}

- (IBAction)filterBGViewClick:(id)sender {
    if (self.didClickBGViewBlock) {
        self.didClickBGViewBlock();
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.filterItems.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.filterItems[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HPCameraCaptureViewFilterItem *item = self.filterItems[indexPath.section][indexPath.row];
    
    HPFilterListViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
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
        self.didSelectedBlock(indexPath);
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:offset];
    
    if (self.selectedItem) {
        [self.filterSectionBtns enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selected = false;
        }];
        
        [self.filterSectionBtns[indexPath.section] setSelected:true];
    }
}

@end


#define DefaultSmoothValue 0.5
#define DefaultThinFaceValue 0.5
#define DefaultBigEyeValue 0.5
#define DefaultLipstickValue 0.5
#define DefaultBlusherValue 0.5


@interface HPCameraCaptureViewController ()
{
    
    BOOL recording;
    BOOL showFilterView;
    BOOL showBeautyView;
    
    NSMutableArray *beautyValues;
    NSInteger selectedBeautyItem;
}
@property(nonatomic, weak) IBOutlet UIView *preview;
@property(nonatomic, weak) IBOutlet UIView *interactionView;

@property(nonatomic, weak) IBOutlet UIView *rightTopView;
@property(nonatomic, weak) IBOutlet UIView *torchView;

@property(nonatomic, weak) IBOutlet UIView *bottomView;
@property(nonatomic, weak) IBOutlet UIView *recordBGView;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *recordBGViewConstraintWidth;
@property(nonatomic, weak) IBOutlet UIButton *delView;
@property(nonatomic, weak) IBOutlet UIButton *saveView;


//filter view
@property(nonatomic, weak) IBOutlet UIView *filterAlertView;
@property(nonatomic, weak) IBOutlet UILabel *filterName;
@property(nonatomic, weak) IBOutlet UILabel *filterCategoryName;
@property(nonatomic, weak) IBOutlet HPFilterListView *filterView;

//beauty view
@property(nonatomic, weak) IBOutlet UIView *beautyView;
@property(nonatomic, weak) IBOutlet UISlider *beautyViewSlider;
@property(nonatomic, copy) IBOutletCollection(UIView) NSArray *beautyItemViews;

@property(nonatomic, weak) IBOutlet UIView *hudView;

//progress view
@property(nonatomic, strong) HPProgressView *progressView;

@property(nonatomic, strong) HPCameraCaptureViewModel *vm;
@end

@implementation HPCameraCaptureViewController

- (BOOL)prefersStatusBarHidden {
    return true;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.vm startCameraCapture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.vm setupFacepp];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.vm stopCameraCapture];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    
    self.vm = [[HPCameraCaptureViewModel alloc] init];
    [self.vm setupFilter:self.preview];
    [self resetView];
    [self resetBeauty:nil];
    self.filterView.filterItems = self.vm.filterItems;
    
    
    __weak typeof(self) wself = self;
    self.vm.updateRecordedTime = ^(NSArray *timePoints, BOOL finished) {
        __strong typeof(wself) self = wself;
        [self updateProgressView:timePoints];
        if (finished) {
            [self saveClick:nil];
        }
    };
}

- (void)initView {
    
    self.navigationController.navigationBar.hidden = true;
    self.navigationController.interactivePopGestureRecognizer.enabled = false;
    self.view.bounds = [UIScreen mainScreen].bounds;
    self.preview.bounds = self.view.bounds;
    self.beautyView.frame = self.view.bounds;
    self.filterView.frame = self.view.bounds;
    self.hudView.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    
    
    self.progressView = [HPProgressView new];
    self.progressView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 4);
    [self.view addSubview:self.progressView];
    
    [self.interactionView addSubview: self.beautyView];
    [self.interactionView addSubview: self.filterView];
    [self.interactionView addSubview: self.hudView];
    self.beautyView.hidden = true;
    self.filterView.hidden = true;
    self.hudView.hidden = true;
    
    __weak typeof(self) wself = self;
    self.filterView.didClickBGViewBlock = ^{
        __strong typeof(wself) self = wself;
        [self showFilterView];
    };
    
    self.filterView.didSelectedBlock = ^(NSIndexPath *indexPath) {
        __strong typeof(wself) self = wself;
        [self.vm switchFilterTo:indexPath];
        [self showFilterAlertView:indexPath];
    };
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.interactionView addGestureRecognizer:pan];
}

- (void)resetView {
    BOOL torchAvailable = self.vm.torchAvailable;
    
    self.saveView.hidden = recording || !self.vm.canSave;
    self.delView.hidden = recording || !self.vm.canRemove;
    
    if (recording) {
        self.recordBGView.layer.cornerRadius = 4;
        self.recordBGViewConstraintWidth.constant = 30;
    } else {
        self.recordBGView.layer.cornerRadius = 30;
        self.recordBGViewConstraintWidth.constant = 60;
    }
    if (showBeautyView) {
        self.beautyView.hidden = false;
    } else {
        self.beautyView.hidden = true;
    }
    if (showFilterView) {
        self.filterView.hidden = false;
    } else {
        self.filterView.hidden = true;
    }
    self.bottomView.hidden = (showFilterView || showBeautyView);
    self.rightTopView.hidden = (showFilterView || showBeautyView || recording);
    self.torchView.hidden = !torchAvailable;
    
    //beauty view
    for (UIView *view in self.beautyItemViews) {
        view.layer.borderWidth = 0;
    }
    UIView *selectedView = self.beautyItemViews[selectedBeautyItem];
    selectedView.layer.borderWidth = 2;
    selectedView.layer.borderColor = [UIColor colorWithRed:0xfa/256.0 green:0xce/256.0 blue:0x15/256.0 alpha:1].CGColor;
    self.beautyViewSlider.value = [beautyValues[selectedBeautyItem] floatValue];
}

- (void)showFilterAlertView:(NSIndexPath *)indexPath {
    
    self.filterAlertView.hidden = false;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideFilterAlertView) withObject:nil afterDelay:1];
    NSArray *titles = @[@"人像", @"风景", @"美食", @"新锐"];
    HPCameraCaptureViewFilterItem *item = self.vm.filterItems[indexPath.section][indexPath.row];
    self.filterName.text = item.name;
    self.filterCategoryName.text = titles[indexPath.section];
}

- (void)hideFilterAlertView {
    self.filterAlertView.hidden = true;
}

- (void)updateProgressView:(NSArray *)timePoints {
   
    CGFloat maxTime = self.vm.maxRecordingTime;
    NSMutableArray *points = @[].mutableCopy;
    [timePoints enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [points addObject:@(obj.floatValue/maxTime)];
    }];
    [self.progressView resetView:points hasLastSplitLine:!self->recording];
}

#pragma mark - PanGesture

static CGFloat panOffset;
static CGFloat maxVelocity;
static BOOL leftToRight;
static NSIndexPath *firstIndexPath;
static NSIndexPath *secondIndexPath;
static BOOL ignoredFirst;

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    
    CGPoint point = [pan translationInView:self.interactionView];
    [pan setTranslation:CGPointZero inView:self.interactionView];
    
    CGFloat velocity = [pan velocityInView:self.interactionView].x;
    maxVelocity = MAX(maxVelocity, fabs(velocity));
    
    if (showFilterView || showBeautyView || recording || !ignoredFirst) {
        ignoredFirst = true;
        return;
    }
    
    NSArray *filterItems = self.vm.filterItems;
    if (panOffset == 0) {
        panOffset = point.x;
        leftToRight = panOffset > 0;
        
        NSIndexPath *currentIndexPath = self.vm.filterIndexPath;
        if (currentIndexPath == nil) {
            currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        }
        if (leftToRight) {
            NSInteger firstSection;
            NSInteger firstRow;
            if (currentIndexPath.row == 0) {
                firstSection = (secondIndexPath.section-1) % filterItems.count;
                firstRow = [filterItems[firstSection] count] - 1;
            } else {
                firstSection = currentIndexPath.section;
                firstRow = currentIndexPath.row - 1;
            }
            firstIndexPath = [NSIndexPath indexPathForRow:firstRow inSection:firstSection];
            secondIndexPath = currentIndexPath;
            
        } else {
            NSInteger secondSection;
            NSInteger secondRow;
            if (currentIndexPath.row == [filterItems[currentIndexPath.section] count] - 1) {
                secondSection = (currentIndexPath.section+1) % filterItems.count;
                secondRow = 0;
            } else {
                secondSection = currentIndexPath.section;
                secondRow = currentIndexPath.row + 1;
            }
            firstIndexPath = currentIndexPath;
            secondIndexPath = [NSIndexPath indexPathForRow:secondRow inSection:secondSection];
        }
        [self.vm beginTwoLutFilter:firstIndexPath secondIndexPath:secondIndexPath split:leftToRight?0:1];
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        panOffset += point.x;
        CGFloat split = panOffset / self.interactionView.bounds.size.width;
        if (!leftToRight) {
            split = 1+split;
        }
        if (split < 0) {
            split = 0;
        }
        [self.vm updateTwoLutFilter:split];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        panOffset += point.x;
        CGFloat split = panOffset / self.interactionView.bounds.size.width;
        if (!leftToRight) {
            split = 1+split;
        }
        BOOL isFirst = split >= 0.5;
        if (fabs(velocity) > 800) {
            isFirst = leftToRight;
        }
        NSIndexPath *indexPath = isFirst ? firstIndexPath : secondIndexPath;
        NSIndexPath *lastIndexPath = self.vm.filterIndexPath;
        
        [self.vm endTwoLutFilter:indexPath];
        if (indexPath != lastIndexPath) {
            HPCameraCaptureViewFilterItem *lastItem = self.vm.filterItems[lastIndexPath.section][lastIndexPath.row];
            lastItem.selected = false;
            
            HPCameraCaptureViewFilterItem *currentItem = self.vm.filterItems[indexPath.section][indexPath.row];
            currentItem.selected = true;
            
            [self.filterView selectIndexPath:indexPath];
            [self showFilterAlertView:indexPath];
        }
        
        panOffset = 0;
        maxVelocity = 0;
        ignoredFirst = false;
    }
}


#pragma mark - Action

- (IBAction)recordClick:(UIButton *)sender {
    
    recording = !recording;
    [self resetView];
    if (recording) {
        [self.vm startRecording];
        
    } else {
        sender.enabled = false;
        [self.vm stopRecording:^{
             sender.enabled = true;
        }];
    }
}

- (IBAction)saveClick:(id)sender {
    recording = false;
    [self resetView];
    self.hudView.hidden = false;
    
    [self.vm saveMovie:^(BOOL succeed) {
        if (succeed) {
            self.hudView.hidden = true;
            [self pushToEditVideo];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"合成视频文件失败" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
        }
    }];
    
    [self resetView];
}

- (IBAction)delClick:(id)sender {
    [self.vm removeLastMovieFile];
    
    [self resetView];
    [self updateProgressView:self.vm.recordedTimePoints];
}

- (IBAction)rightTopClick:(UIButton *)sender {
    NSInteger index = sender.tag - 100;
    switch (index) {
        case 0:{
            [self.vm rotateCamera];
            [self resetView];
            break;
        }
        case 1:
            [self showFilterView];
            break;
        case 2:
            [self showBeautyView];
            break;
        case 3:
            [self.vm lightingSwitch];
            break;
            
        default:
            break;
    }
}


- (IBAction)beautyBGViewClick:(id)sender {
    [self showBeautyView];
}

- (IBAction)selectBeautyItem:(UIButton *)sender {
    selectedBeautyItem = sender.tag - 100;
    [self resetView];
}

- (IBAction)sliderDidChange:(UISlider *)sender {
    NSInteger index = selectedBeautyItem;
    CGFloat value = sender.value;
    [beautyValues replaceObjectAtIndex:index withObject:@(value)];
    
    [self update:index percent:value];
}

- (IBAction)resetBeauty:(id)sender {
    beautyValues = @[@(DefaultSmoothValue), @(DefaultThinFaceValue), @(DefaultBigEyeValue), @(DefaultLipstickValue), @(DefaultBlusherValue)].mutableCopy;
    [self resetView];
    
    NSInteger index = 0;
    while (index < beautyValues.count) {
        CGFloat value = [beautyValues[index] floatValue];
        [self update:index percent:value];
        index += 1;
    }
    
}

- (IBAction)backClick:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark -

- (void)showFilterView {
    showFilterView = !showFilterView;
    [self resetView];
}

- (void)showBeautyView {
    showBeautyView = !showBeautyView;
    [self resetView];
    
}

- (void)update:(NSInteger)index percent:(CGFloat)percent {
    CGFloat value = percent;
    switch (index) {
        case 0:
            [self.vm updateSmooth:value];
            break;
        case 1:
            [self.vm updateThinFace:value];
            break;
        case 2:
            [self.vm updateBigEye:value];
            break;
        case 3:
            [self.vm updateLipstick:value];
            break;
        case 4:
            [self.vm updateBlusher:value];
            break;
        default:
            break;
    }
}

- (void)pushToEditVideo {
    
    HPCameraEditViewModel *vm = [HPCameraEditViewModel new];
    vm.videoPath = self.vm.outputVideoFilePath;
    
    UIStoryboard *sd = [UIStoryboard storyboardWithName:@"Aweme" bundle:nil] ;
    HPVideoEditViewController *edit = (HPVideoEditViewController *)[sd instantiateViewControllerWithIdentifier:NSStringFromClass(HPVideoEditViewController.class)];
    edit.vm = vm;
    [self.navigationController pushViewController:edit animated:true];
    
}

- (void)dealloc {
    NSLog(@"HPCameraCaptureViewController dealloc");
}

@end


/*
 
 
 - (void)magnificate {
 videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
 //    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
 videoCamera.horizontallyMirrorFrontFacingCamera = true;
 
 magFilter = [[GPUImageMagnificationFilter alloc] init];
 
 [videoCamera addTarget:magFilter];
 [magFilter addTarget:self.preview];
 
 [videoCamera startCameraCapture];
 }
 
 */
