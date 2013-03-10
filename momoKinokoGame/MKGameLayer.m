//
//  MKGameLayer.m
//  momoKinokoGame
//
//  Created by slightair on 2013/02/23.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKGameLayer.h"
#import "MKGameInfoLayer.h"
#import "MKFreezeEffectLayer.h"
#import "MKItem.h"
#import "MKSpecialItem.h"
#import "MKGameEngine.h"

#define kAddItemInterval 0.05
#define kEmergedAreaHorizontalMarginRate 0.1
#define kGameInfoLayerZOrder 100
#define kFreezeEffectLayerZOrder 10
#define kSpecialItemZOrder 20

@interface MKGameLayer ()

- (void)addItem;
- (void)gameEngineDidStartTimeStop:(NSNotification *)notification;
- (void)gameEngineDidFinishTimeStop:(NSNotification *)notification;
- (void)gameEngineDidFinish:(NSNotification *)notification;

@property (nonatomic, strong) MKGameInfoLayer *infoLayer;
@property (nonatomic, strong) MKFreezeEffectLayer *freezeEffectLayer;

@end

@implementation MKGameLayer

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    MKGameLayer *layer = [MKGameLayer node];

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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameEngineDidStartTimeStop:)
                                                 name:MKGameEngineNotificationStartTimeStop
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameEngineDidFinishTimeStop:)
                                                 name:MKGameEngineNotificationFinishTimeStop
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameEngineDidFinish:)
                                                 name:MKGameEngineNotificationGameFinished
                                               object:nil];
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];

    self.infoLayer = [MKGameInfoLayer node];
    [self addChild:self.infoLayer z:kGameInfoLayerZOrder];

    self.freezeEffectLayer = [MKFreezeEffectLayer node];
    [self addChild:self.freezeEffectLayer z:kFreezeEffectLayerZOrder];

    [self schedule:@selector(addItem) interval:kAddItemInterval];
}

- (void)onExit
{
    [super onExit];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addItem
{
    CGSize windowSize = [[CCDirector sharedDirector] winSize];

    MKItem *item = (arc4random() % 100) < 50 ? [MKItem mushroom] : [MKItem peach];

    CGFloat horizontalMargin = windowSize.width * kEmergedAreaHorizontalMarginRate;
    NSInteger emergedAreaWidth = windowSize.width - horizontalMargin * 2;
    CGFloat positionX = arc4random() % emergedAreaWidth + horizontalMargin;
    item.position = ccp(positionX, windowSize.height + item.textureRect.size.height / 2);

    [self addChild:item];
    [item fall];
}

- (void)gameEngineDidStartTimeStop:(NSNotification *)notification
{
    [self pauseSchedulerAndActions];
}

- (void)gameEngineDidFinishTimeStop:(NSNotification *)notification
{
    [self resumeSchedulerAndActions];
}

- (void)gameEngineDidFinish:(NSNotification *)notification
{
    [self unschedule:@selector(addItem)];
}

@end
