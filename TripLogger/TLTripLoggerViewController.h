//
//  TLTripLoggerViewController.h
//  TripLogger
//
//  Created by Zeev Vax on 10/23/14.
//  Copyright (c) 2014 Zeev Vax. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TLTrip;
@protocol TLTripLoggerViewControllerDataSource;

@interface TLTripLoggerViewController : UIViewController
@property (nonatomic, weak) id<TLTripLoggerViewControllerDataSource> dataSource;

@end

@protocol TLTripLoggerViewControllerDataSource <NSObject>
- (NSUInteger)tripLoggerViewControllerNumberOfTrips:(TLTripLoggerViewController*) tripLoggerVC;
- (TLTrip *)tripLoggerViewControllerTripInfo:(TLTripLoggerViewController*) tripLoggerVC index:(NSUInteger)index;
- (void)tripLoggerViewControllerStartCollectingData:(TLTripLoggerViewController*) tripLoggerVC;
- (void)tripLoggerViewControllerStopCollectingData:(TLTripLoggerViewController*) tripLoggerVC;
- (BOOL)tripLoggerViewControllerIsLogStatusOn:(TLTripLoggerViewController*) tripLoggerVC;
@end
