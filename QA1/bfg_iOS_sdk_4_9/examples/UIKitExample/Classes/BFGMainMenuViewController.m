//
//  BFGMainMenuViewController.m
//  BFGUIKitExample
//
//  Created by Big Fish Games, Inc. on 6/29/11.
//  Copyright 2013 Big Fish Games, Inc.. All rights reserved.
//

#import "BFGMainMenuViewController.h"

#import "BFGGameScreenViewController.h"
#import "BFGInAppPurchaseController.h"
#import "BFGInAppPurchaseViewController.h"
#import "BFGBonusContentViewController.h"
#import "BFGUIKitExampleAppDelegate.h"

#import <bfg_iOS_sdk/bfgadsController.h>
#import <bfg_iOS_sdk/bfgutils.h>
#import <bfg_iOS_sdk/bfgBrandingViewController.h>
#import <bfg_iOS_sdk/bfgGameReporting.h>
#import <bfg_iOS_sdk/bfgLoginController.h>
#import <bfg_iOS_sdk/bfgMailController.h>
#import <bfg_iOS_sdk/bfgManager.h>
#import <bfg_iOS_sdk/bfgRating.h>
#import <bfg_iOS_sdk/bfgSettings.h>
#import <bfg_iOS_sdk/bfgSplash.h>
#import <bfg_iOS_sdk/bfgStrings.h>
#import <bfg_iOS_sdk/bfgAppManager.h>

#import <GameKit/GameKit.h>
#import <QuartzCore/QuartzCore.h>


@interface BFGMainMenuViewController()

@property (nonatomic, strong) IBOutlet UIButton                 *loginButton;

@property (nonatomic, strong) BFGGameScreenViewController       *gameScreenViewController;
@property (nonatomic, strong) BFGInAppPurchaseViewController    *inAppPurchaseViewController;
@property (nonatomic, strong) BFGBonusContentViewController     *bonusContentViewController;
@property (nonatomic, assign) bfgadsOrigin                       lastAdOrigin;
@property (nonatomic, strong) UIButton                          *splashButton;


// Notification handlers
- (void)handleBrandingComplete:(NSNotification *)notification;
- (void)handleLoginClosed:(NSNotification *)notification;
- (void)handleLoginOpened:(NSNotification *)notification;
- (void)handleSplashComplete:(NSNotification *)notification;
- (void)handleMoreGamesComplete:(NSNotification *)notification;
- (void)updateLoginButton;

@end


@implementation BFGMainMenuViewController

#pragma mark - Instance lifecycle

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];	
}


- (BFGInAppPurchaseViewController *)inAppPurchaseViewController
{
    if (!_inAppPurchaseViewController)
    {
        _inAppPurchaseViewController = [[BFGInAppPurchaseViewController alloc] initWithNibName:[BFGUIKitExampleAppDelegate nibNameWithBaseName: @"BFGInAppPurchaseViewController"] bundle: nil];
    }
    return _inAppPurchaseViewController;
}


- (BFGGameScreenViewController *)gameScreenViewController
{
    if (!_gameScreenViewController)
    {
        _gameScreenViewController = [[BFGGameScreenViewController alloc] initWithNibName:[BFGUIKitExampleAppDelegate nibNameWithBaseName: @"BFGGameScreenViewController"] bundle:nil];
    }
    return _gameScreenViewController;
}

- (BFGBonusContentViewController *)bonusContentViewController
{
    if (!_bonusContentViewController)
    {
        _bonusContentViewController = [[BFGBonusContentViewController alloc] initWithNibName:[BFGUIKitExampleAppDelegate nibNameWithBaseName:@"BFGBonusContent"] bundle:nil];
    }
    return _bonusContentViewController;
}


#pragma mark - View lifecycle


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateLoginButton];

    self.splashButton = [bfgSplash createSplashButton];
    CGPoint location = [bfgutils iPadMode]?CGPointMake(20, 120):CGPointMake(5, 55);
    
    self.splashButton.frame = CGRectMake(location.x, location.y, self.splashButton.frame.size.width, self.splashButton.frame.size.height);

    [self.view insertSubview:self.splashButton atIndex:1];

    [super viewWillAppear:animated];
    //
    //   NOTE: If you create your own newsletter button, you should check for
    //   [bfgSplash getNewsletterSent] to decide whether or not
    //   to hide iSplash newletter button
    //
    // self.newsletterSent.hidden = [bfgSplash getNewsletterSent];

    self.mainMenuRateButton.hidden = ![bfgRating canShowMainMenuRateButton];
    self.tellAFriendButton.hidden = ![bfgManager canShowTellAFriendButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLoginButton) name:BFG_NOTIFICATION_LOGIN_STATUS_CHANGE object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [BFGInAppPurchaseController startPurchaseService];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleBrandingComplete:) name:BFGBRANDING_NOTIFICATION_COMPLETED object:nil];
    [nc addObserver:self selector:@selector(handleSplashComplete:) name:BFGSPLASH_NOTIFICATION_COMPLETED object:nil];
    [nc addObserver:self selector:@selector(handleMoreGamesComplete:) name:BFGPROMODASHBOARD_NOTIFICATION_MOREGAMES_CLOSED object:nil];
    [nc addObserver:self selector:@selector(handleLoginOpened:) name:BFG_NOTIFICATION_LOGIN_OPENED object:nil];
 
    self.versionInfo.text = [NSString stringWithFormat:@"Version - %08x", BFGLIB_VERSION_CURRENT];

    [super viewDidAppear:animated];

    //
    // Start Ads
    //
    if (!self.lastAdOrigin)
    {
        self.lastAdOrigin = BFGADS_ORIGIN_BOTTOM;
    }
    [bfgManager startAds:self.lastAdOrigin];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:BFGBRANDING_NOTIFICATION_COMPLETED object:nil];
    [nc removeObserver:self name:BFGSPLASH_NOTIFICATION_COMPLETED object:nil];
    [nc removeObserver:self name:BFGPROMODASHBOARD_NOTIFICATION_MOREGAMES_CLOSED object:nil];
    [nc removeObserver:self name:BFG_NOTIFICATION_LOGIN_OPENED object:nil];
    
    [bfgManager stopAds];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BFG_NOTIFICATION_LOGIN_STATUS_CHANGE object:nil];
}


