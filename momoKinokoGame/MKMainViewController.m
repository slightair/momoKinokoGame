//
//  MKMainViewController.m
//  momoKinokoGame
//
//  Created by slightair on 2013/03/15.
//  Copyright (c) 2013年 slightair. All rights reserved.
//

#import "MKMainViewController.h"

@interface MKMainViewController ()

@end

@implementation MKMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLeaderboard
{
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = self;
    [self presentViewController:leaderboardViewController
                       animated:YES
                     completion:NULL];
}

#pragma mark -
#pragma mark GKLeaderboardViewControllerDelegate methods

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
