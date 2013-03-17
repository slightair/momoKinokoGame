//
//  MKGameEngine.m
//  momoKinokoGame
//
//  Created by slightair on 2013/03/02.
//  Copyright (c) 2013年 slightair. All rights reserved.
//

#import "MKGameEngine.h"
#import <cocos2d.h>
#import "MKIntroLayer.h"
#import "MKGameLayer.h"
#import "MKGameResultLayer.h"
#import "MKItem.h"
#import "MKSpecialItem.h"
#import "MKPlayer.h"

#define kTransitionDuration 1.0
#define kHarvestItemSuccessScore 100
#define kHarvestItemFailureScore -200
#define kGameTime 30.0
#define kWaitAfterGameFinishedDuration 3.0
#define kTimeStopTime 5.0
#define kSpecialItemSupplyScoreInterval 1000

#define kLeaderboardIDHighScores @"momoKinokoGame.highScore"
#define kLeaderboardIDLowScores @"momoKinokoGame.lowScore"

// Notifications
NSString *const MKGameEngineNotificationUpdateScore = @"MKGameEngineNotificationUpdateScore";
NSString *const MKGameEngineNotificationPlayerObtainScore = @"MKGameEngineNotificationPlayerObtainScore";
NSString *const MKGameEngineNotificationStartTimeStop = @"MKGameEngineNotificationStartTimeStop";
NSString *const MKGameEngineNotificationFinishTimeStop = @"MKGameEngineNotificationFinishTimeStop";
NSString *const MKGameEngineNotificationGameFinished = @"MKGameEngineNotificationGameFinished";
NSString *const MKGameEngineNotificationSupplySpecialItem = @"MKGameEngineNotificationSupplySpecialItem";

// Notification User Info Keys
NSString *const MKGameEngineUpdatedScoreUserInfoKey = @"MKGameEngineUpdatedScore";
NSString *const MKGameEnginePlayerObtainedScoreUserInfoKey = @"MKGameEnginePlayerObtainedScore";
NSString *const MKGameEngineItemReachedLocationUserInfoKey = @"MKGameEngineItemReachedLocation";

@interface MKGameEngine ()

- (void)itemDidReachHarvestArea:(NSNotification *)notification;
- (void)specialItemDidTouch:(NSNotification *)notification;
- (void)tick:(NSTimer *)timer;
- (void)finishGame;
- (void)submitScore;

@property (nonatomic, assign) NSInteger score;
@property (nonatomic, strong) NSTimer *gameTimer;
@property (nonatomic, assign) NSTimeInterval remainTime;
@property (nonatomic, strong) NSDictionary *harvestedItems;
@property (nonatomic, assign) BOOL isTimeStop;
@property (nonatomic, assign) NSTimeInterval remainTimeStopTime;
@property (nonatomic, assign) BOOL specialItemCount;
@property (nonatomic, strong) MKPlayer *player;

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
        self.enableGameCenter = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidReachHarvestArea:)
                                                     name:MKItemNotificationReachedItem
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(specialItemDidTouch:)
                                                     name:MKSpecialItemNotificationDidTouchItem
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
    self.remainTime = kGameTime + kTransitionDuration;
    self.remainTimeStopTime = 0.0;
    self.isTimeStop = NO;
    self.specialItemCount = 0;
    self.harvestedItems = [NSMutableDictionary dictionaryWithDictionary:@{
                           @(MKItemIDMushroomAkaKinoko): @(0),
                           @(MKItemIDMushroomHashiraDake): @(0),
                           @(MKItemIDMushroomHukuroDake): @(0),
                           @(MKItemIDMushroomAoKinoko): @(0),
                           @(MKItemIDMushroomKasaKinoko): @(0),
                           @(MKItemIDPeachBamiyan): @(0),
                           @(MKItemIDPeachOutou): @(0),
                           @(MKItemIDPeachHakutou): @(0)}];

    id transition = [CCTransitionFade transitionWithDuration:kTransitionDuration scene:[MKGameLayer scene]];
    [[CCDirector sharedDirector] replaceScene:transition];

    if (self.gameTimer) {
        [self.gameTimer invalidate];
    }
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:MKGameEngineGameTimerInterval
                                                      target:self
                                                    selector:@selector(tick:)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)showTitle
{
    id transition = [CCTransitionFade transitionWithDuration:kTransitionDuration scene:[MKIntroLayer scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
}

- (void)tick:(NSTimer *)timer
{
    if (self.isTimeStop) {
        self.remainTimeStopTime -= MKGameEngineGameTimerInterval;

        if (self.remainTimeStopTime < 0) {
            self.isTimeStop = NO;

            [[NSNotificationCenter defaultCenter] postNotificationName:MKGameEngineNotificationFinishTimeStop
                                                                object:self];
        }
    }
    else {
        self.remainTime -= MKGameEngineGameTimerInterval;

        if (self.remainTime < 0) {
            [timer invalidate];
            self.gameTimer = nil;

            [self finishGame];
        }
    }
}

- (void)finishGame
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MKGameEngineNotificationGameFinished
                                                        object:self];

    double delayInSeconds = kWaitAfterGameFinishedDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.enableGameCenter) {
            [self submitScore];
        }

        id transition = [CCTransitionFade transitionWithDuration:kTransitionDuration scene:[MKGameResultLayer scene]];
        [[CCDirector sharedDirector] replaceScene:transition];
    });
}

