//
//  MKItem.m
//  momoKinokoGame
//
//  Created by slightair on 2013/02/24.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKItem.h"

#define kItemSize 24
#define kItemRotationAngle 360
#define kItemFallingSpeed 320
#define kEmergedAreaHorizontalMarginRate 0.1

@interface MKItem ()

+ (NSString *)imageFileNameOfItemID:(MKItemID)itemID;

@property (nonatomic, assign) MKItemID itemID;

@end

@implementation MKItem

+ (id)mushroom
{
    MKItemID itemID = MKItemIDMushroomAkaKinoko + arc4random() % kNumberOfMushroom;
    NSString *imageFileName = [self imageFileNameOfItemID:itemID];
    MKItem *mushroom = [MKItem spriteWithFile:imageFileName];
    mushroom.itemID = itemID;

    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    CGFloat horizontalMargin = windowSize.width * kEmergedAreaHorizontalMarginRate;
    NSInteger emergedAreaWidth = windowSize.width - horizontalMargin * 2;
    CGFloat positionX = arc4random() % emergedAreaWidth + horizontalMargin;
    mushroom.position = ccp(positionX, windowSize.height + kItemSize / 2);

    return mushroom;
}

+ (NSString *)imageFileNameOfItemID:(MKItemID)itemID
{
    NSString *fileName = nil;

    switch (itemID) {
        case MKItemIDMushroomAkaKinoko:
            fileName = @"mushroom1.png";
            break;

        case MKItemIDMushroomHashiraDake:
            fileName = @"mushroom2.png";
            break;

        case MKItemIDMushroomHukuroDake:
            fileName = @"mushroom3.png";
            break;

        case MKItemIDMushroomAoKinoko:
            fileName = @"mushroom4.png";
            break;

        case MKItemIDMushroomKasaKinoko:
            fileName = @"mushroom5.png";
            break;

        default:
            break;
    }

    return fileName;
}

- (void)onEnter
{
    [super onEnter];

    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)fall
{
    CGSize windowSize = [[CCDirector sharedDirector] winSize];

    ccTime duration = windowSize.height / kItemFallingSpeed;
    id fallAction = [CCSpawn actions:
                     [CCMoveBy actionWithDuration:duration position:ccp(0, - windowSize.height - kItemSize)],
                     [CCRotateBy actionWithDuration:duration angle:kItemRotationAngle],
                     nil];
    id action = [CCSequence actions:
                 fallAction,
                 [CCCallFuncND actionWithTarget:self selector:@selector(removeFromParentAndCleanup:) data:(void *)YES],
                 nil];

    [self runAction:action];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:touch.view];
    location = [[CCDirector sharedDirector] convertToGL:location];

    CGRect spriteRect = CGRectOffset(self.textureRect, self.position.x - kItemSize / 2, self.position.y - kItemSize / 2);
    if (!CGRectContainsPoint(spriteRect, location)) {
        return NO;
    }

    [self stopAllActions];
    self.position = location;

    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:touch.view];
    location = [[CCDirector sharedDirector] convertToGL:location];

    self.position = location;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self removeFromParentAndCleanup:YES];
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self removeFromParentAndCleanup:YES];
}

@end
