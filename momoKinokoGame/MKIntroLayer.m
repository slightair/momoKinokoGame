//
//  MKIntroLayer.m
//  momoKinokoGame
//
//  Created by slightair on 2013/02/20.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKIntroLayer.h"
#import "MKGameEngine.h"

#define kTitleLabelFontName @"HiraKakuProN-W6"
#define kStartLabelFontName @"Chalkboard SE"
#define kLabelFontSize 24

@interface MKIntroLayer ()

- (void)addLabel:(NSString *)title position:(CGPoint)position fontName:(NSString *)fontName;

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

    [self addLabel:@"エクストリーム" position:ccp(windowSize.width / 2, windowSize.height / 2 + 100) fontName:kTitleLabelFontName];
    [self addLabel:@"もも・きのこ狩り" position:ccp(windowSize.width / 2, windowSize.height / 2 + 60) fontName:kTitleLabelFontName];
    [self addLabel:@"Start!!" position:ccp(windowSize.width / 2, windowSize.height / 2 - 80) fontName:kStartLabelFontName];

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

- (void)addLabel:(NSString *)title position:(CGPoint)position fontName:(NSString *)fontName
{
    CGSize shadowOffset = CGSizeMake(1, -1);

    CCLabelTTF *shadowLabel = [CCLabelTTF labelWithString:title fontName:fontName fontSize:kLabelFontSize];
    shadowLabel.position = ccp(position.x + shadowOffset.width, position.y + shadowOffset.height);
    shadowLabel.color = ccc3(0, 0, 0);
    [self addChild:shadowLabel];

    CCLabelTTF *label = [CCLabelTTF labelWithString:title fontName:fontName fontSize:kLabelFontSize];
    label.position = position;
    [self addChild:label];
}

@end
