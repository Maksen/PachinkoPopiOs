//
//  BFGGameScreenViewController.m
//  BFGUIKitExample
//
//  Created by Big Fish Games, Inc. on 7/1/11.
//  Copyright 2013 Big Fish Games, Inc.. All rights reserved.
//

#import "BFGGameScreenViewController.h"
#import <bfg_iOS_sdk/bfgRating.h>
#import <bfg_iOS_sdk/bfgManager.h>
#import "BFGUIKitExampleAppDelegate.h"
#import <bfg_iOS_sdk/bfgGameReporting.h>
#import <bfg_iOS_sdk/bfgAppManager.h>

@interface BFGGameScreenViewController() <UITextFieldDelegate>
{
    /*
     // These are for test purposes only.
     //
     */
    NSUInteger _paywallCount;
    NSUInteger _gamelevelCount;
    NSUInteger _minigameCount;
}

@property (weak, nonatomic) IBOutlet UITextField *wrappingIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *chapterTextField;
@property (weak, nonatomic) IBOutlet UITextField *pageTextField;

- (IBAction)significantEvent:(id)sender;
- (IBAction)showSupport:(id)sender;
- (IBAction)showPrivacy:(id)sender;
- (IBAction)showTermsOfUse:(id)sender;
- (IBAction)backToMainMenu:(id)sender;
- (IBAction)rateInGame:(id)sender;

//
// These are used to simulate Game Events.
//
- (IBAction)paywallShown:(id)sender;
- (IBAction)levelStart:(id)sender;
- (IBAction)levelFinished:(id)sender;
- (IBAction)minigameStart:(id)sender;
- (IBAction)minigameSkipped:(id)sender;
- (IBAction)minigameFinished:(id)sender;

@end


@implementation BFGGameScreenViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDetected:) name:BFG_NOTIFICATION_APP_DETECTED object:nil];
        _paywallCount = 0;
        _gamelevelCount = 0;
        _minigameCount = 0;
    }    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    self.wrappingIDTextField.delegate = self;
    self.chapterTextField.delegate = self;
    self.pageTextField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // dismiss keyboard
    [self.view endEditing:YES];
}

#pragma mark - Rating Methods

- (IBAction)significantEvent:(id)sender
{
	[bfgRating userDidSignificantEvent:TRUE];
	[self logRatingsTextWithAlertTitle: @"Significant Event Logged"];
}


- (IBAction)rateInGame:(id)sender
{
	[bfgRating immediateTrigger];
}


#pragma mark - Support Methods

- (IBAction)showSupport:(id)sender
{
    [bfgManager showSupport];
}


- (IBAction)showPrivacy:(id)sender
{
    [bfgManager showPrivacy];
}


-(IBAction)showTermsOfUse:(id)sender
{
    [bfgManager showTerms];
}


#pragma mark - Back Method

- (IBAction)backToMainMenu:(id)sender
{
    // Optional: Stop detecting Big Fish Games app installation when leaving game screen
    [bfgAppManager stopDetectingAppWithIdentifier:BFG_BIG_FISH_GAMES_BUNDLE_ID];
    
    [self.navigationController popViewControllerAnimated:NO];
}


// This bfgGameReporting should be triggered by game progress and not by a button.
- (IBAction)paywallShown:(id)sender
{
    NSString *paywallid = [NSString stringWithFormat:@"GamePayWall%d", _paywallCount];
    [bfgGameReporting logPurchasePayWallShown:paywallid];
    BFGUIKitExampleLog(@"%@", [NSString stringWithFormat:@"logPurchasePayWallShown: %@.", paywallid]);
    ++_paywallCount;
}


// This bfgGameReporting should be triggered by game progress and not by a button.
- (IBAction)levelStart:(id)sender
{
    if (_gamelevelCount > 5)
    {
        _gamelevelCount = 0;
        [bfgGameReporting logGameCompleted ];
        BFGUIKitExampleLog(@"%@", [NSString stringWithFormat:@"logGameCompleted."]);
        [bfgGameReporting logAchievementEarned: @"logAchievementEarned: GameCompleted."];
    }
    NSString *gamelevelid = [NSString stringWithFormat:@"GameLevel%d", _gamelevelCount];
    [bfgGameReporting logLevelStart:gamelevelid];
    BFGUIKitExampleLog(@"%@", [NSString stringWithFormat:@"logLevelStart: %@.", gamelevelid]);
}


