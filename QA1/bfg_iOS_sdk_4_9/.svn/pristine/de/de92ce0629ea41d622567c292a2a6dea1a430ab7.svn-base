//
//  BFGExampleViewController.m
//  BFGUIKitExample
//
//  Created by Big Fish Games, Inc. on 7/6/11.
//  Copyright 2013 Big Fish Games, Inc.. All rights reserved.
//

#import "BFGExampleViewController.h"
#import "BFGUIKitExampleAppDelegate.h"
#import <bfg_iOS_sdk/bfgutils.h>
#import <bfg_iOS_sdk/bfgsettings.h>
#import <bfg_iOS_sdk/bfgManager.h>
#import <bfg_iOS_sdk/bfgStrings.h>
#import <bfg_iOS_sdk/bfgRating.h>


@implementation BFGExampleViewController

#pragma mark - Properties

-(BFGUIKitExampleAppDelegate *) appDelegate { return (BFGUIKitExampleAppDelegate *)[UIApplication sharedApplication].delegate; }

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{

    // Support on landscape and portrait, not face-up, down or unknown
    return (UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation));

}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [bfgManager setParentViewController:self];
}


#pragma mark - Alert Methods

- (void) logRatingsTextWithAlertTitle: (NSString *) alertTitle
{
    NSString * message;

    [self displayAlertWithTitle: alertTitle message: message];
}

- (void) displayAlertWithTitle: (NSString *) title message: (NSString *) message
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: title message: message 
                                                    delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
    [alert show];
}

@end
