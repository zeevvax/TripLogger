//
//  TLTripLoggerViewController.m
//  TripLogger
//
//  Created by Zeev Vax on 10/23/14.
//  Copyright (c) 2014 Zeev Vax. All rights reserved.
//

#import "TLTripLoggerViewController.h"
#import "TLLocationManager.h"
#import "TLTripTableViewCell.h"
#import "TLTrip.h"
#import "NSDate+TripDate.h"
#import "UIView+Borders.h"

static NSString *const TripTableViewCellID = @"TripTableViewCell";

@interface TLTripLoggerViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) TLLocationManager *locationManager;

@end

@implementation TLTripLoggerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTripDataSource];
    [self setupNavigationBar];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(oriantationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}


- (void)setupNavigationBar
{
    UIImage *image = [UIImage imageNamed:@"navbar"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [self.navigationController.navigationBar addSubview:imageView];

}

- (void)setupTripDataSource
{
    self.locationManager = [TLLocationManager new];
    self.dataSource = self.locationManager;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logDataUpdate:)
                                                 name: TLLocationManagerUpadtedData
                                               object:nil];
}

- (void)oriantationDidChange:(NSNotification *)n
{
    [self.tableView reloadData];
    [self setupNavigationBar];
}

- (void)logDataUpdate:(NSNotification*)n
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource tripLoggerViewControllerNumberOfTrips:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLTrip *tripInfo = [self.dataSource tripLoggerViewControllerTripInfo:self index:indexPath.row];
    TLTripTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TripTableViewCellID];
    cell.carImageView.image = [UIImage imageNamed:@"icon_car"];
    NSString *endAddress = tripInfo.endAddress?[NSString stringWithFormat:@" > %@",tripInfo.endAddress]:@"";
    cell.addressLabel.text = [NSString stringWithFormat:@"%@%@", tripInfo.startAddress, endAddress];
    if (tripInfo.endTime)
    {
        NSInteger tripLengthInSeconds = (NSInteger)[tripInfo.endTime timeIntervalSinceDate:tripInfo.startTime];
        cell.tripTimeLabel.text = [NSString stringWithFormat:@"%@-%@ (%dmin)",[tripInfo.startTime tripTimeAsString],
                                   [tripInfo.endTime tripTimeAsString], (int)(1 + tripLengthInSeconds/60)];
    }
    else
        cell.tripTimeLabel.text = [tripInfo.startTime tripTimeAsString];
    [cell.contentView addBottomBorderWithHeight:1.0 andColor:[UIColor lightGrayColor]];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 60.0)];
    [headerView addTopBorderWithHeight:1.0 andColor:[UIColor lightGrayColor]];
    [headerView addBottomBorderWithHeight:1.0 andColor:[UIColor lightGrayColor]];
    
    UILabel *tripLoginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 20.0)];
    tripLoginLabel.text = @"Trip Logging";
    tripLoginLabel.font = [UIFont systemFontOfSize:16.0];
    [headerView addSubview:tripLoginLabel];
    UISwitch *logSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [headerView addSubview:logSwitch];
    [logSwitch addTarget:self action:@selector(setLogState:) forControlEvents:UIControlEventValueChanged];
    [logSwitch setOn:[self.dataSource tripLoggerViewControllerIsLogStatusOn:self]];
    [logSwitch setOnTintColor:
     [UIColor colorWithRed:24.0/255.0 green:164.0/255.0 blue:170.0/255.0 alpha:1.0]];
    
    NSDictionary *viewsDictionary = @{@"nameLabel": tripLoginLabel, @"logSwitch":logSwitch};
    tripLoginLabel.translatesAutoresizingMaskIntoConstraints = NO;
    logSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *nameLabelConstraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[nameLabel(20)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    NSArray *nameLabelConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[nameLabel(120)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    [headerView addConstraints:nameLabelConstraint_H];
    [headerView addConstraints:nameLabelConstraint_V];
    
    NSLayoutConstraint *logSwitchCenterY = [NSLayoutConstraint
                                                    constraintWithItem:logSwitch
                                                    attribute:NSLayoutAttributeCenterY
                                                    relatedBy:NSLayoutRelationEqual
                                                    toItem:headerView
                                                    attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                    constant:0.f];
    
    NSArray *logSwitchConstraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[logSwitch]-20-|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:viewsDictionary];
    [headerView addConstraint:logSwitchCenterY];
    [headerView addConstraints:logSwitchConstraint_H];
    
    
    return headerView;
}

#pragma mark - action

- (void)setLogState:(id)sender
{
    if ([sender isOn])
        [self.dataSource tripLoggerViewControllerStartCollectingData:self];
    else
        [self.dataSource tripLoggerViewControllerStopCollectingData:self];

}



@end
