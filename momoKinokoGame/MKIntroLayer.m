//
//  MKIntroLayer.m
//  momoKinokoGame
//
//  Created by slightair on 2013/02/20.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKIntroLayer.h"

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

    NSInteger numMushrooms = 100;
    NSInteger adjustX = 12;
    CGFloat delayMax = 10.0;
    NSInteger delaySteps = 64;

    for (int i=0; i<numMushrooms; i++) {
        NSString *fileName = [NSString stringWithFormat:@"mushroom%d.png", arc4random() % 5 + 1];
        CGFloat width = windowSize.width / numMushrooms * i + adjustX;
        CCSprite *mushroom = [CCSprite spriteWithFile:fileName];
        mushroom.position = ccp(width, windowSize.height + 12);

        id fallAction = [CCSpawn actions:
                         [CCMoveTo actionWithDuration:1.0 position:ccp(width, 12)],
                         [CCRotateBy actionWithDuration:1.0 angle:360],
                         nil];
        id action = [CCSequence actions:
                     [CCDelayTime actionWithDuration:(arc4random() % delaySteps) * (delayMax / delaySteps)],
                     fallAction,
                     nil];

        [mushroom runAction:action];

        [self addChild:mushroom];
    }
}

@end
