//
//  UnityWrapperUtilities.mm
//
//  Created by John Starin on 4/1/14.
//
//

#import <Foundation/Foundation.h>
#import "UnityWrapperUtilities.h"

// Notification definitions
#import <bfg_iOS_sdk/bfgPurchase.h>
#import <bfg_iOS_sdk/bfgPurchaseObject.h>
#import <bfg_iOS_sdk/bfgManager.h>
#import <bfg_iOS_sdk/bfgBrandingViewController.h>
#import <bfg_iOS_sdk/bfgGameReporting.h>
#import <bfg_iOS_sdk/bfgReporting.h>

static const NSString *kNotificationNameKey = @"BfgNotificationName";

@interface UnityWrapper : NSObject

@property (strong, nonatomic) NSMutableDictionary* notificationToHandlerMapping;

+ (id)sharedInstance;

@end

// TODO: make thread-safe
@implementation UnityWrapper

+ (id)sharedInstance
{
    static UnityWrapper *sharedUnityWrapper;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedUnityWrapper = [[self alloc] init];
    });
    
    return sharedUnityWrapper;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.notificationToHandlerMapping = [NSMutableDictionary dictionary];
    }
    
    return self;
}

+ (void)addNotification:(NSString *)notificationName unityObjectName:(NSString *)objectName unityMethodName:(NSString *)methodName
{
    [self.sharedInstance addNotification:notificationName forUnityObjectName:objectName withUnityMethodName:methodName];
}

- (void)addNotification:(NSString *)notificationName forUnityObjectName:(NSString *)objectName withUnityMethodName:(NSString *)methodName
{
//    NSLog(@"addNotification: %@, %@, %@", notificationName, objectName, methodName);
    
    if (!notificationName || !objectName || !methodName)
    {
        return;
    }
    
    if (![self.notificationToHandlerMapping objectForKeyedSubscript:notificationName])
    {
        // First entry for this notification
        self.notificationToHandlerMapping[notificationName] = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:notificationName object:nil];
    }
    
    self.notificationToHandlerMapping[notificationName][objectName] = methodName;
}

+ (void)removeNotification:(NSString *)notificationName unityObjectName:(NSString *)objectName
{
    [self.sharedInstance removeNotification:notificationName unityObjectName:objectName];
}

- (void)removeNotification:(NSString *)notificationName unityObjectName:(NSString *)objectName
{
    if (!notificationName || !objectName)
    {
        return;
    }
    
    NSMutableDictionary *objectToHandlerMapping = self.notificationToHandlerMapping[notificationName];
    [objectToHandlerMapping removeObjectForKey:objectName];
    
    if ([[objectToHandlerMapping[notificationName] allKeys] count] == 0)
    {
        [self.notificationToHandlerMapping removeObjectForKey:notificationName];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
    }
}

+ (void)removeAllNotificationsForUnityObjectName:(NSString *)objectName
{
    [self.sharedInstance removeAllNotificationsForUnityObjectName:objectName];
}

- (void)removeAllNotificationsForUnityObjectName:(NSString *)objectName
{
    if (!objectName)
    {
        return;
    }
    
    NSMutableArray *notificationNames = [[NSMutableArray alloc] init];
    for (NSString *notificationName in self.notificationToHandlerMapping.allKeys)
    {
        if (self.notificationToHandlerMapping[notificationName][objectName])
        {
            [notificationNames addObject:notificationName];
        }
    }
    
    for (NSString *notificationName in notificationNames)
    {
        [self removeNotification:notificationName unityObjectName:objectName];
    }
}

- (void)handleNotification:(NSNotification *)notification
{
    if (!notification || !notification.name)
    {
        return;
    }
    
    NSDictionary *objectNameToMethodNameMapping = [self.notificationToHandlerMapping objectForKey:notification.name];
    if (objectNameToMethodNameMapping)
    {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        
        // Add notification name to userInfo
        userInfo[kNotificationNameKey] = notification.name;
        
        // Add notification.userInfo data to userInfo
        if (notification.userInfo)
        {
            for (NSString *keyName in notification.userInfo)
            {
                if (![keyName isKindOfClass:[NSString class]])
                    continue;
                
                id object = notification.userInfo[keyName];
                
                if ([object isKindOfClass:[bfgPurchaseObject class]])
                {
                    NSDictionary *purchaseObjectDictionary = [[self class] dictionaryFromPurchaseObject:object];
                    userInfo[keyName] = purchaseObjectDictionary;
                }
                else if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSNull class]])
                {
                    userInfo[keyName] = object;
                }
                else if ([NSJSONSerialization isValidJSONObject:object])
                {
                    userInfo[keyName] = object;
                }
                else
                {
//                    NSLog(@"Unable to return userInfo[%@] for notification: %@", keyName, notification.name);
                }
            }
        }
        
        // Convert userInfo dictionary to JSON
        NSString *message = convertJSONObjectToString(userInfo);
        
        NSLog(@"Sending message to Unity: %@", message);
        
        // Send messages to registered objects
        for (NSString *unityObjectName in [objectNameToMethodNameMapping allKeys])
        {
            NSString *unityMethodName = [objectNameToMethodNameMapping objectForKey:unityObjectName];
            UnitySendMessage(unityObjectName.UTF8String, unityMethodName.UTF8String, message.UTF8String);
        }
    }
}

