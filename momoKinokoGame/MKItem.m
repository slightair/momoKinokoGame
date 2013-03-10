//
//  MKItem.m
//  momoKinokoGame
//
//  Created by slightair on 2013/02/24.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKItem.h"
#import "MKGameEngine.h"

#define kItemFallingSpeed 320
#define kFlipDistanceThreshold 12
#define kFadeOutDuration 0.5

// Notifications
NSString *const MKItemNotificationReachedItem = @"MKItemNotificationReachedItem";

// Notification User Info Keys
NSString *const MKItemReachedItemIDUserInfoKey = @"MKItemReachedItemID";
NSString *const MKItemReachedItemKindUserInfoKey = @"MKItemReachedItemKind";
NSString *const MKItemReachedLocationUserInfoKey = @"MKItemReachedLocation";

@interface MKItem ()

+ (id)itemWithID:(MKItemID)itemID;
- (void)flipFrom:(CGPoint)from to:(CGPoint)to deltaTime:(CFAbsoluteTime)deltaTime;
- (void)notifyReachedItem:(NSValue *)destination;
- (void)gameEngineDidStartTimeStop:(NSNotification *)notification;
- (void)gameEngineDidFinishTimeStop:(NSNotification *)notification;

@property (nonatomic, assign) MKItemID itemID;
@property (nonatomic, assign) MKItemKind itemKind;
@property (nonatomic, assign) CGPoint prevLocation;
@property (nonatomic, assign) CFAbsoluteTime prevTime;
@property (nonatomic, strong) CCAction *flipAction;
@property (nonatomic, assign) BOOL isFrozen;

@end

@implementation MKItem

+ (id)itemWithID:(MKItemID)itemID
{
    NSString *imageFileName = [self imageFileNameOfItemID:itemID];
    MKItem *item = [MKItem spriteWithFile:imageFileName];
    item.itemID = itemID;
    item.flipAction = nil;
    item.isFrozen = NO;

    return item;
}

+ (id)mushroom
{
    MKItemID itemID = MKItemIDMushroomAkaKinoko + arc4random() % kNumberOfMushroom;
    MKItem *item = [self itemWithID:itemID];
    item.itemKind = MKItemKindMushroom;

    return item;
}

+ (id)peach
{
    MKItemID itemID = MKItemIDPeachHakutou + arc4random() % kNumberOfPeach;
    MKItem *item = [self itemWithID:itemID];
    item.itemKind = MKItemKindPeach;

    return item;
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

        case MKItemIDPeachHakutou:
            fileName = @"peach1.png";
            break;

        case MKItemIDPeachOutou:
            fileName = @"peach2.png";
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameEngineDidStartTimeStop:)
                                                 name:MKGameEngineNotificationStartTimeStop
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameEngineDidFinishTimeStop:)
                                                 name:MKGameEngineNotificationFinishTimeStop
                                               object:nil];
}

- (void)onExit
{
    [super onExit];

    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fall
{
    CGSize windowSize = [[CCDirector sharedDirector] winSize];

    ccTime duration = windowSize.height / kItemFallingSpeed;
    CGFloat rotateAngle = 360 + arc4random() % 180;
    id fallAction = [CCSpawn actions:
                     [CCMoveBy actionWithDuration:duration position:ccp(0, - windowSize.height - self.textureRect.size.height)],
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

    CGFloat destX = 0;
    CGFloat destY = 0;
    if (movedX != 0) {
        destX = movedX > 0 ? windowSize.width : 0;
        destY = (destX - from.x) * (movedY / movedX) + from.y;

        if (destY < 0 || windowSize.height < destY) {
            destY = movedY > 0 ? windowSize.height : 0;
            destX = (destY - from.y) * (movedX / movedY) + from.x;
        }
    }
    else {
        destX = to.x;
        destY = movedY > 0 ? windowSize.height : 0;
    }

    CGFloat moved = sqrt(pow(movedX, 2) + pow(movedY, 2));
    CGFloat move = sqrt(pow(destX - to.x, 2) + pow(destY - to.y, 2));
    ccTime duration = move / moved * deltaTime;

    CGFloat rotateAngle = 360;

    id flipAction = [CCSpawn actions:
                     [CCMoveTo actionWithDuration:duration position:ccp(destX, destY)],
                     [CCRotateBy actionWithDuration:duration angle:rotateAngle],
                     nil];
    id action = [CCSequence actions:
                 flipAction,
                 [CCCallFuncO actionWithTarget:self selector:@selector(notifyReachedItem:) object:[NSValue valueWithCGPoint:ccp(destX, destY)]],
                 [CCCallFuncND actionWithTarget:self selector:@selector(removeFromParentAndCleanup:) data:(void *)YES],
                 nil];

    self.flipAction = action;
}

- (void)notifyReachedItem:(NSValue *)destination
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MKItemNotificationReachedItem
                                                        object:self
                                                      userInfo:@{MKItemReachedItemIDUserInfoKey : @(self.itemID),
                                                                 MKItemReachedItemKindUserInfoKey : @(self.itemKind),
                                                                 MKItemReachedLocationUserInfoKey : destination}];
}

- (void)gameEngineDidStartTimeStop:(NSNotification *)notification
{
    [self pauseSchedulerAndActions];
    self.isFrozen = YES;
}

- (void)gameEngineDidFinishTimeStop:(NSNotification *)notification
{
    self.isFrozen = NO;

    if (self.flipAction) {
        [self runAction:self.flipAction];
    }
    else {
        [self resumeSchedulerAndActions];
    }
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.flipAction) {
        return NO;
    }

    CGPoint location = [touch locationInView:touch.view];
    location = [[CCDirector sharedDirector] convertToGL:location];
    CGSize itemSize = self.textureRect.size;

    CGRect spriteRect = CGRectMake(self.position.x - itemSize.width,
                                   self.position.y - itemSize.height,
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
    if (self.flipAction) {
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
            if (!self.isFrozen) {
                [self runAction:self.flipAction];
            }
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

    if (!self.flipAction) {
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
