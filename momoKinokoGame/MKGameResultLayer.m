//
//  MKGameResultLayer.m
//  momoKinokoGame
//
//  Created by slightair on 2013/03/03.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKGameResultLayer.h"
#import "MKGameEngine.h"
#import "MKItem.h"

#define kLabelFontName @"Chalkboard SE"
#define kLabelFontSize 24
#define kHarvestedItemLabelInterval 28

@interface MKGameResultLayer ()

- (void)addTitleLabel:(NSString *)title position:(CGPoint)position;
- (void)addItemResult:(MKItemID)itemID count:(NSInteger)count position:(CGPoint)position;

@end

@implementation MKGameResultLayer

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    MKGameResultLayer *layer = [MKGameResultLayer node];

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

    MKGameEngine *gameEngine = [MKGameEngine sharedEngine];
    CGFloat offsetY = windowSize.height / 2 + 150;
    for (NSNumber *itemID in [[gameEngine.harvestedItems allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        [self addItemResult:[itemID integerValue] count:[gameEngine.harvestedItems[itemID] integerValue] position:ccp(windowSize.width / 2, offsetY)];
        offsetY -= kHarvestedItemLabelInterval;
    }

    NSString *scoreString = [NSString stringWithFormat:@"Score: %d", gameEngine.score];
    [self addTitleLabel:@"Result" position:ccp(windowSize.width / 2, windowSize.height / 2 + 200)];
    [self addTitleLabel:scoreString position:ccp(windowSize.width / 2, windowSize.height / 2 - 90)];
    [self addTitleLabel:@"Retry!!" position:ccp(windowSize.width / 2, windowSize.height / 2 - 160)];

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

- (void)addItemResult:(MKItemID)itemID count:(NSInteger)count position:(CGPoint)position
{
    CGSize shadowOffset = CGSizeMake(1, -1);
    NSString *countString = [NSString stringWithFormat:@"x %d", count];

    CCSprite *item = [CCSprite spriteWithFile:[MKItem imageFileNameOfItemID:itemID]];
    CGFloat offsetX = -item.textureRect.size.width / 2;
    item.anchorPoint = ccp(1.0, 0.5);
    item.position = ccp(position.x + offsetX, position.y);
    [self addChild:item];

    CGPoint labelPosition = ccp(position.x + offsetX, position.y);
    CCLabelTTF *shadowLabel = [CCLabelTTF labelWithString:countString fontName:kLabelFontName fontSize:kLabelFontSize];
    shadowLabel.anchorPoint = ccp(0.0, 0.5);
    shadowLabel.position = ccp(labelPosition.x + shadowOffset.width, labelPosition.y + shadowOffset.height);
    shadowLabel.color = ccc3(0, 0, 0);
    [self addChild:shadowLabel];

    CCLabelTTF *label = [CCLabelTTF labelWithString:countString fontName:kLabelFontName fontSize:kLabelFontSize];
    label.anchorPoint = ccp(0.0, 0.5);
    label.position = labelPosition;
    [self addChild:label];
}

@end
