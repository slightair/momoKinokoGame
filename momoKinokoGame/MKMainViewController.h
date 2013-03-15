//
//  MKMainViewController.h
//  momoKinokoGame
//
//  Created by slightair on 2013/03/15.
//  Copyright (c) 2013年 slightair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface MKMainViewController : UINavigationController <GKLeaderboardViewControllerDelegate>

- (void)showLeaderboard;

@end
