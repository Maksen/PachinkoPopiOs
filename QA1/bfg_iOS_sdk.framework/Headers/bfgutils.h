/// \file bfgutils.h
/// \brief BFG utilities
///
// \author Big Fish Games
// \copyright Copyright 2013 Big Fish Games. All rights reserved.
/// \details Helpful utility methods.

#import "bfglibPrefix.h"


/// Navigation to the URL has started
#define BFGLIB_NOTIFICATION_OPENLINKSHAREURL_STARTED	@"BFGLIB_NOTIFICATION_OPENLINKSHAREURL_STARTED"
/// A long delay has occurred since navigation to the URL was started
#define BFGLIB_NOTIFICATION_OPENLINKSHAREURL_LONGDELAY	@"BFGLIB_NOTIFICATION_OPENLINKSHAREURL_LONGDELAY"
/// Navigation to the URL has ended
#define BFGLIB_NOTIFICATION_OPENLINKSHAREURL_ENDED		@"BFGLIB_NOTIFICATION_OPENLINKSHAREURL_ENDED"

/// NSString representation of an undefined BFGUDID
#define BFGUDID_UNDEFINED   @"0000000000000000000000000000000000000000"

/// Macro that adds a key value pair only if the value is YES
#define addToDictionaryIfTrue(dictionary, key, value) if (value) { dictionary[key] = value; }

/// NSString representation of a BOOL (@"YES" or @"NO").
NSString* NSStringFromBOOL(BOOL aBOOL);

/// dispatch_time from milliseconds.
dispatch_time_t dispatch_time_delay_from_milliseconds(int64_t milliseconds);

/// Macro that converts colors with integer values between [0-255] to floating point components
#define RGB_COMPONENTS(r, g, b, a)  (r) / 255.0f, (g) / 255.0f, (b) / 255.0f, (a)

/// Macro for detecting iOS 6.0 and above
#define IS_IOS6_AWARE (__IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1)

/// \brief bfgutils class
@interface bfgutils : NSObject

/// Dimmensions of actual screen pixels.
+ (CGSize)screenPixels;

/// Dimmensions of screen points for the current orientation.
+ (CGSize)screenPixelsWithOrientation;

/// \return
/// \retval YES if the current device is an iPad.
/// \retval NO if otherwise.
+ (BOOL)iPadMode;

/// \return
/// \retval YES if the current device is an iPad with retina display.
/// \retval NO if otherwise.
+ (BOOL)iPad3Mode;

/// \return
/// \retval YES if the current device is an iPhone/iPod.
/// \retval NO if otherwise.
+ (BOOL)iPhoneMode;

/// \return
/// \retval YES if the current device is an iPhone/iPod with retina display.
/// \retval NO if otherwise.
+ (BOOL)iPhone4Mode;

/// \return
/// \retval YES if the current device is an iPhone/iPod with a 4" retina display.
/// \retval NO if otherwise.
+ (BOOL)iPhone5Mode;

/// \return
/// \retval YES if the current iOS version is greater than or equal to versionString
/// \retval NO if otherwise.
+ (BOOL)SystemVersionGreaterThanOrEqualTo:(NSString *)versionString;

/// \return A BigFish identifier for the user. NOT Apple's UDID.
+ (NSString *)bfgUDID;

/// \return
/// \retval YES if IFA tracking has been enabled.
/// \retval NO if otherwise.
+ (BOOL)bfgIFAEnabled; // Return if IFA tracking has been enabled/disabled

/// \return IFA for device.
+ (NSString *)bfgIFA; // Return the IFA for device

/// \return Game Center Player ID if user is logged into Game Center; nil otherwise.
+ (NSString *)gameCenterPlayerID; // If logged into Game Center, returns the Game Center Player ID

/// \return MAC address of the device; for example: 'AB:CD:EF:01:23:45'
+ (NSString *)getMACAddress; // MAC Address of the device

/// \return Name of the user's home carrier; nil if unavailable.
+ (NSString *)userDeviceCarrierName;

/// \return Country code of the user's device.
+ (NSString *)userCountryCode;

/// \return Preferred language of the user's device.
+ (NSString *)userPreferredLanguage;

+(NSString *)jsonStringFromObject:(id)object;
+(id)objectFromJSONString:(NSString *)jsonString;
+(id)objectFromJSONData:(NSData *)jsonData;

@end
