//
//	 ______    ______    ______    
//	/\  __ \  /\  ___\  /\  ___\   
//	\ \  __<  \ \  __\_ \ \  __\_ 
//	 \ \_____\ \ \_____\ \ \_____\ 
//	  \/_____/  \/_____/  \/_____/ 
//
//	Powered by BeeFramework
//
//
//  BarPlotBoard_iPhone.m
//  Demo
//
//  Created by hao on 13-8-13.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "BarPlotBoard_iPhone.h"
#import "ServerAPI.h"
#import "Helper.h"

#pragma mark -

@interface BarPlotBoard_iPhone()
{
	//<#@private var#>
}
@end

@implementation BarPlotBoard_iPhone

SUPPORT_AUTOMATIC_LAYOUT( YES );
SUPPORT_RESOURCE_LOADING( YES );

const CGFloat initialBarOffset = 0.2;
const CGFloat xAxisLength = 7.0;

- (void)load
{
	[super load];
}

- (void)unload
{
	[super unload];
}

#pragma mark Signal

ON_SIGNAL2( BeeUIBoard, signal )
{
    [super handleUISignal:signal];

    if ( [signal is:BeeUIBoard.CREATE_VIEWS] )
    {        
        [self.navigationController.navigationBar setTitleTextAttributes:[Helper fontDictWithFontSize:12.0f andColor:[UIColor whiteColor]]];

    }
    else if ( [signal is:BeeUIBoard.DELETE_VIEWS] )
    {
    }
    else if ( [signal is:BeeUIBoard.LAYOUT_VIEWS] )
    {
    }
    else if ( [signal is:BeeUIBoard.LOAD_DATAS] )
    {
    }
    else if ( [signal is:BeeUIBoard.FREE_DATAS] )
    {
    }
    else if ( [signal is:BeeUIBoard.WILL_APPEAR] )
    {
    }
    else if ( [signal is:BeeUIBoard.DID_APPEAR] )
    {
    }
    else if ( [signal is:BeeUIBoard.WILL_DISAPPEAR] )
    {
    }
    else if ( [signal is:BeeUIBoard.DID_DISAPPEAR] )
    {
    }
}

ON_SIGNAL2( BeeUINavigationBar, signal )
{
	[super handleUISignal:signal];
	
	if ( [signal is:BeeUINavigationBar.LEFT_TOUCHED] )
	{
	}
	else if ( [signal is:BeeUINavigationBar.RIGHT_TOUCHED] )
	{
	}
}

#pragma mark - 处理 Controller 消息

- (void)handleMessage:(BeeMessage *)msg
{
    [super handleMessage:msg];
    if ( [msg is:ServerAPI.GET_PAGE_DETAIL] ) {
        if ( msg.succeed ) {
            NSDictionary * resp  = msg.GET_OUTPUT( @"response" );
            self.plotDataSource  = resp[@"plot_data_source"];
            self.plotIdentifiers = resp[@"plot_identifiers"];
            self.xLabels         = resp[@"x_labels"];
            self.numberOfPlots   = resp[@"number_of_plots"];
            self.numberOfRecords = resp[@"number_of_records"];
            
//            INFO(@"plotDataSource: %@", self.plotDataSource);
            INFO(@"xLabels: %@", self.xLabels);
            INFO(@"plotIdentifiers: %@", self.plotIdentifiers);
            INFO(@"numberOfPlots: %@", self.numberOfPlots);
            INFO(@"numberOfRecords: %@", self.numberOfRecords);

            [self preprocessVars];
            [self configGraphAndHostView];
            [self configPlots];
            [self configAxes];
        }
    }
}

#pragma mark - 绘图

