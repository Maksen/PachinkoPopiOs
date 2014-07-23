//
//  BFGUIKitExampleAppDelegate.h
//  BFGUIKitExample
//
//  Created by Big Fish Games, Inc. on 6/29/11.
//  Copyright 2013 Big Fish Games, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

// For reference
#define IAP_VERIFY_CLIENT_ONLY          @"a3f515d2563f51f750f1f1168faa8a488f566604"
#define IAP_VERIFY_SERVER_ONLY          @"3806030c8bc7fc6ad4aa4638e693ff322d241e10"
#define IAP_VERIFY_CLIENT_AND_SERVER    @"f28f6a8a1e4508a45e277b91c12b9ecb9d5df77b"


@class BFGUIKitExampleViewController;
@class bfgBrandingViewController;
@class BFGMainMenuViewController;
@class BFGGameScreenViewController;
@class BFGInAppPurchaseViewController;
@class BFGBonusContentViewController;

/**
 * Unified UIKit Example Application delegate
 * @author bigfishgames.com
 */
@interface BFGUIKitExampleAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet BFGUIKitExampleViewController *viewController;
@property (nonatomic, strong) UIViewController *activeViewController;  // Used only when root view controller is not supported

/**
 * Returns the nib name for the view controller given orientation and device type.
 * @param baseName the base part of the nib name
 */
+ (NSString *)nibNameWithBaseName:(NSString *)baseName;

@end
