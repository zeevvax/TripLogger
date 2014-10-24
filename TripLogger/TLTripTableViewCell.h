//
//  TLTripTableViewCell.h
//  TripLogger
//
//  Created by Zeev Vax on 10/23/14.
//  Copyright (c) 2014 Zeev Vax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLTripTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *carImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *tripTimeLabel;
@end
