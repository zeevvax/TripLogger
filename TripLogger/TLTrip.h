//
//  TLTrip.h
//  TripLogger
//
//  Created by Zeev Vax on 10/23/14.
//  Copyright (c) 2014 Zeev Vax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLTrip : NSObject
@property (nonatomic, strong) NSString *startAddress;
@property (nonatomic, strong) NSString *endAddress;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@end
