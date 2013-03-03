//
//  MKIntroLayer.m
//  momoKinokoGame
//
//  Created by slightair on 2013/02/20.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKIntroLayer.h"
#import "MKGameEngine.h"

#define kLabelFontName @"HiraKakuProN-W6"
#define kLabelFontSize 24

@interface MKIntroLayer ()

- (void)addTitleLabel:(NSString *)title position:(CGPoint)position;

@end

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

    [self addTitleLabel:@"エクストリーム" position:ccp(windowSize.width / 2, windowSize.height / 2 + 100)];
    [self addTitleLabel:@"もも・きのこ狩り" position:ccp(windowSize.width / 2, windowSize.height / 2 + 60)];
    [self addTitleLabel:@"はじめる" position:ccp(windowSize.width / 2, windowSize.height / 2 - 80)];

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

- (void)addTitleLabel:(NSString *)title position:(CGPoint)position
{
    CGSize shadowOffset = CGSizeMake(1, -1);

    CCLabelTTF *shadowLabel = [CCLabelTTF labelWithString:title fontName:kLabelFontName fontSize:kLabelFontSize];
    shadowLabel.position = ccp(position.x + shadowOffset.width, position.y + shadowOffset.height);
    shadowLabel.color = ccc3(0, 0, 0);
    [self addChild:shadowLabel];

    CCLabelTTF *label = [CCLabelTTF labelWithString:title fontName:kLabelFontName fontSize:kLabelFontSize];
    label.position = position;
    [self addChild:label];
}

@end
