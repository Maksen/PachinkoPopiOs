///
/// \file bfgManager.h
/// \brief Interface for performing core Big Fish SDK tasks
///
// \author Created by Sean Hummel on 10/30/10.
// \author Updated by Ben Flynn 12/18/12
// \copyright Copyright 2013 Big Fish Games, Inc. All rights reserved.
///

#import "bfglibPrefix.h"
#import "bfgadsConsts.h"

/*
 NOTIFICATIONS
 */

/// Sent after GDN play button is selected.
#define	BFGPROMODASHBOARD_NOTIFICATION_COLDSTART			@"BFGPROMODASHBOARD_NOTIFICATION_CONTINUE"

/// Sent after GDN resume button is selected.
#define BFGPROMODASHBOARD_NOTIFICATION_WARMSTART			@"BFGPROMODASHBOARD_NOTIFICATION_APPLICATION_RESUMED"

/// Sent when the More Games UI is closed (iPad only).
#define BFGPROMODASHBOARD_NOTIFICATION_MOREGAMES_CLOSED		@"BFGPROMODASHBOARD_NOTIFICATION_MOREGAMES_CLOSED"

#define BFGPROMODASHBOARD_NOTIFICATION_WEBBROWSER_CLOSED	@"BFGPROMODASHBOARD_NOTIFICATION_WEBBROWSER_CLOSED"

/// Sent after GDN main menu button is selected.
#define BFGPROMODASHBOARD_NOTIFICATION_MAINMENU				@"BFGPROMODASHBOARD_NOTIFICATION_MAINMENU"

/// Sent when new startup settings are downloaded from server
#define BFG_NOTIFICATION_STARTUP_SETTINGS_UPDATED           @"BFG_NOTIFICATION_STARTUP_SETTINGS_UPDATED"

/// Sent when new startup settings are downloaded from server
#define BFG_NOTIFICATION_TELLAFRIEND_MAILCOMPLETED           @"BFG_NOTIFICATION_TELLAFRIEND_MAILCOMPLETED"

#define BFG_NOTIFICATION_UDID_UPDATED                        @"BFG_NOTIFICATION_UDID_UPDATED"



/*
 Settings
 */

#define BFGDASH_UI_TYPE_NONE_STRING                     @"no"
#define BFGDASH_UI_TYPE_DASHFULL_STRING                 @"fs"
#define BFGDASH_UI_TYPE_DASHWIN_STRING                  @"pm"
#define BFGDASH_UI_TYPE_MOREGAMES_STRING                @"mg"
#define BFGDASH_UI_TYPE_ADS_STRING                      @"ad"

/// Whether the SDK is displaying UI and what UI is displayed.
typedef enum
{
	BFGDASH_UI_TYPE_NONE = 0, /**< The SDK is not displaying any UI. */
	BFGDASH_UI_TYPE_DASHFULL = 1, /**< The full Dashboard is displayed. */
	BFGDASH_UI_TYPE_DASHWIN = 2, /**< The Dashboard in a window is displayed. */
	BFGDASH_UI_TYPE_MOREGAMES = 3 /**< The More Games UI is displayed. */
}
BFGDASH_UI_TYPE;


/**
 @brief Initialize the Big Fish Game Components.
 
 Initialize bfgManager to enable the Big Fish Game Discovery Network (GDN).
 
 You should initialize the bfgManager when your application finishes launching with either your root view controller
 or your main window.
 
 \code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
 ...
 [bfgManager initializeWithViewController: myRootViewController];
 ...
 }
 
 \endcode
 
 If you are using these APIs, you should become an observer for the following events:
 
 <UL>
 <LI>BFGPROMODASHBOARD_NOTIFICATION_COLDSTART - Sent after the GDN play button is selected.
 <LI>BFGPROMODASHBOARD_NOTIFICATION_WARMSTART - Sent after the GDN resume button is selected.
 <LI>BFGPROMODASHBOARD_NOTIFICATION_MAINMENU - Sent after the GDN Main Menu button is selected.
 <LI>BFGPROMODASHBOARD_NOTIFICATION_MOREGAMES_CLOSED - Sent when the More Games UI closes (iPad only).
 </UL>
 
 If your application needs to be notified when an ad or a GDN element has navigated away from the application to a URL,
 you should also become an observer of these events:
 
 <UL>
 <LI>BFGLIB_NOTIFICATION_OPENLINKSHAREURL_STARTED - Navigation to the URL has started.
 <LI>BFGLIB_NOTIFICATION_OPENLINKSHAREURL_LONGDELAY - A long delay has occurred since navigation to the URL was started.
 <LI>BFGLIB_NOTIFICATION_OPENLINKSHAREURL_ENDED - Navigation to the URL has ended.
 </UL>
 
 */
@interface bfgManager : NSObject


///
/// \details The view controller to use when showing the GDN,
/// for both startup and resume UI. This view controller can be
/// updated with the bfgManager::setParentViewController API.
///
+ (void)initializeWithViewController:(UIViewController *)controller;


///
/// \details Number of session for the application. Incremented on each UIApplicationDidBecomeActiveNotification.
///
+ (NSInteger)sessionCount;


///
/// \details It is the initial launch or "install" of the application.
///
+ (BOOL)isInitialLaunch;


///
/// \details Application has been started from a cold-started.
///
+ (BOOL)isFirstTime;


