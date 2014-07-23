/// \file bfgLoginController.h
/// \brief bfgLoginController header file.
///
// \author Created by Benjamin Flynn on 6/28/13.
// \copyright Copyright 2013 Big Fish Games, Inc. All rights reserved.
///


#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

/// The user logged in, logged out, or logged in as a different user
///
/// \since 4.5.0
#define BFG_NOTIFICATION_LOGIN_STATUS_CHANGE                    @"BFG_NOTIFICATION_LOGIN_STATUS_CHANGE"

/// Delivered in the userInfo of the status change notification. Returns the HMID of the logged
/// in user or nil if the user is not logged in.
///
/// \since 4.5.0
#define BFG_LOGIN_STATUS_CHANGE_KEY_ACTIVE_HMID                 @"BFG_LOGIN_STATUS_CHANGE_KEY_ACTIVE_HMID"

/// Delivered in the userInfo of the status change notification. Returns the HMID of the previous user
/// if the app is re-entered with a different user active than when the app was backgrounded. Otherwise
/// this value is undefined.
///
/// \since 4.5.0
#define BFG_LOGIN_STATUS_CHANGE_KEY_PREVIOUS_HMID               @"BFG_LOGIN_STATUS_CHANGE_KEY_PREVIOUS_HMID"

/// The login UI has is being presented.
///
/// \since 4.5.1
#define BFG_NOTIFICATION_LOGIN_OPENED                           @"BFG_NOTIFICATION_LOGIN_OPENED"

/// The login UI has been fully dismissed.
///
/// \since 4.5.0
#define BFG_NOTIFICATION_LOGIN_CLOSED                           @"BFG_NOTIFICATION_LOGIN_CLOSED"

///
/// \brief Manages BigFish Login.
///
/// The login controller accesses information about the user that is shared across apps.
/// All apps have access to whether the user is logged in and a hashed identifier of the
/// most recent user to log in.
///
/// Additionally, apps can allow the user to log in and out. The app must present
/// "Sign In" and "Sign Out" buttons (depending on the login state of the user). The
/// app must call "startService" on the bfgLoginController. Implementing these methods
/// gives the app access to the current user's "nickname."
///
/// The login UI is presented over the current view controller. It is semi-transparent.
/// It is presented as a child view controller in the parent view controller specified in
/// bfgManager. It posts a notification when dismissed. The logout button has no UI.
///
/// If you are using these APIs, you may wish to become an observer
/// for the following events:
///
/// - BFG_NOTIFICATION_LOGIN_STATUS_CHANGE
/// - BFG_NOTIFICATION_LOGIN_CLOSED
///
/// \since 4.5.0
///
@interface bfgLoginController : NSObject

///
/// \return
/// \retval YES User has successfully logged in and has not logged out.
/// \retval NO User has not logged in or has interactively logged out.
///
+ (BOOL)isLoggedIn;


///
/// \return
/// \retval YES The login UI is visible on the screen.
/// \retval NO The login UI has not been displayed or has been dismissed.
///
+ (BOOL)isLoginUIVisible;

///
/// \brief Present the welcomeBack UI to user
///
+ (void)presentWelcomeBack;

///
/// \return A hashed ID of the logged-in user, or the most recently logged-in user.
///
+ (NSString *)latestHMID;


///
/// \return The username of the logged-in user, if it exists. If the unique username "nickname" does not exist, the username part of the email address
/// of the logged-in user will be used instead. If the user is not logged in, or if name information is unexpectedly missing, returns
/// nil.
///
+ (NSString *)loggedInNickname;


///
/// \details Generates a localized Sign In button. You are responsible for adding this button to
/// your view hierarchy.
///
/// \param frame CGRect defining the size and position of the button relative to its container.
/// \param lightColor If YES, button will have light-colored graphics suitable for dark backgrounds.
/// \return A UIButton with localized sign-in text. This button will launch the bfgLogin UI when tapped.
///
+ (UIButton *)logInButtonWithFrame:(CGRect)frame lightColor:(BOOL)lightColor;


///
/// \details Generates a localized sign in button image.
///
/// \param frame CGRect defining the size and position of the button relative to its container.
/// \param lightColor If YES, button will have light-colored graphics suitable for dark backgrounds.
/// \return A UIImage with localized sign-in text.
///
+ (UIImage *)logInButtonNormalImage:(CGRect)frame lightColor:(BOOL)lightColor;


///
/// \details Generates a localized Sign In button image for the button's highlighted display.
///
/// \param frame CGRect defining the size and position of the button relative to its container.
/// \param lightColor If YES, button will have light-colored graphics suitable for dark backgrounds.
/// \return A UIImage with localized sign-in text.
///
+ (UIImage *)logInButtonHighlightImage:(CGRect)frame lightColor:(BOOL)lightColor;


///
/// \details Generates a localized Sign Out button. You are responsible for adding this button to
/// your view hierarchy.
///
/// \param frame CGRect defining the size and position of the button relative to its container.
/// \param lightColor If YES, button will have light-colored graphics suitable for dark backgrounds.
/// \return A UIButton with localized sign-out text. This button will sign the user out when tapped.
///
+ (UIButton *)logOutButtonWithFrame:(CGRect)frame lightColor:(BOOL)lightColor;


///
/// \details Generates a localized Sign Out button image.
///
/// \param frame CGRect defining the size and position of the button relative to its container.
/// \param lightColor If YES, button will have light-colored graphics suitable for dark backgrounds.
/// \return A UIImage with localized sign-out text.
///
+ (UIImage *)logOutButtonNormalImage:(CGRect)frame lightColor:(BOOL)lightColor;


///
/// \details Generates a localized Sign Out button image for the button's highlighted display.
///
/// \param frame CGRect defining the size and position of the button relative to its container.
/// \param lightColor If YES, button will have light-colored graphics suitable for dark backgrounds.
/// \return A UIImage with localized sign-out text.
///
+ (UIImage *)logOutButtonHighlightImage:(CGRect)frame lightColor:(BOOL)lightColor;


///
/// \details Presents the Big Fish login UI, if connected to the network.
///
/// \return
/// \retval YES Login UI is being presented.
/// \retval NO Login UI could not be presented.
///
+ (BOOL)showLogin;


///
/// \details Logs user out of Big Fish.
///
+ (void)logOut;


///
/// \details Call startService to enable signing in and out of Big Fish accounts. If your app does
/// not provide the user means to log in and out, do NOT call this method.
///
+ (void)startService;

@end
