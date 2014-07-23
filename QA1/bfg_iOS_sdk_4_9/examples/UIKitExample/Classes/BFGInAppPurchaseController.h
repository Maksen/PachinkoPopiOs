//
//  BFGInAppPurchaseController.h
//  BFGUIKitExample
//
//  Created by Benjamin Flynn on 5/1/13.
//  Copyright (c) 2013 Big Fish Games, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFGInAppPurchaseController : NSObject

#define EXAMPLE_NOTIFICATION_NEW_PURCHASE           @"EXAMPLE_NOTIFICATION_NEW_PURCHASE"
#define EXAMPLE_NOTIFICATION_PURCHASE_FAILED        @"EXAMPLE_NOTIFICATION_PURCHASE_FAILED"
#define EXAMPLE_NOTIFICATION_REDOWNLOADED_PURCHASE  @"EXAMPLE_NOTIFICATION_REDOWNLOADED_PURCHASE"
#define EXAMPLE_NOTIFICATION_RESTORED_PURCHASE     @"EXAMPLE_NOTIFICATION_RESTORED_PURCHASE"
#define EXAMPLE_NOTIFICATION_RESTORE_FAILED         @"EXAMPLE_NOTIFICATION_RESTORE_FAILED"
#define EXAMPLE_NOTIFICATION_RESTORE_SUCCEEDED      @"EXAMPLE_NOTIFICATION_RESTORE_SUCCEEDED"
#define EXAMPLE_NOTIFICATION_STORE_READY            @"EXAMPLE_NOTIFICATION_STORE_READY"

#define EXAMPLE_RESTORE_SUCCESS_COUNT_USER_INFO_KEY @"EXAMPLE_RESTORE_SUCCESS_COUNT_USER_INFO_KEY"
#define EXAMPLE_RESTORE_FAILURE_COUNT_USER_INFO_KEY @"EXAMPLE_RESTORE_FAILURE_COUNT_USER_INFO_KEY"

#define PRODUCT_ID(NAME)                            [NSString stringWithFormat:@"%@.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"], NAME]
#define PRODUCT_ID_CONSUMABLE                       PRODUCT_ID(@"consumeme")
#define PRODUCT_ID_UNLOCK                           PRODUCT_ID(@"seunlock")


+ (BOOL)isPurchased:(NSString *)productId;

+ (BOOL)isRestoreActive;

+ (NSArray *)purchasesOfProduct:(NSString *)productId;

+ (void)purchaseProduct:(NSString *)productId;

+ (void)purchaseProduct:(NSString *)productId
               details1:(NSString *)details1
               details2:(NSString *)details2
               details3:(NSString *)details3
         additionalInfo:(NSDictionary *)additionalInfo;

+ (BOOL)readyForPurchasing;

+ (void)restoreProducts;

+ (void)setShouldShowAlerts:(BOOL)shouldShowAlerts;

+ (BOOL)shouldShowAlerts;

+ (void)startPurchaseService;

@end
