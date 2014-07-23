//
/// \file bfgGameReporting.h
/// \brief Used by game to report significant events.
//  bfg_iOS_sdk
//
// \author Created by Michelle McKelvey on 3/5/12.
// \author Updated by Craig Thompson on 4/11/14.
// \copyright Copyright (c) 2013 Big Fish Games, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "bfgReporting.h"

///
///
/// Support for Placement Notification and keys
///
///

/// Placement keys contained in notification.userInfo NSDictionary
#define BFG_PLACEMENT_CONTENT_NAME_KEY @ "contentName"
#define BFG_PLACEMENT_CONTENT_TRIGGER_KEY @ "contentTrigger"

/// Reward keys contained in notification.userInfo NSDictionary
#define BFG_PLACEMENT_REWARD_NAME_KEY @"rewardName"
#define BFG_PLACEMENT_REWARD_QUANTITY_KEY @"rewardQuantity"
#define BFG_PLACEMENT_REWARD_RECEIPT_KEY @"rewardReceipts"


#define BFG_PLACEMENT_PURCHASE_PRODUCTID_KEY @"purchaseProductID"
#define BFG_PLACEMENT_PURCHASE_ITEM_KEY @"purchaseItem"
#define BFG_PLACEMENT_PURCHASE_QUANTITY_KEY @"purchaseQuantity"
#define BFG_PLACEMENT_PURCHASE_RECEIPT_KEY @"purchaseReceipt"


#define BFG_NOTIFICATION_PLACEMENT_CONTENT_OPENED                  @"BFG_NOTIFICATION_PLACEMENT_CONTENT_OPENED"
#define BFG_NOTIFICATION_PLACEMENT_CONTENT_CLOSED                  @"BFG_NOTIFICATION_PLACEMENT_CONTENT_CLOSED"
#define BFG_NOTIFICATION_PLACEMENT_CONTENT_ERROR                   @"BFG_NOTIFICATION_PLACEMENT_CONTENT_ERROR"
#define BFG_NOTIFICATION_PLACEMENT_CONTENT_UNLOCK_REWARD_OPENED    @"BFG_NOTIFICATION_PLACEMENT_CONTENT_UNLOCK_REWARD_OPENED"
#define BFG_NOTIFICATION_PLACEMENT_CONTENT_UNLOCK_REWARD_CLOSED    @"BFG_NOTIFICATION_PLACEMENT_CONTENT_UNLOCK_REWARD_CLOSED"
#define BFG_NOTIFICATION_PLACEMENT_CONTENT_START_PURCHASE          @"BFG_NOTIFICATION_PLACEMENT_CONTENT_START_PURCHASE"


///
///
/// Required game logging APIs.
///
///

/// \details This class is used for reporting all game events.
///
@interface bfgGameReporting : NSObject


///
/// \details Called each time the Main Menu is shown.
///
+ (void)logMainMenuShown;


///
/// \details Called each time Rate from the Main Menu is canceled.
///
+ (void)logRateMainMenuCanceled;


///
/// \details Called each time the Options Menu is shown.
///
+ (void)logOptionsShown;


///
/// \details Called each time purchase from the Main Menu is shown.
///
+ (void)logPurchaseMainMenuShown;

///
/// \details Called each time purchase from the Main Menu is closed.
///
+ (void)logPurchaseMainMenuClosed;

///
/// \details Called each time a non-mainmenu purchase paywall is shown with an identifier for the paywall.
///
+ (void)logPurchasePayWallShown:(NSString *)paywallID;


///
/// \details Called each time a non-mainmenu purchase paywall is closed with an identifier for the paywall.
///
+ (void)logPurchasePayWallClosed:(NSString *)paywallID;

///
/// \details Called each time a level has started.
///
+ (void)logLevelStart:(NSString *)levelID;


///
/// \details Called each time a level is finished.
///
+ (void)logLevelFinished:(NSString *)levelID;


///
/// \details Called each time a mini game is started.
///
+ (void)logMiniGameStart:(NSString *)miniGameID;


///
/// \details Called each time a mini game is skipped.
///
+ (void)logMiniGameSkipped:(NSString *)miniGameID;


///
/// \details Called each time a mini game is finished.
///
+ (void)logMiniGameFinished:(NSString *)miniGameID;


///
/// \details Called each time an achievement is earned.
///
+ (void)logAchievementEarned:(NSString *)achievementID;

///
/// \details Called each time a hint is requested.
///
+ (void)logGameHintRequested;

//
// \details  Calls the In-App Purchase screen when the purchase button is selected.
//
// purchaseButton can be one of the following values:
// BFG_PURCHASE_BUTTON_BUY,
// BFG_PURCHASE_BUTTON_RESTORE,
// BFG_PURCHASE_BUTTON_LATER,
// BFG_PURCHASE_BUTTON_CLOSE
//
//  Removed Flurry Events
// + (void)logIAPButtonTapped:(BFG_PURCHASE_BUTTON)purchaseButton;


///
/// \details Called when the game is completed.
///
+ (void)logGameCompleted;

///
/// \details logCustomEvent logs a custom event.
///
/// @param
/// name The name of the event at its lowest level of detail.
/// @param
/// value The value of this parameter is dependent on eventDetails1.
/// @param
/// level This parameter can be used to track game levels where custom events occur. 
/// If it is not applicable to your event, you should use 1.
/// @param
/// details1 This field should be outlined in a document provided by your producer.
/// @param
/// details2 Typically reflects the "type" of an event occurring within details1.
/// @param
/// details3 Typically describes the method or location of an event.
/// @param
/// additionalDetails For reporting purposes, any additional data pertaining to the event 
/// can be added as a dictionary. This *must* be 
/// a flat dictionary containing only NSString * as keys and values.
///
+ (void)logCustomEvent:(NSString *)name
                 value:(NSInteger)value
                 level:(NSInteger)level
              details1:(NSString *)details1
              details2:(NSString *)details2
              details3:(NSString *)details3
     additionalDetails:(NSDictionary *)additionalDetails;


///
/// \details logCustomPlacement logs a custom placement.
///
/// @param
/// placementName The name of the custom placement that has occurred.
///
+ (void)logCustomPlacement:(NSString * )placementName;

///
/// \details preloadCustomPlacement Pre-load the content of a custom event.
///
/// @param
/// placementName The name of the placement to be custom loaded.
///
/// Note: Frequency capping will not be respected for placements that are custom loaded.
///
+ (void)preloadCustomPlacement:(NSString * )placementName;


@end
