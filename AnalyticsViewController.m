//
//  AnalyticsViewController.m
//  GymQ
//
//  Created by Dominic Ong on 7/18/14.
//  Copyright (c) 2014 GymQ. All rights reserved.
//

#import "AnalyticsViewController.h"

@interface AnalyticsViewController ()
@property (strong,nonatomic) IBOutlet CPTGraphHostingView *hostView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *graphSegementedControl;
@end

@implementation AnalyticsViewController{
    NSInteger numWeeks;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_graphSegementedControl addTarget:self action:@selector(switchGraphs:) forControlEvents:UIControlEventValueChanged];
    numWeeks = 5;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self initPlot];
}

-(void)switchGraphs:(id)sender{
    NSString *identifier;
    if([[_graphSegementedControl titleForSegmentAtIndex:[_graphSegementedControl selectedSegmentIndex]]isEqualToString:@"Recent"]){
        identifier = @"Recent";
    }else if([[_graphSegementedControl titleForSegmentAtIndex:[_graphSegementedControl selectedSegmentIndex]]isEqualToString:@"Past 5"]){
        identifier = @"Week";
    }else{
        // Display all data
        identifier = @"Overall";
    }
    [self performSelector:@selector(switchGraphWithIdentifier:) withObject:identifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initPlot{
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)switchGraphWithIdentifier:(NSString *)identifier{
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    NSArray *plots = [graph allPlots];
    CPTScatterPlot *currentPlot;
    for(CPTScatterPlot *plot in plots){
        if([plot.identifier isEqual:identifier]){
            currentPlot = plot;
            [plot setHidden:NO];
        }else{
            [plot setHidden:YES];
        }
    }
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:currentPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    double partialLength = 0.05 * CPTDecimalDoubleValue(yRange.length);
    
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.6f)];
    double firstWeight;
    if([identifier isEqualToString:@"Recent"]){
        firstWeight = [[[_workoutData objectAtIndex:[_workoutData count] - 5]objectForKey:@"weight"] doubleValue];
    }else if([identifier isEqualToString:@"Week"]){
        // Insert code to calculate past 5 week data
        
        NSTimeInterval pastWeeks = 60 * 60 * 24 * 7 * numWeeks;
        NSInteger indexOfOldestWorkout = 0;
        for(int i = 0; i< [_workoutData count]; i++){
            NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:[[_workoutData objectAtIndex:i] objectForKey:@"timestamp"]];
            if(diff > pastWeeks){
                // Located index of workout thats too old
                indexOfOldestWorkout = i - 1;
                break;
            }
        }
        if(indexOfOldestWorkout == -1){
            indexOfOldestWorkout++;
        }
        firstWeight = [[[_workoutData objectAtIndex:indexOfOldestWorkout]objectForKey:@"weight"] doubleValue];
    }else{
        // Overall
        firstWeight = [[[_workoutData firstObject]objectForKey:@"weight"] doubleValue];
    }
        // Calculate first weight
    yRange = [CPTMutablePlotRange plotRangeWithLocation:CPTDecimalFromString([NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:firstWeight - 2.5]]) length: yRange.length];
    plotSpace.yRange = yRange;
    
    // Redo axis on graph switch
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTXYAxis *x = axisSet.xAxis;

    x.orthogonalCoordinateDecimal = CPTDecimalFromString([NSString stringWithFormat:@"%@",[NSNumber numberWithDouble: firstWeight - 2.5]]);
    x.title = @"Sessions Past";
    x.titleOffset = 15.0f;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat dateCount = [_workoutData count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    
    for (NSDictionary *workout in _workoutData) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt:5-i]] textStyle:x.labelTextStyle];
        CGFloat location = i;
        
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
        i++;
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    
    
    // 4 - Configure y-axis
    CPTXYAxis *y = axisSet.yAxis;
    //y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"130");
    NSString *yTitle = [NSString stringWithFormat:@"Weight (%@)",[[_workoutData lastObject] objectForKey:@"units"]];
    y.title = yTitle;
    y.titleOffset = -40.0f;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelOffset = 20.0f;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 10;
    double minorIncrement = 2.5;
    CGFloat yMax = 500.0f;  // should determine dynamically based on max price
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li", (long)j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;

}

