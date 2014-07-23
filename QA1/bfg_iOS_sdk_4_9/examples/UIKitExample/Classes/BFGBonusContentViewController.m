//
//  BFGBonusContentViewController.m
//  BFGUIKitExample
//
//  Created by Big Fish Games on 11/15/13.
//  Copyright (c) 2013 Big Fish Games, Inc. All rights reserved.
//

#import "BFGBonusContentViewController.h"

#import <bfg_iOS_sdk/bfgAppManager.h>

@interface BFGBonusContentViewController ()

@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *conceptArtButton;
@property (weak, nonatomic) IBOutlet UIButton *bonusLevelButton;
@property (weak, nonatomic) IBOutlet UIButton *cutscenesButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation BFGBonusContentViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Enable/Disable bonus content
    [self enableBonusContent:[bfgAppManager isBigFishGamesAppInstalled]];
}


#pragma mark - IBActions

- (IBAction)tappedBackButton:(id)sender
{
    // Leaving 'Bonus Content' screen
    
    // Cancel referral link request in progress (if any)
    [bfgAppManager cancelCurrentReferral];
    
    // Stop background thread from detecting Big Fish Games app
    [bfgAppManager stopDetectingAppWithIdentifier:BFG_BIG_FISH_GAMES_BUNDLE_ID];
    
    // Remove self from all notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self hideCancelUI];
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)tappedDownloadButton:(id)sender
{
    // See if Big Fish Games app is already installed first
    if ([bfgAppManager isBigFishGamesAppInstalled])
    {
        [self enableBonusContent:YES];
        return;
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    // Hide the cancel button and activity indicator when the store is presented
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_6_0)
    {
        // iOS 6+
        [nc addObserver:self selector:@selector(hideCancelUI) name:BFG_NOTIFICATION_APP_STORE_PRESENTED object:nil];
    }
    else
    {
        // iOS 5
        [nc addObserver:self selector:@selector(hideCancelUI) name:BFG_NOTIFICATION_OPENING_APP_STORE object:nil];
    }
    
    [nc addObserver:self selector:@selector(failedToPresentAppStore:) name:BFG_NOTIFICATION_OPEN_REFERRAL_URL_FAILED object:nil];
    
    // Detect when Big Fish Games app has been installed
    [nc addObserver:self selector:@selector(detectedApp:) name:BFG_NOTIFICATION_APP_DETECTED object:nil];
    [bfgAppManager startDetectingAppWithIdentifier:BFG_BIG_FISH_GAMES_BUNDLE_ID];
    
    // Show cancel UI elements
    [self.activityIndicator startAnimating];
    self.cancelButton.hidden = NO;
    
    // Kick off App Store URL
    [bfgAppManager launchStoreWithBigFishGamesApp];
}

- (IBAction)tappedCancelButton:(id)sender
{
    [self cancelDownload];
}


#pragma mark - Helper methods

- (void)cancelDownload
{
    [bfgAppManager cancelCurrentReferral];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:BFG_NOTIFICATION_OPEN_REFERRAL_URL_FAILED object:nil];
    
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_6_0)
    {
        // iOS 6+
        [nc removeObserver:self name:BFG_NOTIFICATION_APP_STORE_PRESENTED object:nil];
    }
    else
    {
        // iOS 5
        [nc removeObserver:self name:BFG_NOTIFICATION_OPENING_APP_STORE object:nil];
    }
    
    [self hideCancelUI];
}

- (void)enableBonusContent:(BOOL)enable
{
    for (UIButton *button in @[self.conceptArtButton, self.bonusLevelButton, self.cutscenesButton])
    {
        button.enabled = enable;
    }
    
    // Hide download button when bonus content enabled
    self.downloadButton.hidden = enable;
}


#pragma mark - Notification handlers

- (void)hideCancelUI
{
    [self.activityIndicator stopAnimating];
    self.cancelButton.hidden = YES;
}

- (void)failedToPresentAppStore:(NSNotification *)notification
{
    [self hideCancelUI];
    
    // Show alert to user
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Store Failed" message:@"Failed to open the App Store. Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

- (void)detectedApp:(NSNotification *)notification
{
    // Get bundle ID of detected app
    NSString *bundleIdOfDetectedApp = notification.userInfo[BFG_BUNDLE_IDENTIFIER_KEY];
    
    if ([bundleIdOfDetectedApp isKindOfClass:[NSString class]] && [bundleIdOfDetectedApp isEqualToString:BFG_BIG_FISH_GAMES_BUNDLE_ID])
    {
        [self enableBonusContent:YES];
    }
}

@end