- (void)preprocessVars
{
    self.minForY = MAXFLOAT;
    self.maxForY = -MAXFLOAT;
    
    // 获取到所有曲线中 Y 坐标的最大、最小值
    for ( int i = 0; i < [self.numberOfPlots intValue]; ++i ) {
        NSArray * dataArray = self.plotDataSource[self.plotIdentifiers[i]];
        for ( id dict in dataArray ) {
            double yValue = [dict[@"y"] doubleValue];
            
            if ( yValue < self.minForY ) {
                self.minForY = yValue;
            }
            if ( yValue > self.maxForY ) {
                self.maxForY = yValue;
            }
        }
    }
    
    INFO(@"preprocess: Y[%.2f, %.2f], interval: %.2f", self.minForY, self.maxForY, self.maxForY*0.05);

    _recordInterval = (xAxisLength - initialBarOffset) / [self.numberOfRecords intValue];       // 每个点之间的距离
    
    if (_recordInterval > 1.8) {
        _recordInterval = 1.5;  // 避免numberOfRecords 较小时，导致条状宽度、间隔过大将右边的挤出可视范围内
    }
    
    _barWidth = _recordInterval * 0.6 / [self.numberOfPlots intValue];     // 每个柱状的宽度
}

- (void)configGraphAndHostView
{
    _colorArray          = @[[CPTColor yellowColor], [CPTColor cyanColor], [CPTColor lightGrayColor]];
    self.title           = @"柱状图";
    
    // 1 - Create the graph
    _graph                         = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTGraphHostingView * hostView = [[CPTGraphHostingView alloc] initWithFrame:self.bounds];
    hostView.collapsesLayers       = NO;
    hostView.hostedGraph           = _graph;
    [_graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    [self.view addSubview:hostView];
    
    // 2 - Set graph title
    _graph.title = self.title;
    
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color                = [CPTColor whiteColor];
    titleStyle.fontName             = @"HeiTi SC";
    titleStyle.fontSize             = 14.0f;
    _graph.titleTextStyle           = titleStyle;
    _graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    _graph.titleDisplacement        = CGPointMake(0.0f, 10.0f);
    
    // 4 - Set padding for plot area
    _graph.paddingLeft    = 2.0;
    _graph.paddingTop     = 20.0;
    _graph.paddingRight   = 2.0;
    _graph.paddingBottom  = 20.0;
    
    _graph.plotAreaFrame.paddingLeft    = 40.0;
    _graph.plotAreaFrame.paddingTop     = 30.0;
    _graph.plotAreaFrame.paddingRight   = 20.0;
    _graph.plotAreaFrame.paddingBottom  = 170.0;
}

- (void)configPlots
{
    // 1 - Get graph and plot space
    CPTXYPlotSpace * plotSpace      = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    
    CGFloat barX = _barWidth / 2;    
    for(int i = 0; i < [self.numberOfPlots intValue]; ++i)
    {
        // 2 - Create the plots        
        CPTBarPlot *barPlot     = [CPTBarPlot tubularBarPlotWithColor:_colorArray[i] horizontalBars:NO];
        barPlot.fill            = [CPTFill fillWithColor:_colorArray[i]];
        barPlot.dataSource      = self;
        barPlot.delegate        = self;
        barPlot.barCornerRadius = 0.0f;
        barPlot.identifier      = self.plotIdentifiers[i];
        barPlot.baseValue       = CPTDecimalFromString(@"0");   // The coordinate value of the fixed end of the bars
        barPlot.barWidth        = CPTDecimalFromFloat(_barWidth);    // 柱状图的宽度
        barPlot.barOffset       = CPTDecimalFromFloat(barX);    // The starting offset of the first bar in location data units
        
        INFO(@"barOffset: %.2f", barX);
        
        barX                    += _barWidth * 1.05;    // 相关两个柱状之间的间隔

        [_graph addPlot:barPlot toPlotSpace:plotSpace];
    }
    
    // 3 - Set up plot space
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(8.3)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(8.2)];
    
    INFO(@"xRange: %@", plotSpace.xRange);
    INFO(@"yRange: %@", plotSpace.yRange);
}

