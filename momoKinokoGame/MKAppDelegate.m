//
//  MKAppDelegate.m
//  momoKinokoGame
//
//  Created by slightair on 2013/02/20.
//  Copyright (c) 2013年 slightair. All rights reserved.
//

#import "MKAppDelegate.h"
#import "MKIntroLayer.h"

@interface MKAppDelegate ()

@property (nonatomic, weak) CCDirectorIOS *director;
@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation MKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
    self.director.displayStats = YES;
    self.director.animationInterval = 1.0/60;
    self.director.view = glView;
    self.director.delegate = self;
    self.director.projection = kCCDirectorProjection2D;

//    [self.director enableRetinaDisplay:YES];

    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

    CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
    [fileUtils setEnableFallbackSuffixes:NO];
    [fileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];
    [fileUtils setiPadSuffix:@"-ipad"];
    [fileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];

    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

    [self.director pushScene:[MKIntroLayer scene]];

    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.director];
    self.navigationController.navigationBarHidden = YES;

    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    if (self.navigationController.visibleViewController == self.director) {
        [self.director pause];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (self.navigationController.visibleViewController == self.director) {
        [self.director stopAnimation];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (self.navigationController.visibleViewController == self.director) {
        [self.director startAnimation];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (self.navigationController.visibleViewController == self.director) {
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
