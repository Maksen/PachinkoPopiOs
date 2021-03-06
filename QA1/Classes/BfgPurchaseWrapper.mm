//
//  BfgPurchaseWrapper.mm
//
//  Created by John Starin on 3/31/14.
//
//

#import <bfg_iOS_sdk/bfgPurchase.h>
#import "UnityWrapperUtilities.h"

extern "C"
{    
    BOOL __bfgPurchase__acquireProductInformation()
    {
        return [bfgPurchase acquireProductInformation];
    }
    
    BOOL __bfgPurchase__acquireProductInformation2(const char* productId)
    {
        NSString *_productId = [NSString stringWithUTF8String:productId];
        return [bfgPurchase acquireProductInformation:_productId];
    }
    
    // acquireProductInfotmationForProducts:(NSSet *)productIds
    BOOL __bfgPurchase__acquireProductInformationForProducts(const char* arrayOfProductIds)
    {
        NSArray *productIdArray = convertJSONtoArray(arrayOfProductIds);
        if (productIdArray)
        {
            return [bfgPurchase acquireProductInformationForProducts:[NSSet setWithArray:productIdArray]];
        }
        
        return NO;
    }
    
    BOOL __bfgPurchase__canStartPurchase()
    {
        return [bfgPurchase canStartPurchase];
    }
    
    BOOL __bfgPurchase__canStartPurchase2(const char* productId)
    {
        NSString *_productId = [NSString stringWithUTF8String:productId];
        return [bfgPurchase canStartPurchase:_productId];
    }
    
    void __bfgPurchase__finishPurchase()
    {
        [bfgPurchase finishPurchase];
    }
    
    void __bfgPurchase__finishPurchase2(const char *productId)
    {
        NSString *_productId = [NSString stringWithUTF8String:productId];
        [bfgPurchase finishPurchase:_productId];
    }
    
    BOOL __bfgPurchase__isPurchaseActive()
    {
        return [bfgPurchase isPurchaseActive];
    }
    
    BOOL __bfgPurchase__isPurchaseActive2(const char *productId)
    {
        NSString *_productId = [NSString stringWithUTF8String:productId];
        return [bfgPurchase isPurchaseActive:_productId];
    }
    
    BOOL __bfgPurchase__isRestoreActive()
    {
        return [bfgPurchase isRestoreActive];
    }
    
    // (NSDictionary *)productInformation
    void __bfgPurchase__productInformation(char* returnDictionary, int size)
    {
        NSDictionary *productInformation = [bfgPurchase productInformation];
        NSString *jsonString = convertJSONObjectToString(productInformation);
        copyStringToBuffer(jsonString, returnDictionary, size);
    }
    
    // (NSDictionary *)productInformation:(NSString *)productId
    void __bfgPurchase__productInformation2(const char* productId, char* returnDictionary, int size)
    {
        NSString *_productId = [NSString stringWithUTF8String:productId];
        NSDictionary *productInformation = [bfgPurchase productInformation:_productId];
        NSString *jsonString = convertJSONObjectToString(productInformation);
        copyStringToBuffer(jsonString, returnDictionary, size);
    }
    
    BOOL __bfgPurchase__purchaseActivityInProgress()
    {
        return [bfgPurchase purchaseActivityInProgress];
    }
    
    void __bfgPurchase__restorePurchases()
    {
        [bfgPurchase restorePurchases];
    }
    
    void __bfgPurchase__startPurchase()
    {
        [bfgPurchase startPurchase];
    }
    
    void __bfgPurchase__startPurchase2(const char* productId)
    {
        NSString *_productId = [NSString stringWithUTF8String:productId];
        [bfgPurchase startPurchase:_productId];
    }
    
    // startPurchase:(NSString *)productId details1:(NSString *)details1 details2:(NSString *)details2 details3:(NSString *)details3 additionalDetails:(NSDictinoary *)addtionalDetails
    void __bfgPurchase__startPurchase3(const char* productId, const char *details1, const char* details2, const char* details3, const char* additionalDetails)
    {
        NSLog(@"called startPurchase3");
        NSString *_productId = [NSString stringWithUTF8String:productId];
        
        NSString *_details1 = (details1) ? [NSString stringWithUTF8String:details1] : nil;
        NSString *_details2 = (details2) ? [NSString stringWithUTF8String:details2] : nil;
        NSString *_details3 = (details3) ? [NSString stringWithUTF8String:details3] : nil;
        
        NSLog(@"additionalDetails: %s", additionalDetails);
        NSDictionary *_additionalDetails = convertJSONtoDictionary(additionalDetails);
        
        NSLog(@"details1: %@\ndetails2: %@\ndetails3: %@\nadditionalDetails: %@", _details1, _details2, _details3, _additionalDetails);
        
        [bfgPurchase startPurchase:_productId details1:_details1 details2:_details2 details3:_details3 additionalDetails:_additionalDetails];
    }
    
    BOOL __bfgPurchase__startService()
    {
        return [bfgPurchase startService];
    }
    
    BOOL __bfgPurchase__startService2(char* errorString, int size)
    {
        NSError *error;
        BOOL success = [bfgPurchase startService:&error];
        memcpy(errorString, error.localizedDescription.UTF8String, size);
        return success;
    }
    
    //NSDictinoary _
}
