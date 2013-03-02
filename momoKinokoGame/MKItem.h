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
#define kNumberOfPeach 2

typedef enum {
    MKItemIDMushroomAkaKinoko   = 1000,
    MKItemIDMushroomHashiraDake,
    MKItemIDMushroomHukuroDake,
    MKItemIDMushroomAoKinoko,
    MKItemIDMushroomKasaKinoko,
    MKItemIDPeachHakutou = 2000,
    MKItemIDPeachOutou,
    MKItemIDUnknown = -1,
} MKItemID;

@interface MKItem : CCSprite <CCTouchOneByOneDelegate>

+ (id)mushroom;
+ (id)peach;
- (void)fall;

@property (nonatomic, assign, readonly) MKItemID itemID;

@end
