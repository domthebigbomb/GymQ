//
//  AnalyticsViewController.h
//  GymQ
//
//  Created by Dominic Ong on 7/18/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface AnalyticsViewController : UIViewController<CPTScatterPlotDataSource,CPTScatterPlotDelegate>

@property (strong, nonatomic) NSString *workoutName;
@property (strong, nonatomic) NSArray *workoutData;


@end