+ (NSDictionary *)dictionaryFromPurchaseObject:(bfgPurchaseObject *)purchaseObject
{
    // Remove purchaseStart (NSDate) and paymentTransaction (SKPaymentTransaction) since they aren't JSON objects
    
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    d[@"productInfo"] = purchaseObject.productInfo;
//    d[@"purchaseStart"] = purchaseObject.purchaseStart;
    d[@"canceled"] = [NSNumber numberWithBool:purchaseObject.canceled];
    d[@"restore"] = [NSNumber numberWithBool:purchaseObject.restore];
    d[@"sandbox"] = [NSNumber numberWithBool:purchaseObject.sandbox];
    d[@"success"] = [NSNumber numberWithBool:purchaseObject.success];
    d[@"quantity"] = [NSNumber numberWithInteger:purchaseObject.quantity];
//    d[@"paymentTransaction"] = purchaseObject.paymentTransaction;
    
    return d;
}

// test data (remove)
+ (NSDictionary *)fakeUserDictWithPurchaseObject
{
    bfgPurchaseObject *purchaseObject = [[bfgPurchaseObject alloc] init];
    purchaseObject.productInfo = @{ PRODUCT_INFO_PRODUCT_ID : @"com.bigfishgames.AwesomeSauce",
                                    PRODUCT_INFO_CURRENCY : @"usd",
                                    PRODUCT_INFO_PRICE : @(0.99),
                                    PRODUCT_INFO_PRICE_STR : @"$0.99",
                                    PRODUCT_INFO_DESCRIPTION : @"The best sauce!",
                                    PRODUCT_INFO_TITLE : @"Awesome Sauce™" };
    purchaseObject.purchaseStart = [NSDate date];
    purchaseObject.canceled = NO;
    purchaseObject.restore = NO;
    purchaseObject.sandbox = NO;
    purchaseObject.success = YES;
    purchaseObject.quantity = 1;
    purchaseObject.paymentTransaction = [SKPaymentTransaction new];
    
    return (@{ BFG_PURCHASE_OBJECT_USER_INFO_KEY : purchaseObject });
}

@end


extern "C"
{
    
#pragma mark - Public Unity Wrapper Utilities
    
    BOOL copyStringToBuffer(NSString *string, char* outputBuffer, int outputBufferSize)
    {
        if (string && outputBuffer && (outputBufferSize >= ([string length] + 1)))
        {
            strcpy(outputBuffer, [string UTF8String]);
            return YES;
        }
        
        return NO;
    }
    
    NSString* convertJSONObjectToString(NSObject *jsonObject)
    {
        NSString *jsonString;
        if ([NSJSONSerialization isValidJSONObject:jsonObject])
        {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:nil];
            jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        }
        
        return jsonString;
    }
    
    // Internal
    id convertJSONtoObject(const char* json)
    {
        if (!json)
        {
            return nil;
        }
        
        NSString *jsonString = [NSString stringWithUTF8String:json];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSObject *object = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        
        // Note: 'error' is being populated even when the conversion is successful; ignoring for now
        
        return object;
    }
    
    NSDictionary* convertJSONtoDictionary(const char* json)
    {
        NSDictionary *dictionary = convertJSONtoObject(json);
        
        // check class
        if (![dictionary isKindOfClass:[NSDictionary class]])
        {
            return nil;
        }
        
        return dictionary;
    }
    
    NSArray* convertJSONtoArray(const char* json)
    {
        NSArray* array = convertJSONtoObject(json);
        
        // check class
        if (![array isKindOfClass:[NSArray class]])
        {
            return nil;
        }
        
        return array;
    }
    
    
#pragma mark - External notification functions
    
    void __BfgUtilities__addNotificationObserver(const char *notificationName, const char* objectName, const char *methodName)
    {
        NSString *_notificationName = [NSString stringWithUTF8String:notificationName];
        NSString *_objectName = [NSString stringWithUTF8String:objectName];
        NSString *_methodName = [NSString stringWithUTF8String:methodName];
        
        [UnityWrapper addNotification:_notificationName unityObjectName:_objectName unityMethodName:_methodName];
    }
    
    void __BfgUtilities__removeNotificationObserverForObject(const char *notificationName, const char* objectName)
    {
        NSString *_notificationName = [NSString stringWithUTF8String:notificationName];
        NSString *_objectName = [NSString stringWithUTF8String:objectName];
        
        [UnityWrapper removeNotification:_notificationName unityObjectName:_objectName];
    }
    
    void __BfgUtilities__removeAllNotificationObserversForObject(const char *objectName)
    {
        NSString *_objectName = [NSString stringWithUTF8String:objectName];
        
        [UnityWrapper removeAllNotificationsForUnityObjectName:_objectName];
    }
    
    