-(void)configureHost {
    // self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    //self.hostView.allowPinchScaling = YES;
    // _hostView.backgroundColor = [UIColor clearColor];
    // [self.view addSubview:self.hostView];
}

-(void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    //[graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;
    // 2 - Set graph title
    NSString *title = @"Workout Progress";
    graph.title = title;
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"HelveticaNeue-Light";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 15.0f);
    //graph.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:20.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    [graph.plotAreaFrame setBorderLineStyle:nil];
    //[graph.plotAreaFrame setBackgroundColor:[UIColor whiteColor].CGColor];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
}

-(void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    //[plotSpace setAllowsUserInteraction:NO];
    // 2 - Create the three plots
    CPTScatterPlot *recentPlot = [[CPTScatterPlot alloc] init];
    
    recentPlot.dataSource = self;
    recentPlot.identifier = @"Recent";
    CPTColor *recentColor = [CPTColor redColor];
    [graph addPlot:recentPlot toPlotSpace:plotSpace];
    
    CPTScatterPlot *weekPlot = [[CPTScatterPlot alloc] init];
    [weekPlot setHidden:YES];
    weekPlot.dataSource = self;
    weekPlot.identifier = @"Week";
    CPTColor *weekColor = [CPTColor redColor];
    [graph addPlot:weekPlot toPlotSpace:plotSpace];
    
    CPTScatterPlot *overallPlot = [[CPTScatterPlot alloc] init];
    [overallPlot setHidden:YES];
    overallPlot.dataSource = self;
    overallPlot.identifier = @"Overall";
    CPTColor *overallColor = [CPTColor redColor];
    [graph addPlot:overallPlot toPlotSpace:plotSpace];
    
    // 3 - Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:recentPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    double partialLength = 0.05 * CPTDecimalDoubleValue(yRange.length);
    
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.6f)];
    double firstWeight = [[[_workoutData objectAtIndex:[_workoutData count] - 5]objectForKey:@"weight"] doubleValue];
    // Calculate first weight
    yRange = [CPTMutablePlotRange plotRangeWithLocation:CPTDecimalFromString([NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:firstWeight - 2.5]]) length: yRange.length];
    plotSpace.yRange = yRange;
    
    // 4 - Create styles and symbols
    
    CPTMutableLineStyle *recentLineStyle = [recentPlot.dataLineStyle mutableCopy];
    recentLineStyle.lineWidth = 2.5;
    recentLineStyle.lineColor = recentColor;
    recentPlot.dataLineStyle = recentLineStyle;
    CPTMutableLineStyle *recentSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    recentSymbolLineStyle.lineColor = recentColor;
    CPTPlotSymbol *recentSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    recentSymbol.fill = [CPTFill fillWithColor:recentColor];
    recentSymbol.lineStyle = recentLineStyle;
    recentSymbol.size = CGSizeMake(6.0f, 6.0f);
    recentPlot.plotSymbol = recentSymbol;
    
    CPTMutableLineStyle *weekLineStyle = [weekPlot.dataLineStyle mutableCopy];
    weekLineStyle.lineWidth = 2.5;
    weekLineStyle.lineColor = weekColor;
    weekPlot.dataLineStyle = weekLineStyle;
    CPTMutableLineStyle *weekSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    weekSymbolLineStyle.lineColor = weekColor;
    CPTPlotSymbol *weekSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    weekSymbol.fill = [CPTFill fillWithColor:weekColor];
    weekSymbol.lineStyle = weekLineStyle;
    weekSymbol.size = CGSizeMake(6.0f, 6.0f);
    weekPlot.plotSymbol = weekSymbol;
    
    CPTMutableLineStyle *overallLineStyle = [overallPlot.dataLineStyle mutableCopy];
    overallLineStyle.lineWidth = 2.5;
    overallLineStyle.lineColor = overallColor;
    overallPlot.dataLineStyle = overallLineStyle;
    CPTMutableLineStyle *overallSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    overallSymbolLineStyle.lineColor = overallColor;
    CPTPlotSymbol *overallSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    overallSymbol.fill = [CPTFill fillWithColor:overallColor];
    overallSymbol.lineStyle = overallLineStyle;
    overallSymbol.size = CGSizeMake(6.0f, 6.0f);
    overallPlot.plotSymbol = overallSymbol;
}

