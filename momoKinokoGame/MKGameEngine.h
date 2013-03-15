//
//  MKGameEngine.h
//  momoKinokoGame
//
//  Created by slightair on 2013/03/02.
//  Copyright (c) 2013年 slightair. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MKGameEngineGameTimerInterval 0.1

// Notifications
extern NSString *const MKGameEngineNotificationUpdateScore;
extern NSString *const MKGameEngineNotificationPlayerObtainScore;
extern NSString *const MKGameEngineNotificationStartTimeStop;
extern NSString *const MKGameEngineNotificationFinishTimeStop;
extern NSString *const MKGameEngineNotificationGameFinished;
extern NSString *const MKGameEngineNotificationSupplySpecialItem;

// Notification User Info Keys
extern NSString *const MKGameEngineUpdatedScoreUserInfoKey;
extern NSString *const MKGameEnginePlayerObtainedScoreUserInfoKey;
extern NSString *const MKGameEngineItemReachedLocationUserInfoKey;

@interface MKGameEngine : NSObject

+ (id)sharedEngine;
- (void)startNewGame;

@property (nonatomic, assign, readonly) NSInteger score;
@property (nonatomic, assign, readonly) NSTimeInterval remainTime;
@property (nonatomic, assign, readonly) NSTimeInterval remainTimeStopTime;
@property (nonatomic, strong, readonly) NSDictionary *harvestedItems;
@property (nonatomic, assign) BOOL enableGameCenter;

@end
