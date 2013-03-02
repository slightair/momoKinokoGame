//
//  MKGameEngine.m
//  momoKinokoGame
//
//  Created by slightair on 2013/03/02.
//  Copyright (c) 2013年 slightair. All rights reserved.
//

#import "MKGameEngine.h"
#import <cocos2d.h>
#import <BlocksKit.h>
#import "MKGameLayer.h"
#import "MKItem.h"

#define kHarvestItemSuccessScore 100
#define kHarvestItemFailureScore -200

// Notifications
NSString *const MKGameEngineNotificationUpdateScore = @"MKGameEngineNotificationUpdateScore";

// Notification User Info Keys
NSString *const MKGameEngineUpdatedScoreUserInfoKey = @"MKGameEngineUpdatedScore";

@interface MKGameEngine ()

- (void)itemDidReachHarvestArea:(NSNotification *)notification;

@property (nonatomic, assign) NSInteger score;

@end

@implementation MKGameEngine

+ (id)sharedEngine
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance;
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidReachHarvestArea:)
                                                     name:MKItemNotificationReachedItem
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startNewGame
{
    self.score = 0;

    id transition = [CCTransitionFade transitionWithDuration:1.0 scene:[MKGameLayer scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
}

- (void)itemDidReachHarvestArea:(NSNotification *)notification
{
    MKItemKind itemKind = [notification.userInfo[MKItemReachedItemKindUserInfoKey] integerValue];
    CGPoint location = [notification.userInfo[MKItemReachedLocationUserInfoKey] CGPointValue];

    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    if (location.x != 0 && location.x != windowSize.width) {
        return;
    }

    if (location.x == 0) {
        self.score += itemKind == MKItemKindPeach ? kHarvestItemSuccessScore : kHarvestItemFailureScore;
    }
    else if(location.x == windowSize.width) {
        self.score += itemKind == MKItemKindMushroom ? kHarvestItemSuccessScore : kHarvestItemFailureScore;
    }
}

- (void)setScore:(NSInteger)score
{
    _score = score;

    [[NSNotificationCenter defaultCenter] postNotificationName:MKGameEngineNotificationUpdateScore
                                                        object:self
                                                      userInfo:@{MKGameEngineUpdatedScoreUserInfoKey: @(_score)}];
}

@end
