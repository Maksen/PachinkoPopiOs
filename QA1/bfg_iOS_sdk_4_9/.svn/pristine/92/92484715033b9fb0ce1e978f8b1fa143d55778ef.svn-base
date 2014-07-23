//
//  BFGUIKitExampleAppDelegate.m
//  BFGUIKitExample
//
//  Created by Big Fish Games, Inc. on 6/29/11.
//  Copyright 2013 Big Fish Games, Inc.. All rights reserved.
//

#import "BFGUIKitExampleAppDelegate.h"
#import "BFGUIKitExampleViewController.h"
#import <bfg_iOS_sdk/bfgBrandingViewController.h>
#import <bfg_iOS_sdk/bfgLoginController.h>
#import <bfg_iOS_sdk/bfgManager.h>
#import <bfg_iOS_sdk/bfgRating.h>
#import <bfg_iOS_sdk/bfgutils.h>
#import "BFGGameScreenViewController.h"
#import "BFGMainMenuViewController.h"
#import "BFGInAppPurchaseViewController.h"
#import "BFGBonusContentViewController.h"
#import <bfg_iOS_sdk/bfgPushNotificationManager.h>

/** Private Methods */
@interface BFGUIKitExampleAppDelegate ()

@property (nonatomic, strong) UINavigationController *navigationController;

// Notification handlers
- (void)handleMainMenu:(NSNotification *)notification;
- (void)handleColdStart:(NSNotification *)notification;
- (void)handleWarmStart:(NSNotification *)notification;
- (void)handleBrandingComplete:(NSNotification *)notification;

@end


@implementation BFGUIKitExampleAppDelegate

#pragma mark - Public class methods

+ (NSString *)nibNameWithBaseName:(NSString *)baseName
{
    NSString * nibName = nil;
    NSString * suffix = @"iPhoneLandscape";
    if([bfgutils iPadMode]) {
        suffix = @"iPad";
    }
    nibName = [NSString stringWithFormat: @"%@-%@", baseName, suffix];
    return nibName;
}


#pragma mark - Application Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Register for the startup notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBrandingComplete:) name:BFGBRANDING_NOTIFICATION_COMPLETED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMainMenu:) name:BFGPROMODASHBOARD_NOTIFICATION_MAINMENU object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleColdStart:) name:BFGPROMODASHBOARD_NOTIFICATION_COLDSTART object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWarmStart:) name:BFGPROMODASHBOARD_NOTIFICATION_WARMSTART object:nil];
    
    // Prepare the main menu
    BFGMainMenuViewController *mainMenuController = [[BFGMainMenuViewController alloc] initWithNibName:[BFGUIKitExampleAppDelegate nibNameWithBaseName: @"BFGMainMenuViewController"] bundle:nil];

    // Our UIKit Example will have views managed by a UINavigationController.
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:mainMenuController];
    [self.navigationController.navigationBar setHidden:YES];
    
    [self.window setRootViewController:self.navigationController];
    
    // The root view controller's view should be visible *before* calling [bfgManager initializeWithViewController:]
    [self.window makeKeyAndVisible];
    
    // *************************************************************************************************************
    // ***                                     IMPORTANT!                                                        ***
    // *** EVERY TIME YOU CHANGE THE VISIBLE VIEW CONTROLLER YOU MUST CALL [bfgManager setParentViewController:] ***
    // *************************************************************************************************************
    [bfgManager initializeWithViewController:mainMenuController]; // Sets the parentViewController to the main menu
    
    // *************************************************************************************************************
    // ***                                     PLEASE NOTE                                                       ***
    // *** In this example we display Apple "Register for push?" dialog immediately after launch, talk to your   ***
    // *** producer for best practice around displaying this dialog.                                             ***
    // *************************************************************************************************************
    [bfgPushNotificationManager registerForPlayHavenPushNotifications];
    [bfgPushNotificationManager handleRemoteNotificationWithLaunchOption:launchOptions];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"This app was launched with this URL: %@", url.absoluteString);
    
    // Check for SDK supported URL scheme support
    if (![bfgManager launchSDKByURLScheme:url.absoluteString])
    {
        // Do you own thing
    }
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	[bfgPushNotificationManager handlePush:userInfo];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	[bfgPushNotificationManager registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	[bfgPushNotificationManager didFailToRegisterWithError:error];
    
    NSLog(@"Failed to get token, error: %@", error);
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private Instance Methods

-(void) handleColdStart: (NSNotification *) notification
{
    BFGUIKitExampleLog(@"Cold Start");
    [bfgManager startBranding];
    
    // Set the push notification icon badge number to 0.
    [bfgPushNotificationManager setIconBadgeNumber:0];
}


- (void)handleMainMenu:(NSNotification *)notification
{
    BFGUIKitExampleLog(@"Time to show the main menu");
    [self.navigationController popViewControllerAnimated:NO];
}


-(void) handleWarmStart: (NSNotification *) notification
{
    BFGUIKitExampleLog(@"Warm Start");
    
    // Set the push notification icon badge number to 0.
    [bfgPushNotificationManager setIconBadgeNumber:0];
}


-(void) handleBrandingComplete: (NSNotification *) notification
{
    BFGUIKitExampleLog(@"Branding complete");
    [bfgLoginController startService];
}


@end
