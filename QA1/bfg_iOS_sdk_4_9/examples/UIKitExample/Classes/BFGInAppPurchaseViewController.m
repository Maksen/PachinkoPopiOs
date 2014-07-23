//
//  BFGInAppPurchaseViewController.m
//  BFGUIKitExample
//
//  Created by Big Fish Games, Inc. on 6/29/11.
//  Copyright 2013 Big Fish Games, Inc.. All rights reserved.
//

#import "BFGInAppPurchaseViewController.h"
#import "BFGInAppPurchaseController.h"
#import "BFGUIKitExampleAppDelegate.h"
#import <bfg_iOS_sdk/bfgPurchase.h>
#import <bfg_iOS_sdk/bfgPurchaseObject.h>
#import <bfg_iOS_sdk/bfgGameReporting.h>
#import <bfg_iOS_sdk/bfgsettings.h>
#import <bfg_iOS_sdk/bfgutils.h>
#import "BFGUIKitExampleLog.h"


/** Private Methods */
@interface BFGInAppPurchaseViewController () <UIAlertViewDelegate>

typedef enum {
    IapSegmentedControlUnlocked,
    IapSegmentedControlLocked
} IapSegmentedControl;


// IBOutlets
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView    *activityIndicator;
@property (nonatomic, weak) IBOutlet UIButton                   *consumableButton;
@property (nonatomic, weak) IBOutlet UITextView                 *consumableInfoTextView;
@property (nonatomic, weak) IBOutlet UITextView                 *debugTextView;
@property (nonatomic, weak) IBOutlet UIView                     *modalMask;
@property (nonatomic, weak) IBOutlet UISegmentedControl         *purchaseSegmentedControl;
@property (nonatomic, weak) IBOutlet UIButton                   *restoreButton;
@property (nonatomic, weak) IBOutlet UILabel                    *storeInfoLabel;
@property (nonatomic, weak) IBOutlet UIButton                   *unlockButton;

// Private properties
@property (nonatomic, strong) NSString                          *activeProductId;
@property (nonatomic, strong) UIAlertView                       *beginPurchaseAlertView;
@property (nonatomic, strong) NSMutableArray                    *debugText;


// IBActions
- (IBAction)didPressBack:(id)sender;
- (IBAction)didPressClearPurchaseLock:(id)sender;
- (IBAction)didPressPurchaseConsumable:(id)sender;
- (IBAction)didPressRestorePurchases:(id)sender;
- (IBAction)didPressUnlockGame:(id)sender;


// "delegates"
- (void)didCompleteNewPurchase:(NSNotification *)notification;
- (void)didRedownloadPurchase:(NSNotification *)notification;
- (void)didRestorePurchase:(NSNotification *)notification;
- (void)purchaseDidFail:(NSNotification *)notification;
- (void)restoreDidFail:(NSNotification *)notification;
- (void)restoreDidSucceed:(NSNotification *)notification;


// Private instance methods
- (void)addDebugText:(NSString *)text;
- (void)adjustLayout;
- (void)adjustStoreState;
- (void)performPurchase:(NSString *)productId;
- (void)setSpinnerHidden:(BOOL)hidden;
- (void)updateDebugTextView;

@end


@implementation BFGInAppPurchaseViewController

NSInteger const kMaxDebugTextEntries = 100;