///
/// \return
/// \retval YES if bfgManger initialized.
/// \retval NO if bfgManger did not initialize.
///
+ (BOOL)isInitialized;


///
/// \details Gets the unique integer identifying this user. Used in all reporting call to services.
///
+ (NSNumber *)userID;


///
/// \details Sets the unique integer identifying this user. Used in all reporting call to services.
///
/// @param
/// userID
+ (void)setUserID:(NSNumber *)userID;

///
/// \details Get the COPPA opt out value, this is NO by default.
///
+ (BOOL)coppaOptOut;

///
/// \details To comply with COPPA regulations and standards, call this method to indicate that the user is under 13.
/// This is set to NO by default.
///
/// @param
/// yesOrNo Yes = The user is under 13. No = The user is 13 or over.
+ (void)setCoppaOptOut:(BOOL)yesOrNo;


///
/// \details Shows the More Games UI.
///
/// If you are using these APIs, you can become an observer
/// for the following events:
///
/// - BFGPROMODASHBOARD_NOTIFICATION_MOREGAMES_CLOSED - More Games UI has been closed.
/// - BFGMOREGAMES_NOTIFICATION_MAILCOMPLETED - More Games mail has been sent.
///
+ (void)showMoreGames;


///
/// \details Removes the More Games UI Interface automatically when the close button
/// is selected or a touch occurs outside the UI.
///
/// - BFGPROMODASHBOARD_NOTIFICATION_MOREGAMES_CLOSED - Notification is sent that the More Games UI has been closed.
///
+ (void)removeMoreGames;


///
/// \details Show the support page with the in-game browser.
///
+ (void)showSupport;


///
/// \details Shows the Privacy page with the in-game browser.
///
+ (void)showPrivacy;


///
/// \details Shows the terms of use page with the in-game browser.
///
+ (void)showTerms;


///
/// \details Shows an in-game browser displaying startPage.
///
+ (void)showWebBrowser:(NSString *)startPage;


///
/// \details Should your game display the "Tell A Friend" button?
///
/// \return
/// \retval YES if the URL to email the app has been downloaded from the servers.
/// \retval NO if the URL to email the app has not been downloaded from the servers.
///
+ (BOOL)canShowTellAFriendButton;

///
/// \details Shows the Tell a Friend email UI
///
+ (BOOL)showTellAFriend;


///
/// \details Removes the in-game browser shown via showWebBrowser:
///
+ (void)removeWebBrowser;


///
///
///
+ (UIInterfaceOrientation)currentOrientation;


///
/// \return
/// \retval YES if there is a connection to the Internet.
/// \retval NO if there is not a connection to the Internet, and displays alert.
///
+ (BOOL)checkForInternetConnection;


///
/// \param displayAlert If YES, displays a UIAlert it cannot connect to the Internet.
/// \return
/// \retval YES if can connect to the Internet.
/// \retval NO if cannot connect to the Internet.
///
+ (BOOL)checkForInternetConnectionAndAlert:(BOOL)displayAlert;


///
/// \details The view controller to use when showing the GDN,
/// for both startup and resume UI. If you change your root ViewController
/// for your application, you should update bfgManager.
///
+ (void)setParentViewController:(UIViewController *)parent;
+ (UIViewController *)getParentViewController __deprecated;
+ (UIViewController *)parentViewController;


///
/// \details Starts branding animation running based on contents of bfgbranding_resources.zip.
///
+ (BOOL)startBranding;


///
/// \details Stops the branding animation. The BFGBRANDING_NOTIFICATION_COMPLETED notification will be sent.
///
+ (void)stopBranding;


///
/// \return
/// \retval YES if ads are currently running.
/// \retval NO if ads are not currently running.
///
+ (BOOL)adsRunning;


///
/// \details Starts ads based on the origin.
///
+ (BOOL)startAds:(bfgadsOrigin)origin;


///
/// \details Stops the currently running ads.
///
+ (void)stopAds;


///
/// \details Returns enum value for the current UI displayed by the SDK.
/// \return
/// \ref BFGDASH_UI_TYPE
///
///	\ref BFGDASH_UI_TYPE_NONE = 0
///
///	\ref BFGDASH_UI_TYPE_DASHFULL = 1
///
///	\ref BFGDASH_UI_TYPE_DASHWIN = 2
///
///	\ref BFGDASH_UI_TYPE_MOREGAMES = 3

+ (BFGDASH_UI_TYPE)currentUIType;


#define BFG_LAUNCH_INSTALL_BFGMOBILEAPP         @"bfg_launch_install_bfgmobileapp"
#define BFG_LAUNCH_ISPLASH                      @"bfg_launch_isplash"
#define BFG_LAUNCH_MORE_GAMES                   @"bfg_launch_more_games"
#define BFG_LAUNCH_TELL_A_FRIEND                @"bfg_launch_tell_a_friend"
#define BFG_LAUNCH_LOGIN                        @"bfg_launch_login"
#define BFG_LAUNCH_WEBBROWSER                   @"bfg_launch_webbrowser"
#define BFG_LAUNCH_GDN                          @"bfg_launch_gdn"

///
/// launchSDKByURLScheme
/// @details Trims URL Scheme and launches by keyword
+(BOOL)launchSDKByURLScheme:(NSString *)urlScheme;


@end
