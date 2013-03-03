//
//  MKIntroLayer.m
//  momoKinokoGame
//
//  Created by slightair on 2013/02/20.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKIntroLayer.h"
#import "MKGameEngine.h"

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

    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)onExit
{
    [super onExit];

    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [[MKGameEngine sharedEngine] startNewGame];
}

@end
