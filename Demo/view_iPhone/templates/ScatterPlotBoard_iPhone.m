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
//  ScatterPlotBoard_iPhone.m
//  Demo
//
//  Created by hao on 13-8-13.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "ScatterPlotBoard_iPhone.h"
#import "ServerAPI.h"
#import "Helper.h"

#pragma mark -

@interface ScatterPlotBoard_iPhone()
{
	//<#@private var#>
    CPTPlotSpaceAnnotation * _plotAnnotation;
}
@end

@implementation ScatterPlotBoard_iPhone

SUPPORT_AUTOMATIC_LAYOUT( YES )
SUPPORT_RESOURCE_LOADING( YES )

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
//            INFO(@"xLabels: %@", self.xLabels);
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

#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
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
}

- (void)configGraphAndHostView
{
    _colorArray      = @[[CPTColor yellowColor], [CPTColor whiteColor], [CPTColor cyanColor]];
    _plotSymbolArray = @[[CPTPlotSymbol ellipsePlotSymbol], [CPTPlotSymbol starPlotSymbol], [CPTPlotSymbol diamondPlotSymbol]];
    
    // 1 - Create the graph
    _graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    [_graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    CPTGraphHostingView * hostView = [[CPTGraphHostingView alloc] initWithFrame:self.bounds];
    hostView.collapsesLayers       = NO;
    hostView.hostedGraph           = _graph;
    [self.view addSubview:hostView];
    
    // 2 - Set graph title
    NSString *title = @"折线图";
    _graph.title = title;
    
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
    CPTXYPlotSpace * plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    
    for(int i = 0; i < [self.numberOfPlots intValue]; ++i)
    {
        // 2 - Create the three plots
        CPTScatterPlot * plot = [[CPTScatterPlot alloc] init];
        plot.dataSource       = self;
        plot.delegate         = self;
        plot.identifier       = self.plotIdentifiers[i];
        [_graph addPlot:plot toPlotSpace:plotSpace];
        
        // 3 - Create styles and symbols
        CPTMutableLineStyle * lineStyle       = [plot.dataLineStyle mutableCopy];
        lineStyle.lineWidth                   = 1.25;
        lineStyle.lineColor                   = _colorArray[i];
        plot.dataLineStyle                    = lineStyle;
        
        CPTMutableLineStyle * symbolLineStyle = [CPTMutableLineStyle lineStyle];
        symbolLineStyle.lineColor             = _colorArray[i];
        CPTPlotSymbol * symbol                = _plotSymbolArray[i];
        symbol.fill                           = [CPTFill fillWithColor:_colorArray[i]];
        symbol.lineStyle                      = symbolLineStyle;
        symbol.size                           = CGSizeMake(3.0f, 3.0f);
        plot.plotSymbol                       = symbol;
    }
    
    // 4 - 创建一个 RangePlot，用于捕捉 touch 事件
    CPTBarPlot * barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor whiteColor] horizontalBars:NO];
    barPlot.fill            = nil;//[CPTFill fillWithColor:[CPTColor whiteColor]];
    barPlot.dataSource      = self;
    barPlot.delegate        = self;
    barPlot.barCornerRadius = 0.0f;
    barPlot.identifier      = @"bar";
    barPlot.lineStyle       = nil;  // 不要画出边界
    barPlot.baseValue       = CPTDecimalFromString(@"0");   // The coordinate value of the fixed end of the bars
    barPlot.barWidth        = CPTDecimalFromFloat(0.2f);    // 柱状图的宽度
    barPlot.barOffset       = CPTDecimalFromFloat(0.0f);    // The starting offset of the first bar in location data units
    [_graph addPlot:barPlot toPlotSpace:plotSpace];

    // 4 - Set up plot space
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
    axisTextStyle.fontName             = @"HeiTi SC";
    axisTextStyle.fontSize             = 10.0f;
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor            = [CPTColor whiteColor];
    tickLineStyle.lineWidth            = 2.0f;
    
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor            = [CPTColor lightGrayColor];
    gridLineStyle.lineWidth            = 0.2f;
    gridLineStyle.dashPattern          = [NSArray arrayWithObjects:[NSNumber numberWithFloat:4.0f], [NSNumber numberWithFloat:4.0f], nil];
    
    // 2 - Get axis set
    CPTXYAxisSet *axisSet              = (CPTXYAxisSet *) _graph.axisSet;
    
    // 3 - Configure x-axis
    CPTXYAxis *x       = axisSet.xAxis;
    x.visibleAxisRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(8.3)]; // 固定8.3个单位
    x.gridLinesRange   = x.visibleAxisRange; // X轴可见范围
    
    x.title                  = @"日期";
    x.titleTextStyle         = axisTitleStyle;
    x.titleOffset            = 20.0f; // 相对X轴往下的偏移量
    x.titleLocation          = CPTDecimalFromFloat(8.15); // 相对X轴原点的偏移量
    x.axisLineStyle          = axisLineStyle;
    x.labelingPolicy         = CPTAxisLabelingPolicyNone;
    x.labelTextStyle         = axisTextStyle;
    x.majorGridLineStyle     = gridLineStyle;
    x.majorTickLineStyle     = axisLineStyle;
    x.majorTickLength        = 4.0f;
    x.tickDirection          = CPTSignNegative; // 刻度线的方向，此为X轴的负数方向，即面向第4象限
    
    NSMutableSet *xLabels    = [NSMutableSet setWithCapacity:[self.numberOfPlots unsignedIntValue]];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:[self.numberOfPlots unsignedIntValue]];

    // 计算每个主刻度之间应该间隔多少个刻度，小于等于8个则保持不变，否则需要按等差只取部分label
    int labelInterval = 1;
    if([self.numberOfRecords integerValue] > 8)
    {
        labelInterval = ([self.numberOfRecords intValue] - 1) / 7 + 1;
    }
    
    for (int i = 0; i < [self.xLabels count]; i = i + labelInterval) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:self.xLabels[i]  textStyle:x.labelTextStyle];
        CGFloat location    = i * (8.0 / ([self.numberOfRecords doubleValue]-1)); 
        label.tickLocation  = CPTDecimalFromCGFloat(location);
        label.offset        = x.majorTickLength + 2.0f;
        label.rotation      = M_PI / 5;

        INFO(@"numberOfRecords: %d, labelInterval: %d, labelLocation: %d", [self.numberOfRecords intValue], labelInterval, i);\

        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels         = xLabels;
    x.majorTickLocations = xLocations;
    
    // 4 - Configure y-axis
    CPTXYAxis *y       = axisSet.yAxis;
    y.visibleAxisRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(8.2)];
    y.gridLinesRange   = x.visibleAxisRange; // 分别设置XY轴背景表格线的可见范围，注意是XY轴互相颠倒过来的
    x.gridLinesRange   = y.visibleAxisRange;

    y.title              = @"Y轴数量";
    y.titleTextStyle     = axisTitleStyle;
    y.titleOffset        = -30.0f; // Y轴标题相对Y轴往左的偏移量
    y.titleLocation      = CPTDecimalFromFloat(8.6); // Y轴标题位置，相对Y轴的原点的偏移量
    y.titleRotation      = 0.0; // 与X轴平行，即水平放置标题
    y.axisLineStyle      = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.minorGridLineStyle = gridLineStyle;
    y.labelingPolicy     = CPTAxisLabelingPolicyNone;
    y.labelTextStyle     = axisTextStyle;
    y.labelOffset        = 20.0f;
    y.labelRotation      = M_PI / 5; 
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength    = 4.0f;
    y.minorTickLength    = 2.0f;
    y.tickDirection      = CPTSignPositive;

    float majorValueIncrement = (self.maxForY*1.1 - self.minForY) / 4.0; // Y轴每个主刻度之间的差值;
    float yOriginalValue      = self.minForY - self.maxForY * 0.05; // Y轴起始点对应的值
    
    INFO(@"yOriginalValue: %.3f, yMaxValue: %.3f, yMajorInterval: %.3f", yOriginalValue, self.maxForY*1.05, (self.maxForY*1.1-self.minForY)/4);
    
    NSMutableSet *yLabels         = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    
    // 计算Y轴主、副刻度的位置，固定是 4 个
    for (int j = 0; j <= 4; ++j) {

        CPTAxisLabel *label;
        NSString * numStr;
        
        float majorValue    = yOriginalValue + majorValueIncrement * j;
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

- (CPTPlotRange *)CPTPlotRangeFromFloat:(float)location length:(float)length
{
    return [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(location) length:CPTDecimalFromFloat(length)];
}

//- (void)changePlotRange
//{
//    // Setup plot space
//    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
//    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(3.0 + 2.0 * rand() / RAND_MAX)];
//    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(3.0 + 2.0 * rand() / RAND_MAX)];
//}

#pragma mark - Plot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
//    INFO(@"numberOfRecords: %@", self.numberOfRecords);
    return [self.numberOfRecords unsignedIntegerValue];
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber * num        = nil;
    NSString * identifier = (NSString *)plot.identifier;
    float yMajorInterval  = (self.maxForY * 1.1 - self.minForY) / 4;
    float yMinValue       = self.minForY - self.maxForY * 0.05;
    
    if ( [plot isKindOfClass:[CPTBarPlot class]] ) {    // 这里要额外判断是否辅助的 BarPlot，此时 Y 轴大小直接返回 yRange 的最大值即可
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                num = [NSNumber numberWithDouble:8.0 / ([self.numberOfRecords doubleValue]-1) * index];
                break;
                
            case CPTBarPlotFieldBarTip:
                num = self.plotDataSource[identifier][index][@"y"];
                num = [NSNumber numberWithDouble:8.0];
                break;
        }
    }
    else {
        switch (fieldEnum) {
            case CPTScatterPlotFieldX:
                num = [NSNumber numberWithDouble:8.0 / ([self.numberOfRecords doubleValue]-1) * index];
                break;
                
            case CPTScatterPlotFieldY:
                num = self.plotDataSource[identifier][index][@"y"];
                num = [NSNumber numberWithDouble:([num doubleValue] - yMinValue) / yMajorInterval * 8.0/4];
                break;
            default:
                break;
        }
    }
    
    return num;
}

