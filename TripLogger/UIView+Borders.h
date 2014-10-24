//
//  UIView+Borders.h
//
//  Created by Zeev Vax on 10/23/14.
//  Copyright (c) 2014 Zeev Vax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Borders)

-(void)addTopBorderWithHeight:(CGFloat)height andColor:(UIColor*)color;
-(void)addBottomBorderWithHeight:(CGFloat)height andColor:(UIColor*)color;

@end
