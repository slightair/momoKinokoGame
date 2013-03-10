//
//  MKSpecialItem.h
//  momoKinokoGame
//
//  Created by slightair on 2013/03/05.
//  Copyright 2013年 slightair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// Notifications
extern NSString *const MKSpecialItemNotificationDidTouchItem;

// Notification User Info Keys
extern NSString *const MKSpecialItemExecutionLocationUserInfoKey;

@interface MKSpecialItem : CCSprite <CCTouchOneByOneDelegate>

+ (id)magicalClock;
- (void)fall;

@end