#pragma mark - Plot Delegate Methods

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
    
    // 获取并格式化 Y 值
    NSString * annotationText = [NSString stringWithFormat:@"%@", self.xLabels[index]];
    for (NSString * identifier in self.plotIdentifiers) {
        NSNumber * yValue = self.plotDataSource[identifier][index][@"y"];
        annotationText = [annotationText stringByAppendingFormat:@"\n%@  %.0f", identifier, [yValue doubleValue]];
    }
    
    // Create text layer for annotation
    CPTTextLayer *textLayer           = [[CPTTextLayer alloc] initWithText:annotationText style:style];
    textLayer.paddingLeft = 5.0f;
    textLayer.paddingRight = 5.0f;
    textLayer.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    textLayer.opacity = 0.5f;
    _plotAnnotation.contentLayer = textLayer;
    
    // Get the anchor point for annotation
    CGFloat x = 8.0 / ([self.numberOfRecords doubleValue]-1) * index;
    CGFloat y = 8.1f;
    NSNumber *anchorX = [NSNumber  numberWithFloat:x];
    NSNumber *anchorY = [NSNumber  numberWithDouble:y];
    _plotAnnotation.anchorPlotPoint = [NSArray  arrayWithObjects:anchorX, anchorY, nil];
    
    // Add the annotation
    [plot.graph.plotAreaFrame.plotArea addAnnotation:_plotAnnotation];
}

