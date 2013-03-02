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
#define kScoreLabelOriginX 24
#define kScoreLabelOriginY 24

@interface MKGameInfoLayer ()

- (void)gameEngineDidUpdateScore:(NSNotification *)notification;
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

    self.scoreLabel = [CCLabelTTF labelWithString:@"" fontName:@"Chalkboard SE" fontSize:kScoreLabelFontSize];
    self.scoreLabel.anchorPoint = ccp(0.0, 0.0);
    self.scoreLabel.position = ccp(kScoreLabelOriginX, windowSize.height - kScoreLabelOriginY - kScoreLabelFontSize);
    [self updateScore:0];

    [self addChild:self.scoreLabel];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameEngineDidUpdateScore:)
                                                 name:MKGameEngineNotificationUpdateScore
                                               object:nil];
}

- (void)gameEngineDidUpdateScore:(NSNotification *)notification
{
    NSInteger newScore = [notification.userInfo[MKGameEngineUpdatedScoreUserInfoKey] integerValue];
    [self updateScore:newScore];
}

- (void)updateScore:(NSInteger)score
{
    self.scoreLabel.string = [NSString stringWithFormat:@"Score: %d", score];
}

@end
