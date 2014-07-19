//
//  BfgManagerWrapper.mm
//  Unity-iPhone
//
//  Created by John Starin on 10/2/13.
//  Copyright 2013 Big Fish Games, Inc. All rights reserved.
//
//

#import <bfg_iOS_sdk/bfgManager.h>

extern "C"
{
    long _sessionCount()
    {
        return [bfgManager sessionCount];
    }
    
    BOOL _isInitialLaunch()
    {
        return [bfgManager isInitialLaunch];
    }
    
    BOOL _isFirstTime()
    {
        return [bfgManager isFirstTime];
    }
    
    BOOL _isInitialized()
    {
        return [bfgManager isInitialized];
    }
    
    void _showMoreGames()
    {
        [bfgManager showMoreGames];
    }
    
    void _removeMoreGames()
    {
        [bfgManager removeMoreGames];
    }
    
    void _showSupport()
    {
        [bfgManager showSupport];
    }
    
    void _showPrivacy()
    {
        [bfgManager showPrivacy];
    }
    
    void _showTerms()
    {
        [bfgManager showTerms];
    }
    
    void _showWebBrowser(const char* startPage)
    {
        NSString *url = [NSString stringWithUTF8String:startPage];
        [bfgManager showWebBrowser:url];
    }
    
    void _removeWebBrowser()
    {
        [bfgManager removeWebBrowser];
    }
    
    BOOL _checkForInternetConnection()
    {
        return [bfgManager checkForInternetConnection];
    }
    
    BOOL _checkForInternetConnectionAndAlert(BOOL displayAlert)
    {
        return [bfgManager checkForInternetConnectionAndAlert:displayAlert];
    }
    
    BOOL _startBranding()
    {
        return [bfgManager startBranding];
    }
    
    void _stopBranding()
    {
        [bfgManager stopBranding];
    }
    
    BOOL _adsRunning()
    {
        return [bfgManager adsRunning];
    }
    
    BOOL _startAds()
    {
        return [bfgManager startAds:BFGADS_ORIGIN_BOTTOM];
    }
    
    void _stopAds()
    {
        [bfgManager stopAds];
    }
}