//
//  ViewController.m
//  AwemeLike
//
//  Created by wang on 2019/11/30.
//  Copyright © 2019 wang. All rights reserved.
//

#import "HPPlayerViewController.h"
#import "HPCameraCaptureViewController.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)camera:(id)sender {
    UIStoryboard *sd = [UIStoryboard storyboardWithName:@"Aweme" bundle:nil] ;
    HPCameraCaptureViewController *camera = (HPCameraCaptureViewController *)[sd instantiateViewControllerWithIdentifier:NSStringFromClass(HPCameraCaptureViewController.class)];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:camera] animated:true completion:nil];
}

- (IBAction)play:(id)sender {
    HPPlayerViewController *player = [HPPlayerViewController new];
    player.title = @"Player";
    [self presentViewController:player animated:true completion:nil];
}


@end