// This bfgGameReporting should be triggered by game progress and not by a button.
- (IBAction)levelFinished:(id)sender
{
    if (_gamelevelCount <= 5)
    {
        NSString *gamelevelid = [NSString stringWithFormat:@"GameLevel%d", _gamelevelCount];
        [bfgGameReporting logLevelFinished: gamelevelid];
        BFGUIKitExampleLog(@"%@", [NSString stringWithFormat:@"logLevelFinished: %@.", gamelevelid]);
        ++_gamelevelCount;
    }
    else
    {
        _gamelevelCount = 0;
        [bfgGameReporting logGameCompleted];
        [bfgGameReporting logAchievementEarned: @"logAchievementEarned: GameCompleted."];
        BFGUIKitExampleLog(@"%@", [NSString stringWithFormat:@"logGameCompleted."] );
    }
}


// This bfgGameReporting should be triggered by game progress and not by a button.
- (IBAction)minigameStart:(id)sender
{
    if (_minigameCount > 5)
    {
        _minigameCount = 0;
    }
    NSString *minigameid = [NSString stringWithFormat:@"MiniGame%d", _minigameCount];
    [bfgGameReporting logMiniGameStart:minigameid];
    BFGUIKitExampleLog(@"%@", [NSString stringWithFormat:@"logMiniGameStart: %@.", minigameid]);
}


// This bfgGameReporting should be triggered by game progress and not by a button.
- (IBAction)minigameSkipped:(id)sender
{
    if (_minigameCount > 5)
    {
        _minigameCount = 0;
    }
    NSString *minigameid = [NSString stringWithFormat:@"MiniGame%d", _minigameCount];
    [bfgGameReporting logMiniGameSkipped:minigameid];
    BFGUIKitExampleLog(@"%@", [NSString stringWithFormat:@"logMiniGameSkipped: %@.", minigameid]);
    ++_minigameCount;
}

// This bfgGameReporting should be triggered by game progress and not by a button.
- (IBAction)minigameFinished:(id)sender
{
    NSString *minigameid = [NSString stringWithFormat:@"MiniGame%d", _minigameCount];
    [bfgGameReporting logMiniGameFinished:minigameid];
    BFGUIKitExampleLog(@"%@", [NSString stringWithFormat:@"logMiniGameFinished: %@.", minigameid]);
    ++_minigameCount;
    [bfgGameReporting logAchievementEarned:@"logAchievementEarned: MiniGameFinished."];
}


// This bfgGameReporting
- (IBAction)logCustomEvent:(id)sender
{
    [bfgGameReporting logCustomEvent:@"UIKItExampleCustomEvent" value:100 level:1 details1:@"customEventDetails1" details2:@"customEventDetails2" details3:@"customEventDetails3" additionalDetails:@{ @"where" : @"store", @"what" : @"a sword" }];
    BFGUIKitExampleLog( @"%@", [NSString stringWithFormat:@"logCustomEvent."] );
}

# pragma mark - Big Fish Games App Strategy Guide


// notifcation handler that app has been detected
- (void)appDetected:(NSNotification *)notification
{
    NSString *detectedAppIdentifier = notification.userInfo[BFG_BUNDLE_IDENTIFIER_KEY];
    
    if ([detectedAppIdentifier isEqualToString:BFG_BIG_FISH_GAMES_BUNDLE_ID])
    {
        NSLog(@"Big Fish Games installation detected!");
        // TODO: Highlight strategy guide button
    }
}

- (IBAction)strategyGuideTapped:(id)sender
{
    if (self.wrappingIDTextField.text.length > 0)
    {
        NSString *wrappingID = self.wrappingIDTextField.text;
        
        if (self.chapterTextField.text.length > 0 || self.pageTextField.text.length > 0)
        {
            NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            
            NSNumber *chapterNumber = [numberFormatter numberFromString:self.chapterTextField.text];
            NSNumber *pageNumber = [numberFormatter numberFromString:self.pageTextField.text];
            
            // Launch strategy guide with chapter and page
            [bfgAppManager launchBigFishGamesAppStrategyGuideWithWrappingID:wrappingID chapterIndex:[chapterNumber integerValue] pageIndex:[pageNumber integerValue]];
        }
        else
        {
            // Launch strategy guide
            [bfgAppManager launchBigFishGamesAppStrategyGuideWithWrappingID:wrappingID];
        }
    }
    else
    {
        // Launch Big Fish Games app
       // [bfgAppManager launchBigFishGamesApp];
    }
}

@end
