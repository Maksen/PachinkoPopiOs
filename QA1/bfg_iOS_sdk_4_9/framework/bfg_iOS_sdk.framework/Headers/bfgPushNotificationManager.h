///  \file bfgPushNotificationManager.h
///  \brief bfgPushNotificationManager header file.
///
//  \author Created by Michelle McKelvey on 3/18/14.
//  \author Edited by Craig Thompson on 5/2/14.
//  \copyright Copyright (c) 2014 Big Fish Games, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

/// \brief Enables push notifications.

/// \details Class to implement push notifications in a game. You must change your application delegate methods to the bfgPushNotificationManager methods in order to implement push notifications.

@interface bfgPushNotificationManager : NSObject

@property (nonatomic, retain) NSDictionary *userInfo;

///
///  registerForPlayHavenPushNotifications
///
///  \details Called when game decided to register the user for Push Notification. The "Do you want to enable push?" dialog will display as a result.
///
+(void) registerForPlayHavenPushNotifications;

///
///
///  handleRemoteNotificationWithLaunchOption
///
///  \details Called from your UIApplicationDelegate in application:didFinishLaunchingWithOptions:
///
///  @param
///  launchOptions Options from didFinishLaunchingWithOptions.
///
+(void) handleRemoteNotificationWithLaunchOption:(NSDictionary *)launchOptions;

///
///  registerDeviceToken
///
///  \details Called from your UIApplicationDelegate in application:didRegisterForRemoteNotificationsWithDeviceToken:
///
///  \return didRegisterForRemoteNotificationsWithDeviceToken: returns on success.
///  \return didFailToRegisterForRemoteNotificationsWithError: returns on failure.
///
///  @param
///  deviceToken Device token from application:didRegisterForRemoteNotificationsWithDeviceToken:
///
+(void) registerDeviceToken:(NSData*)deviceToken;

///
///  didFailToRegisterWithError
///
///  \details Must be called from application:didFailToRegisterForRemoteNotificationsWithError:
///
///  @param
///  error Error param from didFailToRegisterForRemoteNotificationsWithError:
///
+(void) didFailToRegisterWithError:(NSError*)error;

///
///  handlePush
///
///
///  \details Called from your UIApplicationDelegate in application:didReceiveRemoteNotification:
///
///  \return User information.
///
///  @param
///  userInfo From application:didReceiveRemoteNotification:
///
+(void) handlePush:(NSDictionary *)userInfo;

///
///  setIconBadgeNumber
///
///
///  \details Set badge numbers for application icon. 
///
///  @param
///  newNumber Number to set the badge number to.
///
+(void) setIconBadgeNumber:(int) newNumber;

///
///  pushRegistrationInProgress
///
///
///  \details The OS will trigger a resign notification when the Push Registration dialog appears. If you want to be able to differentiate this from other resigns, use this API.
///
+(BOOL) pushRegistrationInProgress;

@end