-(void)configureAxes {
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"HelveticaNeue-Light";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"HelveticaNeue-Light";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTXYAxis *x = axisSet.xAxis;

    double firstWeight = [[[_workoutData objectAtIndex:[_workoutData count]-5]objectForKey:@"weight"] doubleValue];
    x.orthogonalCoordinateDecimal = CPTDecimalFromString([NSString stringWithFormat:@"%@",[NSNumber numberWithDouble: firstWeight - 2.5]]);
    x.title = @"Sessions Past";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat dateCount = [_workoutData count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    
    for (NSDictionary *workout in _workoutData) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt:5-i]] textStyle:x.labelTextStyle];
        CGFloat location = i;

        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
        i++;
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    
    
    // 4 - Configure y-axis
    CPTXYAxis *y = axisSet.yAxis;
    //y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"130");
    NSString *yTitle = [NSString stringWithFormat:@"Weight (%@)",[[_workoutData lastObject] objectForKey:@"units"]];
    y.title = yTitle;
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 20.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 10;
    NSInteger minorIncrement = 2.5;
    CGFloat yMax = 500.0f;  // should determine dynamically based on max price
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li", (long)j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;    
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}

#pragma mark - CPTScatterPlot methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    NSString *plotId = plot.identifier;
    if([plotId isEqualToString:@"Recent"]){
        return 5;
    }else if([plotId isEqualToString:@"Week"]){
        NSTimeInterval pastWeeks = 60 * 60 * 24 * 7 * numWeeks;
        NSInteger indexOfOldestWorkout = 0;
        for(int i = 0; i< [_workoutData count]; i++){
            NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:[[_workoutData objectAtIndex:i] objectForKey:@"timestamp"]];
            if(diff > pastWeeks){
                // Located index of workout thats too old
                indexOfOldestWorkout = i - 1;
                break;
            }
            if(i == [_workoutData count] - 1){
                indexOfOldestWorkout = [_workoutData count];
            }
        }
        if(indexOfOldestWorkout == -1){
            return 0;
        }
        return indexOfOldestWorkout;
    }else{
        return [_workoutData count];
    }
    return [_workoutData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx{
    NSInteger valueCount = [_workoutData count];
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if([plot.identifier isEqual:@"Recent"]){
                if(idx < valueCount){
                    return [NSNumber numberWithUnsignedInteger:idx];
                }
            }else if([plot.identifier isEqual:@"Week"]){
                return [NSNumber numberWithInt:idx];
            }else{
                return [NSNumber numberWithInt:idx];
            }
            break;
        case CPTScatterPlotFieldY:
            if([plot.identifier isEqual:@"Recent"]){
                return [NSNumber numberWithDouble:[[[_workoutData objectAtIndex:valueCount - 5 + idx] objectForKey:@"weight"] doubleValue]];
            }else if([plot.identifier isEqual:@"Week"]){
                return [NSNumber numberWithDouble:[[[_workoutData objectAtIndex:idx] objectForKey:@"weight"] doubleValue]];
            }else{
                return [NSNumber numberWithDouble:[[[_workoutData objectAtIndex:idx] objectForKey:@"weight"] doubleValue]];
            }
            break;
    }
    
    
    return [NSDecimalNumber zero];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
