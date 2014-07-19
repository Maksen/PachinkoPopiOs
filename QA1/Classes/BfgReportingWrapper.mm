//
//  BfgReportingWrapper.mm
//  Unity-iPhone
//
//  Created by John Starin on 12/17/13.
//
//

#import <bfg_iOS_sdk/bfgReporting.h>
#import "UnityWrapperUtilities.h"

extern "C"
{
    // removed
//    void __bfgReporting__initialize()
//    {
//        [bfgReporting initialize];
//    }
    
    // removed
//    void __bfgReporting__beginLogSession()
//    {
//        [bfgReporting beginLogSession];
//    }
    
    // removed
//    void __bfgReporting__endLogSession()
//    {
//        [bfgReporting endLogSession];
//    }
    
    void __bfgReporting__logEvent(const char* eventName)
    {
        NSString *_evenName = [NSString stringWithUTF8String:eventName];
        [bfgReporting logEvent:_evenName];
    }
    
    // added
    void __bfgReporting__logEventWithParameters(const char* eventName, const char* parametersDictionary)
    {
        NSString *_eventName = [NSString stringWithUTF8String:eventName];
        NSDictionary *_parameters = convertJSONtoDictionary(parametersDictionary);
        [bfgReporting logEvent:_eventName withParameters:_parameters];
    }
    
    void __bfgReporting__logSingleFireEvent(const char* eventName)
    {
        NSString *_eventName = [NSString stringWithUTF8String:eventName];
        [bfgReporting logEvent:_eventName];
    }
    
    // not adding
    // + (void)logError:(NSString *)errorID message:(NSString *)message exception:(NSException *)exception;
    // + (void)logError:(NSString *)errorID message:(NSString *)message error:(NSError *)error;
    
    // removed
//    void __bfgReporting__logSessionDataSetValue(NSUInteger eventData, const char* value)
//    {
//        NSString *valueString = [NSString stringWithUTF8String:value];
//        [bfgReporting logSessionData:(BFG_LOG_DATA)eventData setValue:valueString];
//    }
}
