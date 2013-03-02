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

#define kAddItemInterval 0.1
#define kEmergedAreaHorizontalMarginRate 0.1
#define kGameInfoLayerZOrder 100

@interface MKGameLayer ()

- (void)addItem;

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

    [self schedule:@selector(addItem) interval:kAddItemInterval];
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

@end
