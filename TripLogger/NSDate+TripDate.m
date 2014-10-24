//
//  NSDate+TripDate.m
//  TripLogger
//
//  Created by Zeev Vax on 10/23/14.
//  Copyright (c) 2014 Zeev Vax. All rights reserved.
//

#import "NSDate+TripDate.h"

static NSDateFormatter *tripDateFormater = nil;

@implementation NSDate(TripDate)

- (NSString *)tripTimeAsString
{
    if (!tripDateFormater)
    {
        tripDateFormater = [[NSDateFormatter alloc] init];
        tripDateFormater.dateFormat = @"hh:mma";
        [tripDateFormater setTimeZone:[NSTimeZone defaultTimeZone]];
    }

    return [tripDateFormater stringFromDate:self];
}
@end
