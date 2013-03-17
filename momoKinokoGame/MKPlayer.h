//
//  MKPlayer.h
//  momoKinokoGame
//
//  Created by slightair on 2013/03/16.
//  Copyright (c) 2013年 slightair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface MKPlayer : NSObject

- (void)storeScore:(GKScore *)score;
- (void)resubmitStoredScores;
- (void)writeStoredScore;
- (void)loadStoredScores;
- (void)submitScore:(GKScore *)score;

@end
