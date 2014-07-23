//
//  BFGInAppPurchaseController.m
//  BFGUIKitExample
//
//  Created by Benjamin Flynn on 5/1/13.
//  Copyright (c) 2013 Big Fish Games, Inc. All rights reserved.
//


#import "BFGInAppPurchaseController.h"

#import <bfg_iOS_sdk/bfgManager.h>
#import <bfg_iOS_sdk/bfgPurchase.h>
#import <bfg_iOS_sdk/bfgGameReporting.h>


typedef void (^IAPCallbackBlock)(bfgPurchaseObject *);


@interface BFGInAppPurchaseController()

@property (atomic, assign) BOOL                                  hasProductInfo;
@property (nonatomic, strong) NSMutableArray                    *purchaseCache;
@property (nonatomic, assign, getter = isRestoreActive) BOOL     restoreActive;
@property (nonatomic, assign) NSInteger                          restoreFailCount;
@property (nonatomic, assign) NSInteger                          restoreSuccessCount;
@property (nonatomic, assign, getter = isRunning) BOOL           running;
@property (nonatomic, assign) BOOL                               shouldShowAlerts;


+ (BFGInAppPurchaseController *)sharedInstance;

// Wrapped methods
- (BOOL)isPurchased:(NSString *)productId;
- (NSArray *)purchasesOfProduct:(NSString *)productId;
- (void)purchaseProduct:(NSString *)productId;
- (void)purchaseProduct:(NSString *)productId
               details1:(NSString *)details1
               details2:(NSString *)details2
               details3:(NSString *)details3
         additionalInfo:(NSDictionary *)additionalInfo;
- (void)restoreProducts;
- (void)startPurchaseService;

// "delegate" methods
- (void)acquireProductInfoDidSucceed:(NSNotification *)notification;
- (void)purchaseDidFail:(NSNotification *)notification;
- (void)purchaseDidSucceed:(NSNotification *)notification;
- (void)restoreDidFail:(NSNotification *)notification;
- (void)restoreDidSucceed:(NSNotification *)notification;

// private methods
- (void)acquireProductInfo;
- (void)persistPurchase:(bfgPurchaseObject *)purchaseObject
              onSuccess:(IAPCallbackBlock)successBlock
              onFailure:(IAPCallbackBlock)failureBlock;
- (BOOL)savePurchaseObject:(bfgPurchaseObject *)purchaseObject;

@end

@implementation BFGInAppPurchaseController


#pragma mark - Class methods

+ (BFGInAppPurchaseController *)sharedInstance
{
    static BFGInAppPurchaseController *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[BFGInAppPurchaseController alloc] init];
    });
    return _sharedInstance;
}


+ (BOOL)isPurchased:(NSString *)productId
{
    return [self.sharedInstance isPurchased:productId];
}


+ (BOOL)isRestoreActive
{
    return [self.sharedInstance isRestoreActive];
}


+ (NSArray *)purchasesOfProduct:(NSString *)productId
{
    return [self.sharedInstance purchasesOfProduct:productId];
}


+ (void)purchaseProduct:(NSString *)productId
{
    [self.sharedInstance purchaseProduct:productId];
}


+ (void)purchaseProduct:(NSString *)productId
               details1:(NSString *)details1
               details2:(NSString *)details2
               details3:(NSString *)details3
         additionalInfo:(NSDictionary *)additionalInfo
{
    [self.sharedInstance purchaseProduct:productId details1:details1 details2:details2 details3:details3 additionalInfo:additionalInfo];
}


+ (BOOL)readyForPurchasing
{
    return [self.sharedInstance hasProductInfo];
}


+ (void)restoreProducts
{
    [self.sharedInstance restoreProducts];
}


+ (void)setShouldShowAlerts:(BOOL)shouldShowAlerts
{
    [self.sharedInstance setShouldShowAlerts:shouldShowAlerts];
}


+ (BOOL)shouldShowAlerts
{
    return [self.sharedInstance shouldShowAlerts];
}


+ (void)startPurchaseService
{
    [self.sharedInstance startPurchaseService];
}


#pragma mark - Object lifecycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (id)init
{
    self = [super init];
    if (self)
    {
        self.purchaseCache = [NSMutableArray array];
        self.shouldShowAlerts = YES;
        
    }
    return self;
}


#pragma mark - Wrapped methods

- (BOOL)isPurchased:(NSString *)productId
{
    @synchronized (self.purchaseCache)
    {
        for (bfgPurchaseObject *purchaseObject in self.purchaseCache)
        {
            if ([purchaseObject.productId isEqualToString:productId])
            {
                return YES;
            }
        }
    }
    return NO;
}