#pragma mark - Instance lifecycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - View lifecycle

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adjustLayout];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.debugText = [NSMutableArray arrayWithCapacity:kMaxDebugTextEntries];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setSpinnerHidden:YES];
    [self.purchaseSegmentedControl setSelectedSegmentIndex:([BFGInAppPurchaseController isPurchased:PRODUCT_ID_UNLOCK] ?
                                                            IapSegmentedControlUnlocked :
                                                            IapSegmentedControlLocked)];
    [self updateDebugTextView];
    [self adjustLayout];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustStoreState) name:EXAMPLE_NOTIFICATION_STORE_READY object:nil];
    [self adjustStoreState];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(purchaseDidFail:)
												 name:EXAMPLE_NOTIFICATION_PURCHASE_FAILED
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didCompleteNewPurchase:)
												 name:EXAMPLE_NOTIFICATION_NEW_PURCHASE
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didRedownloadPurchase:)
												 name:EXAMPLE_NOTIFICATION_REDOWNLOADED_PURCHASE
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didRestorePurchase:)
												 name:EXAMPLE_NOTIFICATION_RESTORED_PURCHASE
											   object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(restoreDidSucceed:)
												 name:EXAMPLE_NOTIFICATION_RESTORE_SUCCEEDED
											   object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(restoreDidFail:)
												 name:EXAMPLE_NOTIFICATION_RESTORE_FAILED
											   object:nil];
    
    [BFGInAppPurchaseController setShouldShowAlerts:NO];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EXAMPLE_NOTIFICATION_STORE_READY object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EXAMPLE_NOTIFICATION_NEW_PURCHASE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EXAMPLE_NOTIFICATION_PURCHASE_FAILED object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:EXAMPLE_NOTIFICATION_REDOWNLOADED_PURCHASE object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:EXAMPLE_NOTIFICATION_RESTORED_PURCHASE object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:EXAMPLE_NOTIFICATION_RESTORE_FAILED object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:EXAMPLE_NOTIFICATION_RESTORE_SUCCEEDED object:nil];
    [BFGInAppPurchaseController setShouldShowAlerts:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.debugText = nil;
}


#pragma mark - Helper methods

- (void)setSpinnerHidden:(BOOL)hidden
{
    [_modalMask setHidden:hidden];
    if (hidden)
    {
        [_activityIndicator stopAnimating];
    }
    else
    {
        [_activityIndicator startAnimating];
    }
    [_activityIndicator setHidden:hidden];
}


#pragma mark - IBActions

- (IBAction)didPressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}


- (IBAction)didPressClearPurchaseLock:(id)sender
{
	// This is not a normal mechanism -- there is no reason for relocking a game.    
    [self addDebugText:@"Cleared purchase unlock!"];
    [self.purchaseSegmentedControl setSelectedSegmentIndex:IapSegmentedControlLocked];
    [self adjustStoreState];
}


- (IBAction)didPressPurchaseConsumable:(id)sender
{
    [self performPurchase:PRODUCT_ID_CONSUMABLE];
}


- (IBAction)didPressRestorePurchases:(id)sender
{
    [self setSpinnerHidden:NO];
    [BFGInAppPurchaseController restoreProducts];
}


- (IBAction)didPressUnlockGame:(id)sender
{
    [self performPurchase:PRODUCT_ID_UNLOCK];
}


#pragma mark - In-App Purchase Notifications

