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
#import "CCLabelTTF+MKHelper.h"

#define kLabelFontName @"Chalkboard SE"
#define kLabelFontSize 24
#define kHarvestedItemLabelInterval 28

@interface MKGameResultLayer ()

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
    CGFloat offsetY = windowSize.height / 2 + 130;
    for (NSNumber *itemID in [[gameEngine.harvestedItems allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        [self addItemResult:[itemID integerValue] count:[gameEngine.harvestedItems[itemID] integerValue] position:ccp(windowSize.width / 2, offsetY)];
        offsetY -= kHarvestedItemLabelInterval;
    }

    CCLabelTTF *resultLabel = [CCLabelTTF labelWithTitle:@"Result" fontName:kLabelFontName fontSize:kLabelFontSize];
    resultLabel.position = ccp(windowSize.width / 2, windowSize.height / 2 + 180);
    [self addChild:resultLabel];

    CCLabelTTF *scoreLabel = [CCLabelTTF labelWithTitle:[NSString stringWithFormat:@"Score: %d", gameEngine.score]
                                                fontName:kLabelFontName
                                                fontSize:kLabelFontSize];
    scoreLabel.position = ccp(windowSize.width / 2, windowSize.height / 2 - 110);
    [self addChild:scoreLabel];

    CCMenuItem *retryGameItem = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithTitle:@"Retry!!"
                                                                                 fontName:kLabelFontName
                                                                                 fontSize:kLabelFontSize]
                                                         block:^(id sender){
                                                             [[MKGameEngine sharedEngine] startNewGame];
                                                         }];

    CCMenu *menu = [CCMenu menuWithArray:@[retryGameItem]];
    menu.position = ccp(windowSize.width / 2, windowSize.height / 2 - 160);
    [self addChild:menu];
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