//- (void) scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
//{
//    INFO(@"scatter[%d] was selected", index);
//    
//    // Create style
//    static CPTMutableTextStyle *style = nil;
//    if (!style) {
//        style          = [CPTMutableTextStyle textStyle];
//        style.color    = [CPTColor blueColor];
//        style.fontSize = 12.0f;
//        style.fontName = @"Helvetica";
//    }
//    
//    // Create annotation
//    NSNumber  *yValue = self.plotDataSource[plot.identifier][index][@"y"];
//    if (!_plotAnnotation) {
//        NSNumber  *x          = [NSNumber  numberWithInt:0];
//        NSNumber  *y          = [NSNumber  numberWithInt:0];
//        NSArray  *anchorPoint = [NSArray  arrayWithObjects:x, y, nil];
//        _plotAnnotation       = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
//    }
//    
//    // Create number formatter
//    static NSNumberFormatter  *formatter = nil;
//    if (!formatter) {
//        formatter = [[NSNumberFormatter  alloc] init];
//        [formatter setMaximumFractionDigits:2];
//    }
//    
//    // Create text layer for annotation
//    NSString *annotationText = [NSString stringWithFormat:@"%@\n%@  %.2f", self.xLabels[index], plot.identifier, [yValue doubleValue]];
//    
//    CPTTextLayer *textLayer           = [[CPTTextLayer alloc] initWithText:annotationText style:style];
//    textLayer.paddingLeft = 5.0f;
//    textLayer.paddingRight = 5.0f;
//    textLayer.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
//    textLayer.opacity = 0.5f;
//    _plotAnnotation.contentLayer = textLayer;
//    
//    // Get plot index based on identifier
//    NSInteger plotIndex = 0;
//    for (NSString * identifier in self.plotIdentifiers) {
//        if([plot.identifier isEqual:identifier]) {
//            break;
//        }
//        plotIndex += 1;
//    }
//    
//    // Get the anchor point for annotation
//    CGFloat x = 8.0 / ([self.numberOfRecords doubleValue]-1) * index;
//    CGFloat y = 8.2f;
//    NSNumber *anchorX = [NSNumber  numberWithFloat:x];
//    NSNumber *anchorY = [NSNumber  numberWithDouble:y];
//    _plotAnnotation.anchorPlotPoint = [NSArray  arrayWithObjects:anchorX, anchorY, nil];
//    
//    // Add the annotation
//    [plot.graph.plotAreaFrame.plotArea addAnnotation:_plotAnnotation];
//}

