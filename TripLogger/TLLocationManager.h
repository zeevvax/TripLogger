//
//  TLLocationManager.h
//  TripLogger
//
//  Created by Zeev Vax on 10/22/14.
//  Copyright (c) 2014 Zeev Vax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLTripLoggerViewController.h"

extern NSString *const TLLocationManagerUpadtedData;

@interface TLLocationManager : NSObject <TLTripLoggerViewControllerDataSource>
@end

