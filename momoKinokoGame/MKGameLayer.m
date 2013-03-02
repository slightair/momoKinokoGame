//
//  MKGameLayer.m
//  momoKinokoGame
//
//  Created by slightair on 2013/02/23.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKGameLayer.h"
#import "MKGameInfoLayer.h"
#import "MKItem.h"

#define kGameInfoLayerZOrder 100

@interface MKGameLayer ()

@property (nonatomic, strong) MKGameInfoLayer *infoLayer;

@end

@implementation MKGameLayer

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    MKGameLayer *layer = [MKGameLayer node];

    [scene addChild:layer];

    return scene;
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];

    self.infoLayer = [MKGameInfoLayer node];
    [self addChild:self.infoLayer z:kGameInfoLayerZOrder];

    [self schedule:@selector(addMushroom) interval:0.01];
}

- (void)addMushroom
{
    MKItem *mushroom = [MKItem mushroom];

    [self addChild:mushroom];
    [mushroom fall];
}

@end
