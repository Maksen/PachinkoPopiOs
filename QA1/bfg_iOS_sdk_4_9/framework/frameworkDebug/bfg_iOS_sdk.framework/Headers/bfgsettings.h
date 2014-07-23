//
/// \file bfgsettings.h
/// \brief A mechanism for persisting key-value pairs
//
// \author Created by Sean Hummel on 10/2/10.
// \copyright Copyright (c) 2013 Big Fish Games, Inc. All rights reserved.
//

#import "bfglibPrefix.h"

typedef int bfgSettingsStorageType;

FOUNDATION_EXPORT bfgSettingsStorageType const kBfgSettingsStorageTypePlist;
FOUNDATION_EXPORT bfgSettingsStorageType const kBfgSettingsStorageTypeLocalKeychain;
FOUNDATION_EXPORT bfgSettingsStorageType const kBfgSettingsStorageTypeSharedKeychain;


/// Notification sent when a setting is changed. The object part of the notification contains the @"key" and the new @"value".
#define	NOTIFICATION_BFGSETTING_CHANGED	@"NOTIFICATION_BFGSETTING_CHANGED"


// SDK Settings -- Many or all of these macros will likely become private in the future


// Used for setting an alternate mobile service server in the default settings json. Valid for debug builds only.
#define BFG_SETTING_MOBILE_SERVICE                      @"mobile_service"

// Used for setting an alternate device service server in the default settings json. Valid for debug builds only.
#define BFG_SETTING_DEVICE_SERVICE                      @"device_service"

// Used for setting an alternate purchase service server in the default settings json. Valid for debug builds only.
#define BFG_SETTING_PURCHASE_SERVICE                    @"purchase_service"

// A Big Fish specific user ID
#define BFG_SETTING_BFGUDID                             @"BFGUDID"

// A user ID
#define BFG_SETTING_UID                                 @"UID"

// The package version that gets sent to the startup server
#define BFG_SETTING_STARTUP_PACKAGE_VER                 @"package_version"

// URL for downloading icon data
#define BFG_SETTING_ICON_URL                            @"icon_url"

// URL for downloading ad data
#define BFG_SETTING_AD_URL                              @"ad_url"

// URL for downloading iSplash data
#define BFG_SETTING_ISPLASH_URL                         @"isplash_url"

// The app's ID with Apple
#define BFG_SETTING_APPLE_APP_ID                        @"app_id"

// The store used by the app
#define BFG_SETTING_APP_STORE                           @"app_store"

// Key for messages sent from server
#define BFG_SETTING_NOTIFICATION_PROMPTS                @"prompts"

// Key for weekly specials / deals
#define BFG_SETTING_WEEKLY_SPECIALS                     @"weekly_specials"

// URL for app store review
#define BFG_SETTING_REVIEW_URL                          @"review_url"

#define BFG_SETTING_PLAYHAVEN                           @"playhaven"

// URL for app store rating
#define BFG_SETTING_RATING_URL                          @"rating_url"
#define BFG_SETTING_KONTAGENT                           @"kontagent"
#define BFG_SETTING_KT_ARCHIVE_IDX                      @"kontagent_archive_idx"

#define BFG_SETTING_HASOFFERS                           @"hasoffers"

// This is used by legacy games to determine newletter status, don't change
#define BFGSETTING_NEWSLETTER_SENT                      @"newsletter_subscribed"

// Big Fish determined session ID
#define BFG_SETTING_SESSION_ID                          @"session_id"

// Enable/disable flurry analytics
#define BFG_SETTING_FLURRY_CRASH_ANALYTICS              @"crash_analytics"

// Start time (NSDate *) of current session
#define BFG_SETTING_SESSION_STARTTIME                   @"session_starttime"

// Time spent in session (NSTimeInterval)
#define BFG_SETTING_SESSION_PLAYTIME                    @"game_playtime"

// Used for reporting new installs
#define BFG_SETTING_SESSION_NEW_INSTALL                 @"bfg_setting_session_new_install"

// Number of sessions
#define BFG_SETTING_SESSION_COUNT                       @"session_count"

// Can show the Big Fish dashboard?
#define BFGPROMODASHBOARD_SETTING_ENABLED				@"dashboard_active"

