//
//  MKGameInfoLayer.m
//  momoKinokoGame
//
//  Created by slightair on 2013/03/02.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKGameInfoLayer.h"
#import "MKGameEngine.h"

#define kScoreLabelFontSize 18
#define kScoreLabelOriginXiPhone 10
#define kScoreLabelOriginYiPhone 10
#define kScoreLabelOriginXiPad 24
#define kScoreLabelOriginYiPad 24
#define kLabelFontName @"Chalkboard SE"
#define kLabelFadeOutDuration 1.0
#define kObtainedScoreLabelMarginHorizontal 10
#define kLabelColorIncreaseScore ccc3(255, 255, 255)
#define kLabelColorDecreaseScore ccc3(255, 0, 0)

@interface MKGameInfoLayer ()

- (void)gameEngineDidUpdateScore:(NSNotification *)notification;
- (void)playerDidObtainScore:(NSNotification *)notification;
- (void)updateScore:(NSInteger)score;

@property (nonatomic, strong) CCLabelTTF *scoreLabel;

@end

@implementation MKGameInfoLayer


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onEnter
{
    [super onEnter];

    CGSize windowSize = [[CCDirector sharedDirector] winSize];

    self.scoreLabel = [CCLabelTTF labelWithString:@"" fontName:kLabelFontName fontSize:kScoreLabelFontSize];
    self.scoreLabel.anchorPoint = ccp(0.0, 1.0);

    CGFloat scoreLabelOriginX = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? kScoreLabelOriginXiPad : kScoreLabelOriginXiPhone;
    CGFloat scoreLabelOriginY = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? kScoreLabelOriginYiPad : kScoreLabelOriginYiPhone;

    self.scoreLabel.position = ccp(scoreLabelOriginX, windowSize.height - scoreLabelOriginY);
    [self updateScore:0];

    [self addChild:self.scoreLabel];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameEngineDidUpdateScore:)
                                                 name:MKGameEngineNotificationUpdateScore
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidObtainScore:)
                                                 name:MKGameEngineNotificationPlayerObtainScore
                                               object:nil];
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
    CCLabelTTF *obtainedScoreLabel = [CCLabelTTF labelWithString:displayScoreString fontName:kLabelFontName fontSize:kScoreLabelFontSize];
    obtainedScoreLabel.color = obtainedScore > 0 ? kLabelColorIncreaseScore : kLabelColorDecreaseScore;
    obtainedScoreLabel.anchorPoint = location.x == 0 ? ccp(0.0, 0.5) : ccp(1.0, 0.5);
    obtainedScoreLabel.position = ccp(location.x + adjustmentLabelPositionX, location.y);

    [self addChild:obtainedScoreLabel];

    id action = [CCSequence actions:
                 [CCFadeOut actionWithDuration:kLabelFadeOutDuration],
                 [CCCallFuncND actionWithTarget:obtainedScoreLabel selector:@selector(removeFromParentAndCleanup:) data:(void *)YES],
                 nil];
    [obtainedScoreLabel runAction:action];
}

- (void)updateScore:(NSInteger)score
{
    self.scoreLabel.string = [NSString stringWithFormat:@"Score: %d", score];
}

@end