// In this example the Main Menu is landscape only. The Game screen support all orientations.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
 	// Support only landscape on startup
    return (UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation));
}

- (void)authenticateGameCenter
{
    // Check for presence of GKLocalPlayer class.
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
    
    // The device must be running iOS 4.1 or later.
    BOOL osVersionSupported = ([[[UIDevice currentDevice] systemVersion] compare:@"4.1" options:NSNumericSearch] != NSOrderedAscending);
    
    if  (localPlayerClassAvailable && osVersionSupported)
    {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
            if (localPlayer.isAuthenticated)
            {
                BFGUIKitExampleLog(@"Game Center Authenticated Login ID = %@", localPlayer.playerID);
            }
        }];
    }
}

#pragma mark - Branding Methods

- (IBAction)showBranding:(id)sender 
{
    [bfgManager stopAds];
    [bfgManager startBranding];
}


// 
// Check if orientation has changed while More Games was up
//

- (void)handleBrandingComplete:(NSNotification *)notification
{
    BFGUIKitExampleLog(@"handleBrandingComplete");        
    [self authenticateGameCenter];
    [bfgManager startAds:self.lastAdOrigin];
}

- (void)handleLoginClosed:(NSNotification *)notification
{
    BFGUIKitExampleLog(@"The login UI has closed.");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BFG_NOTIFICATION_LOGIN_CLOSED object:nil];
}

- (void)handleLoginOpened:(NSNotification *)notification
{
    BFGUIKitExampleLog(@"The login UI is opening.");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginClosed:) name:BFG_NOTIFICATION_LOGIN_CLOSED object:nil];
}

- (void)handleMoreGamesComplete:(NSNotification *)notification
{
    BFGUIKitExampleLog(@"handleMoreGamesComplete");
    [bfgManager startAds:self.lastAdOrigin];
}

- (void)handleSplashComplete:(NSNotification *)notification
{
    BFGUIKitExampleLog(@"handleSplashComplete");    
}

#pragma mark - Rating Methods

- (IBAction)resetRatings:(id)sender
{
	[bfgRating reset];
	[self logRatingsTextWithAlertTitle: @"Ratings Info Reset"];
}

- (IBAction)rateImmediately:(id)sender
{
	[bfgRating mainMenuRateApp];
    
    // Update UI
    self.mainMenuRateButton.hidden = true;
}


#pragma mark Tell A Friend Methods

- (IBAction)tellFriend:(id)sender
{
    [bfgManager showTellAFriend];
}

#pragma mark - Splash Methods

- (IBAction)startSplash:(id)sender
{
	[bfgSplash displayNewsletter:self];
}

- (IBAction)resetSentFlag:(id)sender
{
    [bfgSplash setNewsletterSent: false];
    [self displayAlertWithTitle: @"Newsletter Splash Reset" message: @"The Newsletter Splash Flag has been reset."];
}


#pragma mark - More Games Methods

- (IBAction) showMoreGames:(id)sender
{
    if ([bfgManager isInitialized]) 
    {        
        [bfgManager stopAds];
        [bfgManager showMoreGames];
    }
}


#pragma mark - Other Screens

- (IBAction)showGameScreen:(id)sender
{
    [bfgManager stopAds];
    [self.navigationController pushViewController:self.gameScreenViewController animated:NO];
    // [self.appDelegate showGameScreen];
}


#pragma mark - In App Purchase Methods

- (IBAction)showIAPScreen:(id)sender
{
    [bfgManager stopAds];
    // Game should call this each time purchase from the Main Menu is shown.
    [bfgGameReporting logPurchaseMainMenuShown];
    [self.navigationController pushViewController:self.inAppPurchaseViewController animated:NO];
}

#pragma mark - Log In

- (void)updateLoginButton
{
    UIButton *currentButton;
    UIViewAutoresizing resizingMask = self.loginButton.autoresizingMask;
    if ([bfgLoginController isLoggedIn])
    {
        currentButton = [bfgLoginController logOutButtonWithFrame:self.loginButton.frame lightColor:NO];
    }
    else
    {
        currentButton = [bfgLoginController logInButtonWithFrame:self.loginButton.frame lightColor:NO];
    }
    currentButton.autoresizingMask = resizingMask;
    UIView *buttonContainerView = self.loginButton.superview;
    NSUInteger subviewIndex = [[buttonContainerView subviews] indexOfObject:self.loginButton];
    [self.loginButton removeFromSuperview];
    [buttonContainerView insertSubview:currentButton atIndex:subviewIndex];
    self.loginButton = currentButton;
}

#pragma mark - Bonus Content

- (IBAction)bonusGamePlayTapped:(id)sender
{
    [bfgManager stopAds];
    [self.navigationController pushViewController:self.bonusContentViewController animated:NO];
}

@end
