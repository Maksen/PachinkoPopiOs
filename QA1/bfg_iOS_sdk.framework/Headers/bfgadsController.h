///
///  \file bfgadsController.h
///  \brief bfgAdsController header file.
///
//  \author Created by Sean Hummel on 6/1/10.
//  \author Updated by Craig Thompson on 10/17/13.
//  \copyright Copyright 2013 Big Fish Games. All rights reserved.
///

#import "bfglibPrefix.h"
#import "bfgadsConsts.h"

/// \brief bfgAdsController header file.

/// \details Class to create ad controller used in game. [bfgManager startAds/stopAds] is a more convenient way to accomplish this.

@interface bfgAdsController : NSObject

@property (nonatomic, readonly, strong)	UIView *                    adParent;
@property (assign)                      UIDeviceOrientation			orientation;
@property (nonatomic, strong)           NSArray *					allowedTypes;
@property (nonatomic, readonly, assign)	bfgadsOrigin				origin;
@property (nonatomic, assign)           BOOL                        areAdsRunning;

/**
 \details Initialize the ad controller.
 
 @param parent Parent view to add subview to.
 @param orientation UIDeviceOrientation to display ads.
 @param origin bfgadsOrigin to display ad {\ref BFGADS_ORIGIN_DEFAULT, \ref BFGADS_ORIGIN_TOP, \ref BFGADS_ORIGIN_BOTTOM}.
 */
- (id)initWithView:(UIView*)parent withOrientation:(UIDeviceOrientation)orientation withOrigin:(bfgadsOrigin)origin;

///
/// \details Starts the ad controller rotating and animating through ads.
///
/// Note: If started, you must call stop on adController before it is released.
///
- (void)start;

///
/// \details Stops the ad controller rotating and animating.
///
/// Should be called on object before released.
- (void)stop;

///
/// \details Moves to the next ad ahead of the schedule.
///
- (void)skip;

@end