#pragma mark - Test functions (remove)
    
    void triggerTestNotifications()
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        // Purchase notifications
        
        [nc postNotificationName:NOTIFICATION_FINISH_PURCHASE_COMPLETE object:nil userInfo:@{BFG_PRODUCT_ID_USER_INFO_KEY: @"com.bigfishgames.AwesomeSauce"}];
        [nc postNotificationName:NOTIFICATION_PURCHASE_FAILED object:nil userInfo:[UnityWrapper fakeUserDictWithPurchaseObject]];
        [nc postNotificationName:NOTIFICATION_PURCHASE_SUCCEEDED object:nil userInfo:[UnityWrapper fakeUserDictWithPurchaseObject]];
        [nc postNotificationName:NOTIFICATION_RESTORE_FAILED object:nil userInfo:nil];
        [nc postNotificationName:NOTIFICATION_RESTORE_SUCCEEDED object:nil userInfo:nil];
        [nc postNotificationName:NOTIFICATION_PURCHASE_PRODUCTINFORMATION object:nil userInfo:@{BFG_ACQUIRE_PRODUCT_INFO_FAILURES_USER_INFO_KEY: @[@"com.bigfishgames.superDarkManor",@"com.bigfishgames.golfBucksBlast",@"com.bigfishgames.sleepy"]}];
        
        // General notifications
        
        [nc postNotificationName:BFGPROMODASHBOARD_NOTIFICATION_COLDSTART object:nil];
        [nc postNotificationName:BFGPROMODASHBOARD_NOTIFICATION_WARMSTART object:nil];
        //[nc postNotificationName:BFGPROMODASHBOARD_NOTIFICATION_MOREGAMES_CLOSED object:nil];
        [nc postNotificationName:BFGPROMODASHBOARD_NOTIFICATION_WEBBROWSER_CLOSED object:nil];
        [nc postNotificationName:BFGPROMODASHBOARD_NOTIFICATION_MAINMENU object:nil];
        [nc postNotificationName:BFG_NOTIFICATION_STARTUP_SETTINGS_UPDATED object:nil];
        [nc postNotificationName:BFG_NOTIFICATION_TELLAFRIEND_MAILCOMPLETED object:nil];
        [nc postNotificationName:BFG_NOTIFICATION_UDID_UPDATED object:nil];
        [nc postNotificationName:BFGBRANDING_NOTIFICATION_COMPLETED object:nil];
        
        // Placement notifications
        
        [nc postNotificationName:BFG_NOTIFICATION_PLACEMENT_CONTENT_OPENED object:nil userInfo:@{BFG_PLACEMENT_CONTENT_NAME_KEY: @"myPlacement"}];
        [nc postNotificationName:BFG_NOTIFICATION_PLACEMENT_CONTENT_CLOSED object:nil userInfo:@{BFG_PLACEMENT_CONTENT_NAME_KEY: @"myPlacement", BFG_PLACEMENT_CONTENT_TRIGGER_KEY: @"placementTrigger"}];
        [nc postNotificationName:BFG_NOTIFICATION_PLACEMENT_CONTENT_ERROR object:nil userInfo:@{BFG_PLACEMENT_CONTENT_NAME_KEY: @"myPlacement"}];
        [nc postNotificationName:BFG_NOTIFICATION_PLACEMENT_CONTENT_UNLOCK_REWARD_OPENED object:nil userInfo:@{BFG_PLACEMENT_CONTENT_NAME_KEY: @"myPlacement", BFG_PLACEMENT_REWARD_NAME_KEY: @"myPlacementReward", BFG_PLACEMENT_REWARD_QUANTITY_KEY: @6, BFG_PLACEMENT_REWARD_RECEIPT_KEY: @"myPlacementReceipt"}];
        [nc postNotificationName:BFG_NOTIFICATION_PLACEMENT_CONTENT_UNLOCK_REWARD_CLOSED object:nil userInfo:@{BFG_PLACEMENT_CONTENT_NAME_KEY: @"myPlacement", BFG_PLACEMENT_REWARD_NAME_KEY: @"myPlacementReward", BFG_PLACEMENT_REWARD_QUANTITY_KEY: @6, BFG_PLACEMENT_REWARD_RECEIPT_KEY: @"myPlacementReceipt"}];
        [nc postNotificationName:BFG_NOTIFICATION_PLACEMENT_CONTENT_START_PURCHASE object:nil userInfo:@{BFG_PLACEMENT_PURCHASE_PRODUCTID_KEY: @"com.bigfishgames.productid", BFG_PLACEMENT_PURCHASE_ITEM_KEY: @"item Key", BFG_PLACEMENT_PURCHASE_QUANTITY_KEY: @1, BFG_PLACEMENT_PURCHASE_RECEIPT_KEY: @"This is my receipt!"}];
        
    }
    
}