- (void)itemDidReachHarvestArea:(NSNotification *)notification
{
    MKItemID itemID = [notification.userInfo[MKItemReachedItemIDUserInfoKey] integerValue];
    MKItemKind itemKind = [notification.userInfo[MKItemReachedItemKindUserInfoKey] integerValue];
    CGPoint location = [notification.userInfo[MKItemReachedLocationUserInfoKey] CGPointValue];

    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    if (location.x != 0 && location.x != windowSize.width) {
        return;
    }

    NSInteger obtainedScore = 0;
    if (location.x == 0) {
        obtainedScore = itemKind == MKItemKindPeach ? kHarvestItemSuccessScore : kHarvestItemFailureScore;
    }
    else if(location.x == windowSize.width) {
        obtainedScore = itemKind == MKItemKindMushroom ? kHarvestItemSuccessScore : kHarvestItemFailureScore;
    }
    self.score += obtainedScore;

    if (obtainedScore > 0) {
        NSInteger count = [self.harvestedItems[@(itemID)] integerValue];
        [(NSMutableDictionary *)self.harvestedItems setObject:@(count + 1) forKey:@(itemID)];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:MKGameEngineNotificationPlayerObtainScore
                                                        object:self
                                                      userInfo:@{MKGameEnginePlayerObtainedScoreUserInfoKey: @(obtainedScore),
                                                                 MKGameEngineItemReachedLocationUserInfoKey: notification.userInfo[MKItemReachedLocationUserInfoKey]}];
}

- (void)specialItemDidTouch:(NSNotification *)notification
{
    if (self.isTimeStop) {
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:MKGameEngineNotificationStartTimeStop
                                                        object:self
                                                      userInfo:notification.userInfo];

    self.remainTimeStopTime = kTimeStopTime;
    self.isTimeStop = YES;
}

- (void)submitScore
{
    GKScore *highScore = [[GKScore alloc] initWithCategory:kLeaderboardIDHighScores];
    highScore.value = self.score;
    [self.player submitScore:highScore];

    GKScore *lowScore = [[GKScore alloc] initWithCategory:kLeaderboardIDLowScores];
    lowScore.value = self.score;
    [self.player submitScore:lowScore];
}

- (void)setScore:(NSInteger)score
{
    _score = score;

    [[NSNotificationCenter defaultCenter] postNotificationName:MKGameEngineNotificationUpdateScore
                                                        object:self
                                                      userInfo:@{MKGameEngineUpdatedScoreUserInfoKey: @(_score)}];

    if (_score >= kSpecialItemSupplyScoreInterval * (self.specialItemCount + 1)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MKGameEngineNotificationSupplySpecialItem
                                                            object:self];
        self.specialItemCount++;
    }
}

- (void)setCurrentPlayerID:(NSString *)currentPlayerID
{
    if ([_currentPlayerID isEqualToString:currentPlayerID]) {
        return;
    }

    _currentPlayerID = currentPlayerID;

    self.player = [[MKPlayer alloc] init];
    [self.player loadStoredScores];
    [self.player resubmitStoredScores];
}

@end