- (NSArray *)purchasesOfProduct:(NSString *)productId
{
    NSMutableArray *purchases = [NSMutableArray array];
    @synchronized(self.purchaseCache)
    {
        for (bfgPurchaseObject *purchaseObject in self.purchaseCache)
        {
            if ([purchaseObject.productId isEqualToString:productId])
            {
                [purchases addObject:purchaseObject];
            }
        }
    }
    return [NSArray arrayWithArray:purchases];
}


- (void)purchaseProduct:(NSString *)productId
{
    [bfgPurchase startPurchase:productId];
}


- (void)purchaseProduct:(NSString *)productId
               details1:(NSString *)details1
               details2:(NSString *)details2
               details3:(NSString *)details3
         additionalInfo:(NSDictionary *)additionalInfo
{
    [bfgPurchase startPurchase:productId details1:details1 details2:details2 details3:details3 additionalDetails:additionalInfo];
}


- (void)restoreProducts
{
    self.restoreActive = YES;
    [bfgPurchase restorePurchases];
}


- (void)startPurchaseService
{
    if (self.isRunning)
    {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acquireProductInfoDidSucceed:) name:NOTIFICATION_PURCHASE_PRODUCTINFORMATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseDidFail:) name:NOTIFICATION_PURCHASE_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseDidSucceed:) name:NOTIFICATION_PURCHASE_SUCCEEDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreDidFail:) name:NOTIFICATION_RESTORE_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreDidSucceed:) name:NOTIFICATION_RESTORE_SUCCEEDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentStartPurchase:) name:BFG_NOTIFICATION_PLACEMENT_CONTENT_START_PURCHASE  object:nil];
    [bfgPurchase startService];
    [self acquireProductInfo];
    self.running = YES;
}


#pragma mark - "delegate" methods

// Handle purchases initiated by placment content
- (void)contentStartPurchase:(NSNotification *)notification
{
    NSDictionary * purchaseInfo = notification.userInfo;
    
    [self purchaseProduct:purchaseInfo[BFG_PLACEMENT_PURCHASE_PRODUCTID_KEY]];
}

- (void)acquireProductInfoDidSucceed:(NSNotification *)notification
{
    NSArray *failures = notification.userInfo[BFG_ACQUIRE_PRODUCT_INFO_FAILURES_USER_INFO_KEY];
    NSArray *successes = notification.userInfo[BFG_ACQUIRE_PRODUCT_INFO_SUCCESSES_USER_INFO_KEY];
    if ([failures count])
    {
        BFGUIKitExampleLog(@"Unexpected failures acquiring product info for the following products: %@\n \
                           -- Make sure these product IDs are valid and that the device can connect to Apple. __\n \
                           If you are using an iTunes Sandbox environment:\n \
                           1. Delete the app from the device and try again.\n \
                           2. Ensure you are not logged into the Store on the device and try again.\n \
                           3. Reboot the device and try again.\n \
                           4. Reset the device and try again.", failures);
        return;
    }
    if (!([successes containsObject:PRODUCT_ID_CONSUMABLE] && [successes containsObject:PRODUCT_ID_UNLOCK]))
    {
        BFGUIKitExampleLog(@"Unexpected lack of info, this should never happen, but the following products succeeded: %@", successes);
        return;
    }
    BFGUIKitExampleLog(@"Acquired product info for: %@", successes);
    self.hasProductInfo = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:EXAMPLE_NOTIFICATION_STORE_READY object:self];
}


