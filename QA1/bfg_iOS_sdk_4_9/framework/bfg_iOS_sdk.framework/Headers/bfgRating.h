///
/// \file bfgRating.h
/// \brief Manages prompting for game rating
///
//  bfg_iOS_sdk
//
// \author Created by Arash Payan on 9/5/09.
// \author Updated by Sean Hummel.
// \author Updated by Craig Thompson on 10/1/13.
// \copyright Copyright (c) 2013 Big Fish Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bfglibPrefix.h"

/// Notification that rating alert is being shown. Game should pause.
#define BFGRATING_NOTIFICATION_RATING_ALERT_OPENED		@"BFGRATING_NOTIFICATION_RATING_ALERT_OPENED"

/// Notification that rating alert has been dismissed.
#define BFGRATING_NOTIFICATION_RATING_ALERT_CLOSED		@"BFGRATING_NOTIFICATION_RATING_ALERT_CLOSED"

///
/// \brief Enables users to rate games.
/// \details If you are using these APIs, you can become an observer 
/// for the following events:
///
/// - BFGRATING_NOTIFICATION_RATING_ALERT_OPENED - The "Rate this Game" dialog has been shown.
/// - BFGRATING_NOTIFICATION_RATING_ALERT_CLOSED - The "Rate this Game" dialog has been closed.
///
/// How ratings work:
/// ImmediateTrigger will always show the Ratings dialog, it does not use display logic at all.
///
/// Display logic for the ratings dialog is as follows:
/// - If the time since you first launched the game is less than the time until the rating, do not show the dialog, return;
/// - If the application use count is less than USES UNTIL PROMPT, do not show the dialog, return;
/// - If the user significant events count is less than SIG_EVENTS UNTIL, do not show the dialog, return;
/// - If the user previously declined to rate this version of the application, do not show the dialog, return;
/// - If the user already rated the application, do not show the dialog, return;
/// - If the user wanted to be reminded later, and if not enough time has passed, do not show the dialog, return;
/// - Show dialog;
///
@interface bfgRating : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) UIAlertView *alertView;

/// \details Initializes the bfgRating class. Not required if bfgManager is already initialized.
+ (void)initialize;

/// \details Restores rating system to its initial state, as if the user had never been
/// prompted to rate the game.
+ (void)reset;


///
/// \details Tells Appirater that the user performed a significant event. A significant
/// event is whatever you want it to be. If your app is used to make VoIP
/// calls, then you might want to call this method whenever the user places
/// a call. If your app is a game, you might want to call this whenever the user
/// beats a level boss.
///
/// If the user has performed enough significant events and used the app enough,
/// you can suppress the rating alert by passing NO for canPromptForRating. The
/// rating alert will simply be postponed until it is called again with YES for
/// canPromptForRating. The rating alert can also be triggered by appLaunched:
/// and appEnteredForeground: (as long as you pass YES for canPromptForRating
/// in those methods).
///
+ (void)userDidSignificantEvent:(BOOL)canPromptForRating;

///
/// \details If you have your own system for triggering, this will
///	show the rating dialog regardless of all other settings.
+ (void)immediateTrigger;

///
/// \details Used to navigate directly to the App Store's rating page.
///	Should be called when users clicks on "Rate App" from the Main Menu.
+ (void)mainMenuRateApp;

///
/// \return
/// \retval YES if the user has already rated this version of the app.
/// \retval NO if the user has not rated this version of the app.
///	
+ (BOOL)hasRatedApp;

///
/// \details Should your game display the "Rate Me!" button on the Main Menu?
///
/// \return
/// \retval YES if the user has not already rated the app, and if the URL
/// to rate the app has been downloaded from the servers.
/// \retval NO if the user has rated the app.
///
+ (BOOL)canShowMainMenuRateButton;

@end