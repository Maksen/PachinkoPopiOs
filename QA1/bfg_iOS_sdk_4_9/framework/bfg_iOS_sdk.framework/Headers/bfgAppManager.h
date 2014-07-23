///
/// \file bfgAppManager.h
/// \brief Installing and launching other apps
///
/// \since 4.6
///
// \author John Starin
// \date 10/15/2013
// \copyright (c) 2013 Big Fish Games, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - Defines for App Detection

///
/// \details This notification is posted when an app has been detected to be installed after calling startDetectingAppWithIdentifier:
///
/// \since 4.6
///
#define BFG_NOTIFICATION_APP_DETECTED @"BFG_NOTIFICATION_APP_DETECTED"

///
/// \details This is the key used to retrieve the bundle identifier of the detected app from the userInfo dictionary of the BFG_NOTIFICATION_APP_DETECTED notification.
///
/// \since 4.6
///
#define BFG_BUNDLE_IDENTIFIER_KEY @"identifier"

///
/// \details Bundle identifier of the Big Fish Games app: @"com.bigfishgames.gamefinder"
///
/// \since 4.6
///
#define BFG_BIG_FISH_GAMES_BUNDLE_ID @"com.bigfishgames.gamefinder"


#pragma mark - Defines for App Store events

///
/// \details This notification is posted when the App Store view controller has been presented (iOS 5 only).
///
/// \since 4.6
///
#define BFG_NOTIFICATION_OPENING_APP_STORE @"BFG_NOTIFICATION_OPENING_APP_STORE"

///
/// \details This notification is posted when the App Store view controller has been presented (iOS 6+).
///
/// \since 4.6
///
#define BFG_NOTIFICATION_APP_STORE_PRESENTED @"BFG_NOTIFICATION_APP_STORE_PRESENTED"

///
/// \details This notification is posted when the App Store view controller has been dismissed (iOS 6+).
///
/// \since 4.6
///
#define BFG_NOTIFICATION_APP_STORE_DISMISSED @"BFG_NOTIFICATION_APP_STORE_DISMISSED"


#pragma mark - Defines for Referral URLs

///
/// \details This notification is posted when bfgAppManager has started to open a referral URL.
///
/// \since 4.6
///
#define BFG_NOTIFICATION_OPEN_REFERRAL_URL_STARTED @"BFG_NOTIFICATION_OPEN_REFERRAL_URL_STARTED"

///
/// \details This notification is posted when bfgAppManager was able to extract an app ID from a referral URL and will attempt to open that app in the App Store.
///
/// \since 4.6
///
#define BFG_NOTIFICATION_OPEN_REFERRAL_URL_SUCCEEDED @"BFG_NOTIFICATION_OPEN_REFERRAL_URL_SUCCEEDED"

///
/// \details This notification is posted when bfgAppManager is unable to extract an app ID from the referral URL.
///
/// \since 4.6
///
#define BFG_NOTIFICATION_OPEN_REFERRAL_URL_FAILED @"BFG_NOTIFICATION_OPEN_REFERRAL_URL_FAILED"

///
/// \details This is the key used to retrieve the NSError (if any) for a connection failure from the userInfo dictionary of the BFG_NOTIFICATION_OPEN_REFERRAL_URL_FAILED notification. The userInfo dictionary may be nil if there wasn't an error.
///
/// \since 4.6
///
#define BFG_OPEN_REFERAL_URL_ERROR_KEY @"error"


#pragma mark - Defines for Download Dialog (Big Fish Games app)

///
/// \details This notification is posted when a download dialog for the Big Fish Games app is presented to the user.
///
/// \since 4.6
///
#define BFG_NOTIFICATION_DOWNLOAD_DIALOG_PRESENTED @"BFG_NOTIFICATION_DOWNLOAD_DIALOG_PRESENTED"

///
/// \details This notification is posted when the download dialog for the Big Fish Games app has been dismissed by tapping the "Download" button.
///
/// \since 4.6
///
#define BFG_NOTIFICATION_DOWNLOAD_DIALOG_DISMISSED_DOWNLOAD @"BFG_NOTIFICATION_DOWNLOAD_DIALOG_DISMISSED_DOWNLOAD"

///
/// \details This notification is posted when the download dialog for the Big Fish Games app has been dismissed by tapping the "Cancel" button.
///
/// \since 4.6
///
#define BFG_NOTIFICATION_DOWNLOAD_DIALOG_DISMISSED_CANCEL @"BFG_NOTIFICATION_DOWNLOAD_DIALOG_DISMISSED_CANCEL"


#pragma mark - bfgAppManager

///
/// \brief Installing and launching other apps.
///
@interface bfgAppManager : NSObject


#pragma mark - Launch Apps

///
/// Launches an installed app
///
/// \details Will launch an app if it is installed on the device.
/// \since 4.6
///
/// \param bundleIdentifier Bundle identifier of app to launch. Example: \@"com.bigfishgames.gamefinder"
///
/// \retval YES if the app was successfully launched.
/// \retval NO if the app is not installed.
///
+ (BOOL)launchApp:(NSString *)bundleIdentifier;

