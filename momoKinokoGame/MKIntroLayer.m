//
//  MKIntroLayer.m
//  momoKinokoGame
//
//  Created by slightair on 2013/02/20.
//  Copyright 2013年 slightair. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "MKAppDelegate.h"
#import "MKMainViewController.h"
#import "MKIntroLayer.h"
#import "MKGameEngine.h"
#import "CCLabelTTF+MKHelper.h"

#define kMenuItemFontName @"Chalkboard SE"
#define kMenuItemVerticalPadding 24

#define kTitleLabelFontName @"HiraKakuProN-W6"
#define kLabelFontSize 24

@implementation MKIntroLayer

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    MKIntroLayer *layer = [MKIntroLayer node];

    [scene addChild:layer];

    return scene;
}

- (void)onEnter
{
    [super onEnter];

    CGSize windowSize = [[CCDirector sharedDirector] winSize];

    CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
    background.position = ccp(windowSize.width / 2, windowSize.height / 2);
    [self addChild:background];

    CCLabelTTF *extremeLabel = [CCLabelTTF labelWithTitle:@"エクストリーム" fontName:kTitleLabelFontName fontSize:kLabelFontSize];
    extremeLabel.position = ccp(windowSize.width / 2, windowSize.height / 2 + 100);
    [self addChild:extremeLabel];

    CCLabelTTF *titleLabel = [CCLabelTTF labelWithTitle:@"もも・きのこ狩り" fontName:kTitleLabelFontName fontSize:kLabelFontSize];
    titleLabel.position = ccp(windowSize.width / 2, windowSize.height / 2 + 60);
    [self addChild:titleLabel];

    CCMenuItem *startGameItem = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithTitle:@"Start!!" fontName:kMenuItemFontName fontSize:kLabelFontSize]
                                                           block:^(id sender){
                                                               [[MKGameEngine sharedEngine] startNewGame];
                                                           }];
    CCMenuItem *showRankingItem = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithTitle:@"Ranking" fontName:kMenuItemFontName fontSize:kLabelFontSize]
                                                             block:^(id sender){
                                                                 MKAppDelegate *appDelegate = (MKAppDelegate *)[UIApplication sharedApplication].delegate;
                                                                 MKMainViewController *mainViewController = appDelegate.mainViewController;
                                                                 [mainViewController showLeaderboard];
                                                             }];

    CCMenu *menu = [CCMenu menuWithArray:@[startGameItem, showRankingItem]];
    [menu alignItemsVerticallyWithPadding:kMenuItemVerticalPadding];
    menu.position = ccp(windowSize.width / 2, windowSize.height / 2 - 160);
    [self addChild:menu];
}

@end
