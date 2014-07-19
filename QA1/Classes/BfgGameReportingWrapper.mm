//
//  BfgGameReportingWrapper.mm
//  Unity-iPhone
//
//  Created by John Starin on 12/17/13.
//  Copyright 2013 Big Fish Games, Inc. All rights reserved.
//
//

#import <bfg_iOS_sdk/bfgGameReporting.h>

extern "C"
{
    void __bfgGameReporting__logMainMenuShown()
    {
        [bfgGameReporting logMainMenuShown];
    }
    
    void __bfgGameReporting__logRateMenuCanceled()
    {
        [bfgGameReporting logRateMainMenuCanceled];
    }
    
    void __bfgGameReporting__logOptionsShown()
    {
        [bfgGameReporting logOptionsShown];
    }
    
    void __bfgGameReporting__logPurchaseMainMenuShown()
    {
        [bfgGameReporting logPurchaseMainMenuShown];
    }
    
    void __bfgGameReporting__logPurchasePayWallShown(const char* paywallID)
    {
        NSString *paywall = [NSString stringWithUTF8String:paywallID];
        [bfgGameReporting logPurchasePayWallShown:paywall];
    }
    
    void __bfgGameReporting__logLevelStart(const char* levelID)
    {
        NSString *level = [NSString stringWithUTF8String:levelID];
        [bfgGameReporting logLevelStart:level];
    }
    
    void __bfgGameReporting__logLevelFinished(const char* levelID)
    {
        NSString *level = [NSString stringWithUTF8String:levelID];
        [bfgGameReporting logLevelFinished:level];
    }
    
    void __bfgGameReporting__logMiniGameStart(const char* miniGameID)
    {
        NSString *miniGame = [NSString stringWithUTF8String:miniGameID];
        [bfgGameReporting logMiniGameStart:miniGame];
    }
    
    void __bfgGameReporting__logMiniGameSkipped(const char* miniGameID)
    {
        NSString *miniGame = [NSString stringWithUTF8String:miniGameID];
        [bfgGameReporting logMiniGameSkipped:miniGame];
    }
    
    void __bfgGameReporting__logMiniGameFinished(const char* miniGameID)
    {
        NSString *miniGame = [NSString stringWithUTF8String:miniGameID];
        [bfgGameReporting logMiniGameFinished:miniGame];
    }
    
    void __bfgGameReporting__logAchievementEarned(const char* achievementID)
    {
        NSString *achievement = [NSString stringWithUTF8String:achievementID];
        [bfgGameReporting logAchievementEarned:achievement];
    }
    
    void __bfgGameReporting__logTellAFriendTapped()
    {
        [bfgGameReporting logTellAFriendTapped];
    }
    
//    void __bfgGameReporting__logIAPButtonTapped(NSUInteger purchaseButton)
//    {
//        BFG_PURCHASE_BUTTON button = (BFG_PURCHASE_BUTTON)purchaseButton;
//        [bfgGameReporting logIAPButtonTapped:button];
//    }
    
    void __bfgGameReporting__logGameCompleted()
    {
        [bfgGameReporting logGameCompleted];
    }
    
    // Add any custom events here
}