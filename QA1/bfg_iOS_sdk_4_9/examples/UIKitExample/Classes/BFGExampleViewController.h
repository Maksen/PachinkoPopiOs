//
//  BFGExampleViewController.h
//  BFGUIKitExample
//
//  Created by Big Fish Games, Inc. on 7/6/11.
//  Copyright 2013 Big Fish Games, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BFGUIKitExampleAppDelegate;


/**
 * Common superclass for all example view controllers
 * @author bigfishgames.com
 */
@interface BFGExampleViewController : UIViewController

#pragma mark - Properties

@property (nonatomic, readonly) BFGUIKitExampleAppDelegate * appDelegate;


#pragma mark - Alert Methods

/** 
 * Logs the ratings text to the console and displays an alert 
 * @param alertTitle the alert title
 */
- (void) logRatingsTextWithAlertTitle: (NSString *) alertTitle;

/**
 * Convenience method to display an alert with the title and message provided
 * @param title the alert title
 * @param message the alert message
 */
- (void) displayAlertWithTitle: (NSString *) title message: (NSString *) message;

@end
