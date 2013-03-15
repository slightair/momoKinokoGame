//
//  MKAppDelegate.h
//  momoKinokoGame
//
//  Created by slightair on 2013/02/20.
//  Copyright (c) 2013年 slightair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <cocos2d.h>
#import "MKMainViewController.h"

@interface MKAppDelegate : UIResponder <UIApplicationDelegate, CCDirectorDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong, readonly) MKMainViewController *mainViewController;

@end
