//
//  BFGMainMenuViewController.h
//  BFGUIKitExample
//
//  Created by Big Fish Games, Inc. on 6/29/11.
//  Copyright 2013 Big Fish Games, Inc.. All rights reserved.
//

#import "BFGExampleViewController.h"


@class bfgAdsController;
@class bfgBrandingViewController;

/**
 * The main menu controller
 * @author bigfishgames.com
 * @deprecated
 */
@interface BFGMainMenuViewController : BFGExampleViewController

#pragma mark - Ad Properties

@property (nonatomic, strong) IBOutlet UILabel          *versionInfo;
@property (nonatomic, strong) IBOutlet UIButton         *mainMenuRateButton;
@property (nonatomic, strong) IBOutlet UIButton         *tellAFriendButton;
@property (weak, nonatomic) IBOutlet UILabel            *welcomeLabel;

#pragma mark - Branding Methods

- (IBAction)showBranding:(id)sender;

#pragma mark - Rating Methods

-(IBAction) resetRatings:(id)sender;
-(IBAction) rateImmediately:(id)sender;

#pragma mark - Splash Methods

-(IBAction) startSplash:(id)sender; 
-(IBAction) resetSentFlag:(id)sender;

#pragma mark - More Games Methods

-(IBAction) showMoreGames:(id)sender;

#pragma mark - In App Purchase Methods

-(IBAction) showIAPScreen:(id)sender;

#pragma mark - Game Screen Methods

-(IBAction) showGameScreen:(id)sender;

#pragma mark - Tell A Friend

- (IBAction)tellFriend:(id)sender;

- (void) authenticateGameCenter;
@end
