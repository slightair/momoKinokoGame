//
//  MKAppDelegate.m
//  momoKinokoGame
//
//  Created by slightair on 2013/02/20.
//  Copyright (c) 2013年 slightair. All rights reserved.
//

#import "MKAppDelegate.h"
#import <GameKit/GameKit.h>
#import "MKIntroLayer.h"
#import "MKGameEngine.h"

#ifdef TESTFLIGHT
#import <TestFlight.h>
#import "MKTestFlightToken.h"
#endif

@interface MKAppDelegate ()

@property (nonatomic, weak) CCDirectorIOS *director;
@property (nonatomic, strong) MKMainViewController *mainViewController;

@end

@implementation MKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef TESTFLIGHT
    [TestFlight takeOff:kTestFlightToken];
#endif

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    CCGLView *glView = [CCGLView viewWithFrame:self.window.bounds
                                   pixelFormat:kEAGLColorFormatRGB565
                                   depthFormat:0
                            preserveBackbuffer:NO
                                    sharegroup:nil
                                 multiSampling:NO
                               numberOfSamples:0];

    self.director = (CCDirectorIOS *)[CCDirector sharedDirector];
    self.director.wantsFullScreenLayout = YES;
    self.director.displayStats = NO;
    self.director.animationInterval = 1.0/60;
    self.director.view = glView;
    self.director.delegate = self;
    self.director.projection = kCCDirectorProjection2D;

    [self.director enableRetinaDisplay:YES];

    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

    CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
    [fileUtils setEnableFallbackSuffixes:NO];
    [fileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];
    [fileUtils setiPadSuffix:@"-ipad"];
    [fileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];

    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

    [self.director pushScene:[MKIntroLayer scene]];

    self.mainViewController = [[MKMainViewController alloc] initWithRootViewController:self.director];
    self.mainViewController.navigationBarHidden = YES;

    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];

    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    __weak GKLocalPlayer *player = localPlayer;
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController) {
            [self.window.rootViewController presentViewController:viewController
                                                         animated:YES
                                                       completion:NULL];
        }
        else if (player.authenticated) {
            [[MKGameEngine sharedEngine] setEnableGameCenter:YES];
            [[MKGameEngine sharedEngine] setCurrentPlayerID:player.playerID];
        }
        else {
            [[MKGameEngine sharedEngine] setEnableGameCenter:NO];
        }
    };

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    if (self.mainViewController.visibleViewController == self.director) {
        [self.director pause];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (self.mainViewController.visibleViewController == self.director) {
        [self.director stopAnimation];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (self.mainViewController.visibleViewController == self.director) {
        [self.director startAnimation];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (self.mainViewController.visibleViewController == self.director) {
        [self.director resume];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    CC_DIRECTOR_END();
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [self.director purgeCachedData];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application
{
    self.director.nextDeltaTimeZero = YES;
}

@end
