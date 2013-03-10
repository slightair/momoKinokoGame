//
//  MKGameInfoLayer.m
//  momoKinokoGame
//
//  Created by slightair on 2013/03/02.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKGameInfoLayer.h"
#import "MKGameEngine.h"

#define kLabelFontSize 18
#define kRemainTimeStopTimeLabelFontSize 180
#define kLabelOriginXiPhone 10
#define kLabelOriginYiPhone 8
#define kLabelOriginXiPad 24
#define kLabelOriginYiPad 20
#define kLabelFontName @"Chalkboard SE"
#define kLabelKeepDuration 1.0
#define kLabelFadeOutDuration 1.0
#define kObtainedScoreLabelMarginHorizontal 10
#define kLabelColorIncreaseScore ccc3(255, 255, 255)
#define kLabelColorDecreaseScore ccc3(255, 0, 0)
#define kFinishLabelFontSize 64
#define kFinishLabelScaleUpDuration 1.0
#define kFinishLabelKeepDuration 0.3
#define kFinishLabelScaleMin 0.3
#define kRemainTimeStopTimeLabelOpacity 64

@interface MKGameInfoLayer ()

- (void)gameEngineDidUpdateScore:(NSNotification *)notification;
- (void)updateScore:(NSInteger)score;
- (void)updateRemainTime;
- (void)playerDidObtainScore:(NSNotification *)notification;
- (void)gameEngineDidFinish:(NSNotification *)notification;

@property (nonatomic, strong) CCLabelTTF *scoreLabel;
@property (nonatomic, strong) CCLabelTTF *remainTimeLabel;
@property (nonatomic, strong) CCLabelTTF *remainTimeStopTimeLabel;

@end

@implementation MKGameInfoLayer

- (void)onEnter
{
    [super onEnter];

    CGSize windowSize = [[CCDirector sharedDirector] winSize];

    CGFloat labelOriginX = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? kLabelOriginXiPad : kLabelOriginXiPhone;
    CGFloat labelOriginY = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? kLabelOriginYiPad : kLabelOriginYiPhone;

    self.scoreLabel = [CCLabelTTF labelWithString:@"" fontName:kLabelFontName fontSize:kLabelFontSize];
    self.scoreLabel.anchorPoint = ccp(0.0, 1.0);
    self.scoreLabel.position = ccp(labelOriginX, windowSize.height - labelOriginY);
    [self updateScore:0];

    self.remainTimeLabel = [CCLabelTTF labelWithString:@"" fontName:kLabelFontName fontSize:kLabelFontSize];
    self.remainTimeLabel.anchorPoint = ccp(1.0, 1.0);
    self.remainTimeLabel.position = ccp(windowSize.width - labelOriginX, windowSize.height - labelOriginY);

    self.remainTimeStopTimeLabel = [CCLabelTTF labelWithString:@"" fontName:kLabelFontName fontSize:kRemainTimeStopTimeLabelFontSize];
    self.remainTimeStopTimeLabel.position = ccp(windowSize.width / 2, windowSize.height / 2);
    self.remainTimeStopTimeLabel.opacity = kRemainTimeStopTimeLabelOpacity;

    [self addChild:self.scoreLabel];
    [self addChild:self.remainTimeLabel];
    [self addChild:self.remainTimeStopTimeLabel];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameEngineDidUpdateScore:)
                                                 name:MKGameEngineNotificationUpdateScore
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidObtainScore:)
                                                 name:MKGameEngineNotificationPlayerObtainScore
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameEngineDidFinish:)
                                                 name:MKGameEngineNotificationGameFinished
                                               object:nil];

    [self schedule:@selector(updateRemainTime) interval:MKGameEngineGameTimerInterval];
}

- (void)onExit
{
    [super onExit];

    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)gameEngineDidUpdateScore:(NSNotification *)notification
{
    NSInteger newScore = [notification.userInfo[MKGameEngineUpdatedScoreUserInfoKey] integerValue];
    [self updateScore:newScore];
}

- (void)playerDidObtainScore:(NSNotification *)notification
{
    NSInteger obtainedScore = [notification.userInfo[MKGameEnginePlayerObtainedScoreUserInfoKey] integerValue];
    CGPoint location = [notification.userInfo[MKGameEngineItemReachedLocationUserInfoKey] CGPointValue];

    NSString *displayScoreString = [NSString stringWithFormat:@"%d", obtainedScore];
    CGFloat adjustmentLabelPositionX = location.x == 0 ? kObtainedScoreLabelMarginHorizontal : -kObtainedScoreLabelMarginHorizontal;
    CCLabelTTF *obtainedScoreLabel = [CCLabelTTF labelWithString:displayScoreString fontName:kLabelFontName fontSize:kLabelFontSize];
    obtainedScoreLabel.color = obtainedScore > 0 ? kLabelColorIncreaseScore : kLabelColorDecreaseScore;
    obtainedScoreLabel.anchorPoint = location.x == 0 ? ccp(0.0, 0.5) : ccp(1.0, 0.5);
    obtainedScoreLabel.position = ccp(location.x + adjustmentLabelPositionX, location.y);

    [self addChild:obtainedScoreLabel];

    id action = [CCSequence actions:
                 [CCDelayTime actionWithDuration:kLabelKeepDuration],
                 [CCFadeOut actionWithDuration:kLabelFadeOutDuration],
                 [CCCallFuncND actionWithTarget:obtainedScoreLabel selector:@selector(removeFromParentAndCleanup:) data:(void *)YES],
                 nil];
    [obtainedScoreLabel runAction:action];
}

- (void)updateScore:(NSInteger)score
{
    self.scoreLabel.string = [NSString stringWithFormat:@"Score: %d", score];
}

- (void)updateRemainTime
{
    NSTimeInterval remainTime = [[MKGameEngine sharedEngine] remainTime];
    if (remainTime < 0) {
        remainTime = 0;
    }
    self.remainTimeLabel.string = [NSString stringWithFormat:@"Time: %.1f", remainTime];

    NSTimeInterval remainTimeStopTime = [[MKGameEngine sharedEngine] remainTimeStopTime];
    NSString *remainTimeStopTimeLabelString = @"";
    if (remainTimeStopTime > 0) {
        remainTimeStopTimeLabelString = [NSString stringWithFormat:@"%.f", ceil(remainTimeStopTime)];
    }
    self.remainTimeStopTimeLabel.string = remainTimeStopTimeLabelString;
}

- (void)gameEngineDidFinish:(NSNotification *)notification
{
    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    CCLabelTTF *finishLabel = [CCLabelTTF labelWithString:@"Finish!!" fontName:kLabelFontName fontSize:kFinishLabelFontSize];
    finishLabel.position = ccp(windowSize.width / 2, windowSize.height / 2);
    finishLabel.scale = kFinishLabelScaleMin;
    [self addChild:finishLabel];

    id action = [CCSequence actions:
                 [CCScaleTo actionWithDuration:kFinishLabelScaleUpDuration scale:1.0],
                 [CCDelayTime actionWithDuration:kFinishLabelKeepDuration],
                 [CCFadeOut actionWithDuration:kLabelFadeOutDuration],
                 [CCCallFuncND actionWithTarget:finishLabel selector:@selector(removeFromParentAndCleanup:) data:(void *)YES],
                 nil];
    [finishLabel runAction:action];
}

@end