- (void)didCompleteNewPurchase:(NSNotification *)notification
{
    [self setSpinnerHidden:YES];
    bfgPurchaseObject *purchaseObject = notification.userInfo[BFG_PURCHASE_OBJECT_USER_INFO_KEY];
    NSString *productName = purchaseObject.productInfo[PRODUCT_INFO_TITLE];
    NSString *priceString = purchaseObject.productInfo[PRODUCT_INFO_PRICE_STR];
    [self addDebugText:[NSString stringWithFormat:@"New purchase: %@", purchaseObject.productInfo]];
    NSString *message = nil;
    if (productName && priceString)
    {
        message = [NSString stringWithFormat:@"Please consider your %@ purchase of '%@' an investment in your future.", priceString, productName];
    }
    else
    {
        message = @"Thank you for your purchase!";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank You"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    if ([[purchaseObject productId] isEqualToString:PRODUCT_ID_UNLOCK])
    {
        [self.purchaseSegmentedControl setSelectedSegmentIndex:IapSegmentedControlUnlocked];
        [self adjustStoreState];
    }
}


- (void)didRedownloadPurchase:(NSNotification *)notification
{
    [self setSpinnerHidden:YES];
    bfgPurchaseObject *purchaseObject = notification.userInfo[BFG_PURCHASE_OBJECT_USER_INFO_KEY];
    NSString *productName = purchaseObject.productInfo[PRODUCT_INFO_TITLE];
    NSString *priceString = purchaseObject.productInfo[PRODUCT_INFO_PRICE_STR];
    [self addDebugText:[NSString stringWithFormat:@"Restored purchase: %@", purchaseObject.productInfo]];
    NSString *message = nil;
    if (productName && priceString)
    {
        message = [NSString stringWithFormat:@"We're glad your %@ purchase of '%@' was worth downloading again.", priceString, productName];
    }
    else
    {
        message = @"Thank you for re-downloading your purchase!";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank You"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    if ([[purchaseObject productId] isEqualToString:PRODUCT_ID_UNLOCK])
    {
        [self.purchaseSegmentedControl setSelectedSegmentIndex:IapSegmentedControlUnlocked];
        [self adjustStoreState];
    }
}


- (void)didRestorePurchase:(NSNotification *)notification
{
    bfgPurchaseObject *purchaseObject = notification.userInfo[BFG_PURCHASE_OBJECT_USER_INFO_KEY];
    NSString *name = purchaseObject.productInfo[PRODUCT_INFO_TITLE];
    if (name)
    {        
        [self addDebugText:[NSString stringWithFormat:@"Purchase restored: %@ (%@)", name, [purchaseObject productId]]];
    }
    else
    {
        // It's possible that after a restart we don't have the product name yet.
        [self addDebugText:[NSString stringWithFormat:@"Purchase restored: <name-not-acquired-yet> (%@)", [purchaseObject productId]]];
    }
    if ([[purchaseObject productId] isEqualToString:PRODUCT_ID_UNLOCK])
    {
        [self.purchaseSegmentedControl setSelectedSegmentIndex:IapSegmentedControlUnlocked];
        [self adjustStoreState];
    }
}


- (void)purchaseDidFail:(NSNotification *)notification
{
    [self setSpinnerHidden:YES];
    bfgPurchaseObject *purchaseObject = notification.userInfo[BFG_PURCHASE_OBJECT_USER_INFO_KEY];
    NSString *productName = purchaseObject.productInfo[PRODUCT_INFO_TITLE];

    if (purchaseObject.canceled)
    {
        [self addDebugText:[NSString stringWithFormat:@"Purchase of %@ was canceled.", productName]];
        return;
    }

    [self addDebugText:[NSString stringWithFormat:@"Purchase of %@ failed", productName]];
    
    UIAlertView *alert;
    NSString *message = nil;
    if (productName)
    {
        message = [NSString stringWithFormat:@"Unfortunately your purchase of '%@' failed.", productName];
    }
    else
    {
        message = @"Unfortanately your purchase failed.";
    }
    alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                       message:message
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    
    [alert show];
}

- (void)restoreDidFail:(NSNotification *)notification
{
    [self setSpinnerHidden:YES];
    [self addDebugText:@"Restore failed"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restore Failed"
                                                    message:@"Cannot restore at this time"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)restoreDidSucceed:(NSNotification *)notification
{    
    [self setSpinnerHidden:YES];
    NSNumber *failureCount = notification.userInfo[EXAMPLE_RESTORE_FAILURE_COUNT_USER_INFO_KEY];
    NSNumber *successCount = notification.userInfo[EXAMPLE_RESTORE_SUCCESS_COUNT_USER_INFO_KEY];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restore Succeeded"
                                                    message:[NSString stringWithFormat:@"Restore completed.\n%@ success(es)\n%@ failure(s)", successCount, failureCount]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    if ([BFGInAppPurchaseController isPurchased:PRODUCT_ID_UNLOCK])
    {
        [self.purchaseSegmentedControl setSelectedSegmentIndex:IapSegmentedControlUnlocked];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BFGUIKitExampleLog(@"%@", [NSString stringWithFormat:@"Alert View: called."] );
    if (alertView == self.beginPurchaseAlertView)
    {
        if (buttonIndex == alertView.cancelButtonIndex)
        {
            BFGUIKitExampleLog(@"User canceled purchase before it really started.");
        }
        else
        {
            BFGUIKitExampleLog(@"User would like to begin purchase.");
            [self setSpinnerHidden:NO];
            if ([self.activeProductId isEqualToString:PRODUCT_ID_UNLOCK])
            {
                [BFGInAppPurchaseController purchaseProduct:self.activeProductId];
            }
            else
            {
                [BFGInAppPurchaseController purchaseProduct:self.activeProductId
                                         details1:@"iapScreen"
                                         details2:@"fullPrice"
                                         details3:nil
                                   additionalInfo:@{ @"where" : @"store", @"what" : @"a sword" }];
            }
        }
    }
}


#pragma mark - Private instance methods

- (void)addDebugText:(NSString *)text
{
    if ([self.debugText count] == kMaxDebugTextEntries)
    {
        [self.debugText removeObjectAtIndex:0];
    }
    [self.debugText addObject:text];
    [self updateDebugTextView];
}


- (void)adjustLayout
{
    if (![bfgutils iPadMode])
    {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            self.consumableInfoTextView.frame = CGRectMake(150, 128, 181, 39);
        }
        else
        {
            self.consumableInfoTextView.frame = CGRectMake(119, 148, 181, 39);
        }
    }
}


- (void)adjustStoreState
{
    if ([BFGInAppPurchaseController readyForPurchasing])
    {
        self.storeInfoLabel.textColor = [UIColor darkTextColor];
        NSDictionary *unlockInfo = [bfgPurchase productInformation:PRODUCT_ID_UNLOCK];
        if (self.purchaseSegmentedControl.selectedSegmentIndex == IapSegmentedControlUnlocked)
        {
            self.storeInfoLabel.text = @"Game is unlocked!";
            self.unlockButton.hidden = YES;
        }
        else
        {
            self.storeInfoLabel.text = [NSString stringWithFormat:@"Unlock the game for only %@!", unlockInfo[PRODUCT_INFO_PRICE_STR]];
            self.unlockButton.hidden = NO;
        }
        NSDictionary *consumableInfo = [bfgPurchase productInformation:PRODUCT_ID_CONSUMABLE];
        self.consumableInfoTextView.text = [NSString stringWithFormat:@"%@ - %@\n\"%@\"", consumableInfo[PRODUCT_INFO_TITLE], consumableInfo[PRODUCT_INFO_PRICE_STR], consumableInfo[PRODUCT_INFO_DESCRIPTION]];
        self.consumableInfoTextView.hidden = NO;
        self.consumableButton.hidden = NO;
        self.restoreButton.hidden = NO;
    }
    else
    {
        self.storeInfoLabel.textColor = [UIColor grayColor];
        self.storeInfoLabel.text = @"Store Unavailable";
        self.consumableInfoTextView.hidden = YES;
        self.consumableButton.hidden = YES;
        self.restoreButton.hidden = YES;
        self.unlockButton.hidden = YES;
    }
}


- (void)performPurchase:(NSString *)productId
{
    UIAlertView *alert = nil;
    [self setSpinnerHidden:NO];
    BOOL canStartPurchase = [bfgPurchase canStartPurchase:productId];
    [self setSpinnerHidden:YES];
    if (canStartPurchase)
    {
        NSDictionary *productInfo = [bfgPurchase productInformation:productId];
        alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat: @"Purchase '%@'?",productInfo[PRODUCT_INFO_TITLE]]
                                           message:@"Your purchases help us keep making great games! Thanks!"
                                          delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 otherButtonTitles:@"Buy!", nil];
        self.activeProductId = productId;
        self.beginPurchaseAlertView = alert;
    }
    else
    {
        [self setSpinnerHidden:YES];
        alert = [[UIAlertView alloc] initWithTitle:@"beginPurchase" message:@"Begin purchase failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    [alert show];
}


- (void)updateDebugTextView
{
    NSString *displayText = [self.debugText componentsJoinedByString:@"\n"];
    [self.debugTextView setText:displayText];
    [self.debugTextView scrollRangeToVisible:NSMakeRange([displayText length], 0)];
}

@end