- (void)purchaseDidFail:(NSNotification *)notification
{
    bfgPurchaseObject *purchaseObject = notification.userInfo[BFG_PURCHASE_OBJECT_USER_INFO_KEY];
    BFGUIKitExampleLog(@"Aw, rats! The purchase of %@ failed", purchaseObject.productId);
    if (self.restoreActive)
    {
        self.restoreFailCount++;
        return;
    }
    if (self.shouldShowAlerts && !purchaseObject.restore && !purchaseObject.canceled)
    {
        NSString *name = purchaseObject.productInfo[PRODUCT_INFO_TITLE];
        NSString *message = nil;
        if (name)
        {
            message = [NSString stringWithFormat:@"Unfortunately your purchase of %@ has failed.", name];
        }
        else
        {
            message = @"Unfortunately your purchase has failed";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase failed!"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EXAMPLE_NOTIFICATION_PURCHASE_FAILED object:self userInfo:notification.userInfo];
}


- (void)purchaseDidSucceed:(NSNotification *)notification
{
    bfgPurchaseObject *purchaseObject = notification.userInfo[BFG_PURCHASE_OBJECT_USER_INFO_KEY];
    
    __weak BFGInAppPurchaseController *weakSelf = self;
    __unsafe_unretained __block IAPCallbackBlock successBlock = ^(bfgPurchaseObject *purchaseObject)
    {
        BFGUIKitExampleBlockLog(@"Successfully saved the purchase!");        
        NSDictionary *userInfo = @{ BFG_PURCHASE_OBJECT_USER_INFO_KEY : purchaseObject };
        
        // If you will be asynchronously loading SKDownload content, you should wait to finish the purchase
        // until the download has completed and successfully been persisted.
        [bfgPurchase finishPurchase:[purchaseObject productId]];
        
        if (weakSelf.restoreActive)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:EXAMPLE_NOTIFICATION_RESTORED_PURCHASE object:weakSelf userInfo:userInfo];
            weakSelf.restoreSuccessCount++;
        }
        else
        {
            if (purchaseObject.restore)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:EXAMPLE_NOTIFICATION_REDOWNLOADED_PURCHASE object:weakSelf userInfo:userInfo];
                if (weakSelf.shouldShowAlerts)
                {
                    NSString *name = purchaseObject.productInfo[PRODUCT_INFO_TITLE];
                    NSString *message = nil;
                    if (name)
                    {
                        message = [NSString stringWithFormat:@"Your purchase of %@ has been restored.", name];
                    }
                    else
                    {
                        message = @"Your purchase has been restored.";
                    }
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you"
                                                                    message:message
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:EXAMPLE_NOTIFICATION_NEW_PURCHASE object:weakSelf userInfo:userInfo];
                if (weakSelf.shouldShowAlerts)
                {
                    NSString *name = purchaseObject.productInfo[PRODUCT_INFO_TITLE];
                    NSString *message = nil;
                    if (name)
                    {
                        message = [NSString stringWithFormat:@"Thank you for purchasing %@.", name];
                    }
                    else
                    {
                        message = @"Thank you for your purchase.";
                    }
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you"
                                                                    message:message
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
        }
    };
    
    __unsafe_unretained __block IAPCallbackBlock failureBlock = ^(bfgPurchaseObject *purchaseObject)
    {
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        BFGUIKitExampleBlockLog(@"Failed to save the purchase");
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf persistPurchase:purchaseObject onSuccess:successBlock onFailure:failureBlock];
        });
    };
    [self persistPurchase:purchaseObject onSuccess:successBlock onFailure:failureBlock];
}


- (void)restoreDidFail:(NSNotification *)notification
{
    BFGUIKitExampleLog(@"Sadly, restoring failed!");
    self.restoreActive = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:EXAMPLE_NOTIFICATION_RESTORE_FAILED object:self];
}


- (void)restoreDidSucceed:(NSNotification *)notification
{
    BFGUIKitExampleLog(@"All done restoring!");
    self.restoreActive = NO;
    NSDictionary *results = @{ EXAMPLE_RESTORE_SUCCESS_COUNT_USER_INFO_KEY : @(self.restoreSuccessCount),
                               EXAMPLE_RESTORE_FAILURE_COUNT_USER_INFO_KEY : @(self.restoreFailCount) };
    self.restoreFailCount = 0;
    self.restoreSuccessCount = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:EXAMPLE_NOTIFICATION_RESTORE_SUCCEEDED object:self userInfo:results];
}


#pragma mark - Private instance methods

- (void)acquireProductInfo
{
    BFGUIKitExampleLog(@"Acquiring product info");
    NSSet *allProductIds = [NSSet setWithArray:@[ PRODUCT_ID_CONSUMABLE, PRODUCT_ID_UNLOCK ]];
    [bfgPurchase acquireProductInformationForProducts:allProductIds];
}


- (void)persistPurchase:(bfgPurchaseObject *)purchaseObject
              onSuccess:(IAPCallbackBlock)successBlock
              onFailure:(IAPCallbackBlock)failureBlock
{
    if ([self savePurchaseObject:purchaseObject])
    {
        if (successBlock)
        {
            successBlock(purchaseObject);
        }
    }
    else
    {
        if (failureBlock)
        {
            failureBlock(purchaseObject);
        }
    }
}


- (BOOL)savePurchaseObject:(bfgPurchaseObject *)purchaseObject
{
    BOOL saveSucceeded;
    // ***************************************************
    // ***               VERY IMPORTANT!               ***
    // ***  THIS IS WHERE YOU SHOULD SAVE THE PURCHASE ***
    // ***************************************************
    BFGUIKitExampleLog(@"PERSIST YOUR PURCHASE HERE!");
    
    // This is where you could also perform an SKDownload, using the SKPaymentTransaction in the purchaseObject.
    
    // Not a real implementation!!!
    saveSucceeded = YES;
    @synchronized(self.purchaseCache)
    {
        [self.purchaseCache addObject:purchaseObject];
    }
    
    return saveSucceeded;
}


@end
