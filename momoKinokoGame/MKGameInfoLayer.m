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

    CGFloat scoreLabelOriginX = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? kScoreLabelOriginXiPad : kScoreLabelOriginXiPhone;
    CGFloat scoreLabelOriginY = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? kScoreLabelOriginYiPad : kScoreLabelOriginYiPhone;

    self.scoreLabel.position = ccp(scoreLabelOriginX, windowSize.height - scoreLabelOriginY - kScoreLabelFontSize);
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