- (void)configAxes
{
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color                = [CPTColor whiteColor];
    axisTitleStyle.fontName             = @"HeiTi SC";
    axisTitleStyle.fontSize             = 12.0f;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth            = 2.0f;
    axisLineStyle.lineColor            = [CPTColor cyanColor];
    
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color                = [CPTColor whiteColor];
//    axisTextStyle.fontName             = @"HeiTi SC";
    axisTextStyle.fontSize             = 10.0f;
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor            = [CPTColor whiteColor];
    tickLineStyle.lineWidth            = 2.0f;
    
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor            = [CPTColor lightGrayColor];
    gridLineStyle.lineWidth            = 0.2f;
    gridLineStyle.dashPattern          = [NSArray arrayWithObjects:[NSNumber numberWithFloat:4.0f], [NSNumber numberWithFloat:4.0f], nil];
    
    CPTXYAxisSet *axisSet         = (CPTXYAxisSet *)_graph.axisSet;
    
    // 2 - 设置 X 轴
    CPTXYAxis *x                  = axisSet.xAxis;
    x.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0f]; // Y轴只能在X轴0.0处上下移动
    x.axisLineStyle               = axisLineStyle;
    x.majorTickLineStyle          = tickLineStyle;
    x.minorTickLineStyle          = nil;
    x.majorTickLength             = 4.0f;
    x.tickDirection               = CPTSignNegative;
    x.majorIntervalLength         = CPTDecimalFromString(@"1"); // TODO: 
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    x.title                       = @"日期";
    x.titleLocation               = CPTDecimalFromFloat(8.15f);
    x.titleOffset                 = 20.0f;
    x.titleTextStyle              = axisTitleStyle;
    x.labelTextStyle              = axisTextStyle;
    x.labelRotation               = M_PI / 5;
    
    x.labelingPolicy         = CPTAxisLabelingPolicyNone;
    
    NSMutableSet *xLabels    = [NSMutableSet setWithCapacity:[self.numberOfPlots unsignedIntValue]];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:[self.numberOfPlots unsignedIntValue]];

    // 计算每个主刻度之间应该间隔多少个刻度，小于等于7个则保持不变，否则需要按等差只取部分label
    int labelInterval = 1;
    if([self.numberOfRecords integerValue] > 7)
    {
       labelInterval = ([self.numberOfRecords intValue] - 1) / 7 + 1;
    }

    for (int i = 0; i < [self.xLabels count]; i = i + labelInterval) {
       CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:self.xLabels[i]  textStyle:x.labelTextStyle];
       CGFloat location    = initialBarOffset + _barWidth / 2.0 + (xAxisLength - initialBarOffset) / ([self.numberOfRecords intValue] - 1) * i;
       label.tickLocation  = CPTDecimalFromCGFloat(location);
       label.offset        = x.majorTickLength + 4.0f;
       label.rotation      = M_PI / 5;

       INFO(@"numberOfRecords: %d, labelInterval: %d, labelLocation: %.2f", [self.numberOfRecords intValue], labelInterval, location);

       if (label) {
           [xLabels addObject:label];
           [xLocations addObject:[NSNumber numberWithFloat:location]];
       }
    }
    x.axisLabels         = xLabels;
    x.majorTickLocations = xLocations;
    
    // 3 - 设置 Y 轴
    CPTXYAxis *y                  = axisSet.yAxis;
    y.axisLineStyle               = axisLineStyle;
    y.majorTickLineStyle          = tickLineStyle;
    y.minorTickLineStyle          = nil;
    y.majorTickLength             = 4.0f;
    y.tickDirection               = CPTSignPositive;
    y.majorIntervalLength         = CPTDecimalFromString(@"1");
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    y.labelingPolicy              = CPTAxisLabelingPolicyNone;
    y.labelTextStyle              = axisTextStyle;
    y.labelOffset                 = 20.0f;
    y.labelRotation               = M_PI / 5; 
    y.title                       = @"Y轴数值";
    y.titleRotation               = 0.0;
    y.titleOffset                 = -30.0f;
    y.titleTextStyle              = axisTitleStyle;
    y.titleLocation               = CPTDecimalFromFloat(8.6f);
    y.majorGridLineStyle          = gridLineStyle;
    y.minorGridLineStyle          = gridLineStyle;
    
    float majorValueIncrement     = self.maxForY*1.1 / 4.0; // Y轴每个主刻度之间的差值;
    float yOriginalValue          = 0.0f; // Y轴起始点对应的值
    
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:yOriginalValue];
    
    INFO(@"yOriginalValue: %.3f, yMaxValue: %.3f, yMajorInterval: %.3f", yOriginalValue, self.maxForY*1.1, majorValueIncrement);
    
    NSMutableSet *yLabels         = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    
    // 计算Y轴主、副刻度的位置，固定是 4 个
    for (int j = 0; j <= 4; ++j) {
        
        float majorValue    = yOriginalValue + majorValueIncrement * j;
        CPTAxisLabel *label;
        NSString *numStr;

        if (majorValue > 10000.0) {
            numStr = [NSString stringWithFormat:@"%.1fw", majorValue / 10000.0];
        }
        else {
            numStr = [NSString stringWithFormat:@"%.0f", majorValue];
        }
        label = [[CPTAxisLabel alloc] initWithText:numStr textStyle:y.labelTextStyle];
        
        NSDecimal location  = CPTDecimalFromFloat(8.0/4 * j);
        label.tickLocation  = location;
        label.offset        = -y.majorTickLength - y.labelOffset - 10.0f;

        if (label) {
            [yLabels addObject:label];
        }
        [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromFloat(8.0/8 * (2*j-1))]];
    }
    y.axisLabels         = yLabels;    
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;

}

