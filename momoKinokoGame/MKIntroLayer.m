//
//  MKIntroLayer.m
//  momoKinokoGame
//
//  Created by slightair on 2013/02/20.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKIntroLayer.h"

#define kMushroomSize 24
#define kNumberOfMushroomKind 5
#define kHorizontalMargin 24
#define kItemRotationAngle 360
#define kItemFallingDuration 1.0

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

    [self schedule:@selector(addMushroom) interval:0.01];
}

- (void)addMushroom
{
    CGSize windowSize = [[CCDirector sharedDirector] winSize];

    NSString *fileName = [NSString stringWithFormat:@"mushroom%d.png", arc4random() % kNumberOfMushroomKind + 1];
    NSInteger emergedAreaWidth = windowSize.width - kHorizontalMargin * 2;
    CGFloat positionX = arc4random() % emergedAreaWidth + kHorizontalMargin;

    CCSprite *mushroom = [CCSprite spriteWithFile:fileName];
    mushroom.position = ccp(positionX, windowSize.height + kMushroomSize / 2);

    id fallAction = [CCSpawn actions:
                     [CCMoveTo actionWithDuration:kItemFallingDuration position:ccp(positionX, -kMushroomSize / 2)],
                     [CCRotateBy actionWithDuration:kItemFallingDuration angle:kItemRotationAngle],
                     nil];
    id action = [CCSequence actions:
                 fallAction,
                 [CCCallFuncND actionWithTarget:mushroom selector:@selector(removeFromParentAndCleanup:) data:(void *)YES],
                 nil];

    [mushroom runAction:action];

    [self addChild:mushroom];
}

@end
