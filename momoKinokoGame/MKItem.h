//
//  MKItem.h
//  momoKinokoGame
//
//  Created by slightair on 2013/02/24.
//  Copyright 2013年 slightair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kNumberOfMushroom 5
#define kNumberOfPeach 3

// Notifications
extern NSString *const MKItemNotificationReachedItem;

// Notification User Info Keys
extern NSString *const MKItemReachedItemIDUserInfoKey;
extern NSString *const MKItemReachedItemKindUserInfoKey;
extern NSString *const MKItemReachedLocationUserInfoKey;

typedef enum {
    MKItemIDMushroomAkaKinoko   = 1000,
    MKItemIDMushroomHashiraDake,
    MKItemIDMushroomHukuroDake,
    MKItemIDMushroomAoKinoko,
    MKItemIDMushroomKasaKinoko,
    MKItemIDPeachBamiyan = 2000,
    MKItemIDPeachOutou,
    MKItemIDPeachHakutou,
    MKItemIDUnknown = -1,
} MKItemID;

typedef enum {
    MKItemKindMushroom = 100,
    MKItemKindPeach,
    MKItemKindUnknown = -1
} MKItemKind;

@interface MKItem : CCSprite <CCTouchOneByOneDelegate>

+ (NSString *)imageFileNameOfItemID:(MKItemID)itemID;
+ (id)mushroom;
+ (id)peach;
- (void)fall;

@property (nonatomic, assign, readonly) MKItemID itemID;
@property (nonatomic, assign, readonly) MKItemKind itemKind;

@end