// Wait at least this long before potentially showing dashboard
#define BFGPROMODASHBOARD_SETTING_TIMEOUT				@"dashboard_timeout"

// Ignore showing the dashboard while this is greater than zero. Decremented on each
// attempt to show dashboard.
#define BFGPROMODASHBOARD_SETTING_TRIGGER_COUNTDOWN		@"dashboard_show_after_this_many_runs"

// Defines the display behavior of the dashboard. "free", "paid"
#define BFGPROMODASHBOARD_SETTING_DISPLAY_TYPE			@"dashboard_display_type"

// Used for SDK internal state
#define BFG_SETTING_PACKAGE_MANAGER_IN_PROGRESS			@"package_manager_in_progess"

///
/// \brief Stores settings to disk automatically so that other libraries can use keys to retrieve them.
///
/// Developers can use this class to store settings used in their own libraries.
///
@interface bfgSettings : NSObject 


///
/// \return Is this storage type available for use?
/// \retval YES Storage type is available for use.
/// \retval NO Storage type is not available for use.
///
/// \since 4.7
///
+ (BOOL)canUseStorageType:(bfgSettingsStorageType)storageType;


///
/// \details Serializes the settings plist to disk.
///
/// \return
/// \retval YES if serialization completed successfully.
/// \retval NO if serialization did not complete.
///
/// \since 2.2
///
+ (BOOL)write;


///
/// \details Persists the relevant settings to the requested storage type.
///
/// \return
/// \retval YES if serialization completed successfully.
/// \retval NO if serialization did not complete.
///
/// \since 4.7
///
+ (BOOL)writeStorageType:(bfgSettingsStorageType)storageType;


///
/// \details Sets a settings value for a key for the settings plist.
///
/// \param key The key to write the value to.
/// \param value The value to write.
///
/// \since 2.2
///
+ (void)set:(NSString*)key value:(id)value;


///
/// \details Sets a settings value for a key for the requested storage type.
///
/// \param key The key to write the value to.
/// \param value The value to write.
/// \param storageType The medium on which to persist the values (plist, local keychain, etc.)
///
/// \since 4.7
///
+ (void)set:(NSString*)key value:(id)value storageType:(bfgSettingsStorageType)storageType;


///
/// \details Gets a setting value for a key from the settings plist.
///
/// \param key The key for the value to be retrieved.
/// \return The value from the settings.
///
/// \since 2.2
///
+ (id)get:(NSString*)key;


///
/// \details Gets a setting value for a key from the requested storage type.
///
/// \param key The key for the value to be retrieved.
/// \param storageType The medium on which to persist the values (plist, local keychain, etc.)
/// \return The value from the settings.
///
/// \since 4.7
///
+ (id)get:(NSString *)key storageType:(bfgSettingsStorageType)storageType;


///
/// \details Gets a setting value for a key from the settings plist, and allows for default if the key does not exist.
///
/// \param key The key for the value to be retrieved.
/// \param defaultValue The default value to be returned when no value is set for the key.
/// \return The value from settings, or withDefault if nil.
///
/// \since 2.2
///
+ (id)get:(NSString*)key withDefault:(id)defaultValue;


///
/// \details Gets a setting value for a key from the requested storage type,
/// and allows for default if the key does not exist.
///
/// \param key The key for the value to be retrieved.
/// \param defaultValue The default value to be returned when no value is set for the key.
/// \param storageType The medium on which to persist the values (plist, local keychain, etc.)
/// \return The value from settings, or withDefault if nil.
///
/// \since 4.7
///
+ (id)get:(NSString*)key withDefault:(id)defaultValue storageType:(bfgSettingsStorageType)storageType;


///
/// \details Not all objects are serializable. Perform a quick check on a value
/// to determine its eligability.
///
/// \param value A value we wish to write to the storage medium
/// \param storageType The medium on which to persist the values (plist, local keychain, etc.)
///
/// \retval YES value can be written to specified storage type.
/// \retval NO value cannot be written to specified storage type.
///
/// \since 4.7
///
+ (BOOL)isPersistable:(id)value storageType:(bfgSettingsStorageType)storageType;


@end


