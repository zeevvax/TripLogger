//
//  TLLocationManager.m
//  TripLogger
//
//  Created by Zeev Vax on 10/22/14.
//  Copyright (c) 2014 Zeev Vax. All rights reserved.
//

#import "TLLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "TLTrip.h"


#define MPS_TO_MPH 2.23694f
#define STOP_TIME 60.0f

typedef enum : NSUInteger {
    TLLocationManagerStatusDriving,
    TLLocationManagerStatusStop
} TLLocationManagerStatus;

@interface TLLocationManager() <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, assign) TLLocationManagerStatus status;
@property (nonatomic, strong) NSTimer *stopTimer;
@property (nonatomic, strong) NSMutableArray *trips;
@property (nonatomic, strong) CLGeocoder *tripGeoCoder;
@property (nonatomic, assign) BOOL isCollectingLocation;
@end

@implementation TLLocationManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setupLocationManger];
        _status = TLLocationManagerStatusStop;
        _trips = [NSMutableArray new];
        _tripGeoCoder = [[CLGeocoder alloc] init];

    }
    return self;
}

- (void)setupLocationManger
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)startUpdatingLocation
{
    [self.locationManager startUpdatingLocation];
    self.isCollectingLocation = YES;
}

- (void)stopUpdatingLocation
{
    [self.locationManager stopUpdatingLocation];
    self.isCollectingLocation = NO;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
//    NSLog(@"didUpdateLocations");
    CLLocation *currentLocation = [locations lastObject];
    if (!self.lastLocation)
        self.lastLocation = currentLocation;
    [self updateStatusWithCurrentLocation:currentLocation];
    self.lastLocation = currentLocation;
}

#pragma mark - trip location helpers
- (void)updateStatusWithCurrentLocation:(CLLocation *) currentLocation
{
//     NSLog(@"updateStatusWithCurrentLocation currentLocation %@ time %@", currentLocation, [NSDate date]);
    if (self.status == TLLocationManagerStatusStop && [self isDrivingWithCurrentLocation:currentLocation])
    {
        self.status = TLLocationManagerStatusDriving;
        [self addNewTrip];
    }
    else if (self.status == TLLocationManagerStatusDriving && [self didMoveWithCurrentLoacation:currentLocation])
    {
        [self updateStopTimer];

    }
}

- (void)updateStopTimer
{
//    NSLog(@"updateStopTimer time %@", [NSDate date]);
    if (self.stopTimer)
    {
        [self.stopTimer invalidate];
        self.stopTimer = nil;
    }
    self.stopTimer = [NSTimer scheduledTimerWithTimeInterval:STOP_TIME
                                                      target:self
                                                    selector:@selector(changeStatusToStop)
                                                    userInfo:nil
                                                     repeats:NO];
}


- (void)changeStatusToStop
{
    NSLog(@"changeStatusToStop");
    self.stopTimer = nil;
    self.status = TLLocationManagerStatusStop;
    [self endTrip];
}

-(BOOL)isDrivingWithCurrentLocation:(CLLocation *) currentLocation
{
    CLLocationSpeed speed = [currentLocation speed] * MPS_TO_MPH;
    return speed >= 10?YES:NO;
    
}

- (BOOL)didMoveWithCurrentLoacation:(CLLocation *) currentLocation
{
    return [self.lastLocation distanceFromLocation:currentLocation] > 0;
}

#pragma mark - trip data update

- (void)addNewTrip
{
    NSLog(@"sendStartDriving %@", self.lastLocation);
    TLTrip *newTrip = [TLTrip new];
    newTrip.startTime = self.lastLocation.timestamp;
    [self.trips addObject:newTrip];
    [self addStreetAddressToTrip:newTrip toStartAdderss:YES location:self.lastLocation];
}

- (void)endTrip
{
    NSLog(@"sendStoppedDriving %@", self.lastLocation);
    TLTrip *lastTrip = [self.trips lastObject];
    lastTrip.endTime = self.lastLocation.timestamp;
    [self addStreetAddressToTrip:lastTrip toStartAdderss:NO location:self.lastLocation];
}

- (void)addStreetAddressToTrip:(TLTrip *) trip toStartAdderss:(BOOL) startAddress location:(CLLocation *) location
{

    [self.tripGeoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        NSLog(@"Found placemarks error: %@", error);
        NSString *address = @"No address found";
        if (error == nil && [placemarks count] > 0)
        {
            CLPlacemark *placemark = [placemarks lastObject];
            if (placemark.thoroughfare)
                address = [NSString stringWithFormat:@"%@ %@",
                                 placemark.subThoroughfare?placemark.subThoroughfare:@"", placemark.thoroughfare];
            
        }
        if (startAddress)
            trip.startAddress = address;
        else
            trip.endAddress = address;
        [[NSNotificationCenter defaultCenter] postNotificationName:TLLocationManagerUpadtedData object:nil];
    }];
}

#pragma mark - TLTripLoggerViewControllerDataSource
- (NSUInteger)tripLoggerViewControllerNumberOfTrips:(TLTripLoggerViewController*) tripLoggerVC
{
    return self.trips.count;
}

- (TLTrip *)tripLoggerViewControllerTripInfo:(TLTripLoggerViewController*) tripLoggerVC index:(NSUInteger)index
{
    NSAssert(index >= 0 && index < self.trips.count , @"Index must be in range of the trips array");
    return self.trips[index];
}

- (void)tripLoggerViewControllerStartCollectingData:(TLTripLoggerViewController*) tripLoggerVC
{
    [self startUpdatingLocation];
}

- (void)tripLoggerViewControllerStopCollectingData:(TLTripLoggerViewController*) tripLoggerVC
{
    [self stopUpdatingLocation];
}

- (BOOL)tripLoggerViewControllerIsLogStatusOn:(TLTripLoggerViewController *)tripLoggerVC
{
    return self.isCollectingLocation;
}


@end

NSString *const TLLocationManagerUpadtedData = @"TLLocationManagerUpadtedData";

