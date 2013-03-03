//
//  MKGameEngine.h
//  momoKinokoGame
//
//  Created by slightair on 2013/03/02.
//  Copyright (c) 2013年 slightair. All rights reserved.
//

#import <Foundation/Foundation.h>

// Notifications
extern NSString *const MKGameEngineNotificationUpdateScore;
extern NSString *const MKGameEngineNotificationPlayerObtainScore;

// Notification User Info Keys
extern NSString *const MKGameEngineUpdatedScoreUserInfoKey;
extern NSString *const MKGameEnginePlayerObtainedScoreUserInfoKey;
extern NSString *const MKGameEngineItemReachedLocationUserInfoKey;

@interface MKGameEngine : NSObject

+ (id)sharedEngine;
- (void)startNewGame;

@end