#pragma mark - Axis Delegate Methods

//- (BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
//{
//    static CPTTextStyle *positiveStyle = nil;
//    static CPTTextStyle *negativeStyle = nil;    
//    NSFormatter *formatter             = axis.labelFormatter;
//    CGFloat labelOffset                = axis.labelOffset;
//    NSDecimalNumber *zero              = [NSDecimalNumber zero];    
//    NSMutableSet *newLabels            = [NSMutableSet set];
//    
//    for ( NSDecimalNumber *tickLocation in locations ) {
//        CPTTextStyle *theLabelTextStyle;
//        
//        if ( [tickLocation isGreaterThanOrEqualTo:zero] ) {
//            if ( !positiveStyle ) {
//                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
//                newStyle.color                = [CPTColor greenColor];
//                positiveStyle                 = newStyle;
//            }
//            theLabelTextStyle = positiveStyle;
//        }
//        else {
//            if ( !negativeStyle ) {
//                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
//                newStyle.color                = [CPTColor redColor];
//                negativeStyle                 = newStyle;
//            }
//            theLabelTextStyle = negativeStyle;
//        }
//        
//        NSString *labelString       = [formatter stringForObjectValue:tickLocation];
//        CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
//        CPTAxisLabel *newLabel      = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
//        newLabel.tickLocation       = tickLocation.decimalValue;
//        newLabel.offset             = labelOffset;
//        
//        [newLabels addObject:newLabel];
//    }
//
//    axis.axisLabels = newLabels;
//    
//    return NO;
//}


@end
