//
//  MKPlayer.m
//  momoKinokoGame
//
//  Created by slightair on 2013/03/16.
//  Copyright (c) 2013年 slightair. All rights reserved.
//

#import "MKPlayer.h"

@interface MKPlayer ()

@property (nonatomic, strong) NSMutableArray *storedScores;
@property (nonatomic, strong) NSString *storedScoresFilename;
@property (nonatomic, strong) NSLock *writeLock;

@end

@implementation MKPlayer

- (id)init
{
    self = [super init];
    if (self) {
        NSString *documentDirectoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *playerID = [GKLocalPlayer localPlayer].playerID;
        self.storedScoresFilename = [documentDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.storedScores.plist", playerID]];
        self.writeLock = [[NSLock alloc] init];
    }
    return self;
}

- (void)storeScore:(GKScore *)score
{
    [self.storedScores addObject:score];
    [self writeStoredScore];
}

- (void)resubmitStoredScores
{
    if (self.storedScores) {
        while ([self.storedScores count] > 0) {
            GKScore *score = [self.storedScores lastObject];
            [self submitScore:score];
            [self.storedScores removeLastObject];
        }
        [self writeStoredScore];
    }
}

- (void)writeStoredScore
{
    [self.writeLock lock];

    NSData *archivedScores = [NSKeyedArchiver archivedDataWithRootObject:self.storedScores];
    [archivedScores writeToFile:self.storedScoresFilename options:NSDataWritingFileProtectionNone error:NULL];

    [self.writeLock unlock];
}

- (void)loadStoredScores
{
    NSArray *storedScores = [NSKeyedUnarchiver unarchiveObjectWithFile:self.storedScoresFilename];
    if (storedScores) {
        self.storedScores = [storedScores mutableCopy];
        [self resubmitStoredScores];
    }
    else {
        self.storedScores = [NSMutableArray array];
    }
}

- (void)submitScore:(GKScore *)score
{
    if ([GKLocalPlayer localPlayer].authenticated) {
        if (!score.value) {
            return;
        }

        [score reportScoreWithCompletionHandler:^(NSError *error){
            if (error) {
                [self storeScore:score];
            }
            else {
                [self resubmitStoredScores];
            }
        }];
    }
}

@end
