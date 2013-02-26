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

typedef enum {
    MKItemIDMushroomAkaKinoko   = 1000,
    MKItemIDMushroomHashiraDake,
    MKItemIDMushroomHukuroDake,
    MKItemIDMushroomAoKinoko,
    MKItemIDMushroomKasaKinoko,
    MKItemIDUnknown = -1,
} MKItemID;

@interface MKItem : CCSprite <CCTouchOneByOneDelegate>

+ (id)mushroom;
- (void)fall;

@property (nonatomic, assign, readonly) MKItemID itemID;

@end
