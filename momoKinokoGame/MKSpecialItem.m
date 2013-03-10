//
//  MKSpecialItem.m
//  momoKinokoGame
//
//  Created by slightair on 2013/03/05.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKSpecialItem.h"

#define kImageFileName @"magicalClock.png"
#define kItemFallingSpeed 160
#define kItemScaleUpMax 5.0
#define kFadeOutDuration 0.5

// Notifications
NSString *const MKSpecialItemNotificationDidTouchItem = @"MKSpecialItemNotificationDidTouchItem";

// Notification User Info Keys
NSString *const MKSpecialItemExecutionLocationUserInfoKey = @"MKSpecialItemExecutionLocation";

@implementation MKSpecialItem

+ (id)magicalClock
{
    id item = [self spriteWithFile:kImageFileName];
    return item;
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
                     [CCMoveBy actionWithDuration:duration position:ccp(0, - windowSize.height - self.textureRect.size.height)],
                     [CCRotateBy actionWithDuration:duration angle:rotateAngle],
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

    id scaleUpAction = [CCSpawn actions:
                        [CCScaleTo actionWithDuration:kFadeOutDuration scale:kItemScaleUpMax],
                        [CCFadeOut actionWithDuration:kFadeOutDuration],
                        nil];
    id action = [CCSequence actions:
                 scaleUpAction,
                 [CCCallFuncND actionWithTarget:self selector:@selector(removeFromParentAndCleanup:) data:(void *)YES],
                 nil];

    [self runAction:action];

    [[NSNotificationCenter defaultCenter] postNotificationName:MKSpecialItemNotificationDidTouchItem
                                                        object:self
                                                      userInfo:@{MKSpecialItemExecutionLocationUserInfoKey:[NSValue valueWithCGPoint:location]}];

    return YES;
}

@end