#pragma mark - Data Source Delegate

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.numberOfRecords unsignedIntValue];
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber * num        = nil;
    NSString * identifier = (NSString *)plot.identifier;
    float yMajorInterval  = self.maxForY * 1.1 / 4;
    
    if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                num = [NSNumber numberWithFloat:initialBarOffset + (xAxisLength - initialBarOffset) / ([self.numberOfRecords intValue] - 1) * index];
                break;
                
            case CPTBarPlotFieldBarTip:
                num = self.plotDataSource[identifier][index][@"y"];
                num = [NSNumber numberWithDouble:[num doubleValue] / yMajorInterval * 8.0/4];
                break;
        }
    }
    return num;
}

// 用 Touch Event 来触发指定的点显示出值更好
//- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
//{
//    NSString * identifier          = (NSString *)plot.identifier;
//    NSNumber * num                 = self.plotDataSource[identifier][index][@"y"];
//    CPTTextLayer *label            = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%.2f", [num doubleValue]]];
//    CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];
//    textStyle.color                = [CPTColor lightGrayColor];
//    label.textStyle                = textStyle;
//    [textStyle release];
//    return [label autorelease];
//}

#pragma mark - CPTBarPlotDelegate Delegate

- (void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
    INFO(@"bar[%d] was selected", index);
    
    // Create style
    static CPTMutableTextStyle *style = nil;
    if (!style) {
        style          = [CPTMutableTextStyle textStyle];
        style.color    = [CPTColor blueColor];
        style.fontSize = 12.0f;
        style.fontName = @"Helvetica";
    }

    // Create annotation
    NSNumber  *yValue = self.plotDataSource[plot.identifier][index][@"y"];
    if (!_plotAnnotation) {
        NSNumber  *x          = [NSNumber  numberWithInt:0];
        NSNumber  *y          = [NSNumber  numberWithInt:0];
        NSArray  *anchorPoint = [NSArray  arrayWithObjects:x, y, nil];
        _plotAnnotation       = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
    }

    // Create number formatter
    static NSNumberFormatter  *formatter = nil;
    if (!formatter) {
        formatter = [[NSNumberFormatter  alloc] init];
        [formatter setMaximumFractionDigits:2];
    }

    // Create text layer for annotation
    NSString *annotationText = [NSString stringWithFormat:@"%@\n%@  %.0f", self.xLabels[index], plot.identifier, [yValue doubleValue]];
    
    CPTTextLayer *textLayer           = [[CPTTextLayer alloc] initWithText:annotationText style:style];
    textLayer.paddingLeft = 5.0f;
    textLayer.paddingRight = 5.0f;
    textLayer.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    textLayer.opacity = 0.5f;
    _plotAnnotation.contentLayer = textLayer;

    // Get the anchor point for annotation
    CGFloat x = initialBarOffset + (xAxisLength - initialBarOffset) / ([self.numberOfRecords intValue] - 1) * index;
    CGFloat y = 8.2f;
    NSNumber *anchorX = [NSNumber  numberWithFloat:x];
    NSNumber *anchorY = [NSNumber  numberWithDouble:y];
    _plotAnnotation.anchorPlotPoint = [NSArray  arrayWithObjects:anchorX, anchorY, nil];

    // Add the annotation 
    [plot.graph.plotAreaFrame.plotArea addAnnotation:_plotAnnotation];
}

@end