///
/// Launches an installed app and passes a parameter string to the app.
///
/// \since 4.6
///
/// \param bundleIdentifier Bundle identifier of app to launch. Example: \@"com.bigfishgames.gamefinder"
/// \param parameterString Parameter string that is passed to the app being launched. Example \@"openGuide?index=5"
///
/// \retval YES if the app was successfully launched.
/// \retval NO if the app is not installed.
///
+ (BOOL)launchApp:(NSString *)bundleIdentifier withParams:(NSString *)parameterString;


#pragma mark - Install Apps

///
/// Checks if an app is installed.
///
/// \since 4.6
///
/// \param bundleIdentifier Bundle identifier of app to check. Example: \@"com.bigfishgames.gamefinder"
///
/// \retval YES if the app is installed.
/// \retval NO if the app is not installed.
///
+ (BOOL)isAppInstalled:(NSString *)bundleIdentifier;

///
/// Presents app in the App Store for user to install.
///
/// \details Presents a modal view of the App Store with the product information for the given app ID (iOS 6 and later). On iOS 5, the user is switched out to the App Store app.
/// \since 4.6
///
/// \param appID App's iTunes identifier. This number can be found at http://linkmaker.itunes.apple.com and is a string of numbers. For example, the iTunes identifier for the iBooks app is 364709193.
+ (void)launchStoreWithApp:(NSString *)appID;

///
/// Starts polling for an app in the background.
///
/// \details When the specified app is detected by the background process, the BFG_NOTIFICATION_APP_DETECTED notification is posted. The bundle identifier of the detected app is in the userInfo dictionary with the key BFG_BUNDLE_IDENTIFIER_KEY. This method can be called multiple times to detect multiple apps simultaneously.
/// \since 4.6
///
/// \param bundleIdentifier Bundle identifier of app to detect. Example: \@"com.bigfishgames.gamefinder"
///
+ (void)startDetectingAppWithIdentifier:(NSString *)bundleIdentifier;

///
/// Stop detecting if an app is installed.
///
/// \since 4.6
///
/// \param bundleIdentifier Bundle identifier of app to detect. Example: \@"com.bigfishgames.gamefinder"
///
+ (void)stopDetectingAppWithIdentifier:(NSString *)bundleIdentifier;


#pragma mark - Big Fish Games App

///
/// Determines if the Big Fish Games app is installed.
///
/// \since 4.6
///
/// \retval YES if the Big Fish Games app was detected.
/// \retval NO if app not installed.
///
+ (BOOL)isBigFishGamesAppInstalled;

///
/// Presents the Big Fish Games app in an App Store view inside the current app (iOS 6 and above); takes user out of the current app to the App Store (iOS 5).
///
/// \details openReferralURL: is invoked with the correct URL for the user's language. @see openReferralURL: for details on expected behavior. This method does not automatically begin detecting if the Big Fish Games app has been installed.
/// \since 4.6
///
+ (void)launchStoreWithBigFishGamesApp;

///
/// Launches Big Fish Games app and opens strategy guide.
///
/// \details If the Big Fish Games app is not installed, a system dialog is presented to the user asking them to download the app. If the user taps the "Download" button, the class automatically begins detecting if the app becomes installed. A notification, BFG_NOTIFICATION_APP_DETECTED, is posted when an app is detected. @see startDetectingAppWithIdentifier: for more information.
/// \since 4.6
///
/// \param wrappingID Wrapping ID of the game.
///
/// \retval YES if app was launched.
/// \retval NO if app not installed.
///
+ (BOOL)launchBigFishGamesAppStrategyGuideWithWrappingID:(NSString *)wrappingID;

///
/// Launches Big Fish Games app and opens strategy guide to a specific chapter and page
///
/// \details If the Big Fish Games app is not installed, a system dialog is presented to the user asking them to download the app. If the user taps the "Download" button, the class automatically begins detecting if the app becomes installed. A notification, BFG_NOTIFICATION_APP_DETECTED, is posted when an app is detected. @see startDetectingAppWithIdentifier: for more information.
/// \since 4.6
///
/// \param wrappingID Wrapping ID of the game.
/// \param chapterIndex Index of strategy guide chapter.
/// \param pageIndex Index of strategy guide page in chapter.
///
/// \retval YES if app was launched.
/// \retval NO if app not installed.
///
+ (BOOL)launchBigFishGamesAppStrategyGuideWithWrappingID:(NSString *)wrappingID chapterIndex:(NSUInteger)chapterIndex pageIndex:(NSUInteger)pageIndex;


#pragma mark - Referral URLs

///
/// Opens a referral link and presents the App Store view (iOS 6+) or switches to the App Store (iOS 5).
///
/// \details A URL connection is made in the background and redirects are followed. When an App Store link is detected, the app ID is extracted and an App Store view is used to present the app in-game (iOS 6), or the user is switched to the App Store to view the app (iOS 5).
/// \since 4.6
///
/// \retval YES if the URL connection has started successfully.
/// \retval NO if the URL failed to start or the URL doesn't match one of the supported referral domains.
///
+ (BOOL)openReferralURL:(NSURL *)url;

///
/// Attempts to cancel the current referral URL that was started with openReferralURL:
///
/// \since 4.6
///
+ (void)cancelCurrentReferral;

@end
