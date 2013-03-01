//
//  MKItem.m
//  momoKinokoGame
//
//  Created by slightair on 2013/02/24.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKItem.h"

#define kItemSize 24
#define kEmergedAreaHorizontalMarginRate 0.1
#define kItemFallingSpeed 320
#define kItemFlipSpeed 320
#define kFlipDistanceThreshold 24
#define kFadeOutDuration 0.5

@interface MKItem ()

+ (NSString *)imageFileNameOfItemID:(MKItemID)itemID;
- (void)flipFrom:(CGPoint)from to:(CGPoint)to deltaTime:(CFAbsoluteTime)deltaTime;

@property (nonatomic, assign) MKItemID itemID;
@property (nonatomic, assign) CGPoint prevLocation;
@property (nonatomic, assign) CFAbsoluteTime prevTime;
@property (nonatomic, assign) BOOL isFlipped;

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
    mushroom.isFlipped = NO;

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

- (void)onExit
{
    [super onExit];

    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

- (void)fall
{
    CGSize windowSize = [[CCDirector sharedDirector] winSize];

    ccTime duration = windowSize.height / kItemFallingSpeed;
    CGFloat rotateAngle = 360 + arc4random() % 180;
    id fallAction = [CCSpawn actions:
                     [CCMoveBy actionWithDuration:duration position:ccp(0, - windowSize.height - kItemSize)],
                     [CCRotateBy actionWithDuration:duration angle:rotateAngle],
                     nil];
    id action = [CCSequence actions:
                 fallAction,
                 [CCCallFuncND actionWithTarget:self selector:@selector(removeFromParentAndCleanup:) data:(void *)YES],
                 nil];

    [self runAction:action];
}

- (void)flipFrom:(CGPoint)from to:(CGPoint)to deltaTime:(CFAbsoluteTime)deltaTime
{
    CGFloat movedX = to.x - from.x;
    CGFloat movedY = to.y - from.y;

    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    CGFloat slope = movedY / movedX;

    CGFloat destX = movedX > 0 ? windowSize.width : 0;
    CGFloat destY = (destX - from.x) * slope + from.y;
    ccTime duration = (destX - to.x) / movedX * deltaTime;
    CGFloat rotateAngle = 360;

    id flipAction = [CCSpawn actions:
                     [CCMoveTo actionWithDuration:duration position:ccp(destX, destY)],
                     [CCRotateBy actionWithDuration:duration angle:rotateAngle],
                     nil];
    id action = [CCSequence actions:
                 flipAction,
                 [CCCallFuncND actionWithTarget:self selector:@selector(removeFromParentAndCleanup:) data:(void *)YES],
                 nil];

    [self runAction:action];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:touch.view];
    location = [[CCDirector sharedDirector] convertToGL:location];

    CGRect spriteRect = CGRectMake(self.position.x - kItemSize,
                                   self.position.y - kItemSize,
                                   self.textureRect.size.width * 2,
                                   self.textureRect.size.height * 2);
    if (!CGRectContainsPoint(spriteRect, location)) {
        return NO;
    }

    [self stopAllActions];
    self.position = location;
    self.prevLocation = location;
    self.prevTime = CFAbsoluteTimeGetCurrent();

    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.isFlipped) {
        return;
    }

    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime deltaTime = now - self.prevTime;
    self.prevTime = now;

    CGPoint location = [touch locationInView:touch.view];
    location = [[CCDirector sharedDirector] convertToGL:location];

    if (!CGPointEqualToPoint(self.prevLocation, CGPointZero)) {
        CGFloat movedX = location.x - self.prevLocation.x;
        CGFloat movedY = location.y - self.prevLocation.y;
        CGFloat distance = sqrt(pow(movedX, 2) + pow(movedY, 2));
        if (distance > kFlipDistanceThreshold) {
            [self flipFrom:self.prevLocation to:location deltaTime:deltaTime];
            self.isFlipped = YES;
        }
        else {
            self.prevLocation = location;
        }
    }

    self.position = location;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.prevLocation = CGPointZero;

    if (!self.isFlipped) {
        id action = [CCSequence actions:
                     [CCFadeOut actionWithDuration:kFadeOutDuration],
                     [CCCallFuncND actionWithTarget:self selector:@selector(removeFromParentAndCleanup:) data:(void *)YES],
                     nil];

        [self runAction:action];
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.prevLocation = CGPointZero;
    [self removeFromParentAndCleanup:YES];
}

@end
