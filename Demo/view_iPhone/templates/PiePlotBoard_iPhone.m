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
//  PiePlotBoard_iPhone.m
//  Demo
//
//  Created by hao on 13-8-13.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "PiePlotBoard_iPhone.h"
#import "ServerAPI.h"
#import "Helper.h"

#pragma mark -

@interface PiePlotBoard_iPhone()
{
	//<#@private var#>
    CPTPlotSpaceAnnotation * _plotAnnotation;
    NSUInteger _offsetIndex;
}
@end

@implementation PiePlotBoard_iPhone

SUPPORT_AUTOMATIC_LAYOUT( YES );
SUPPORT_RESOURCE_LOADING( YES );

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
    if ( [msg is:ServerAPI.GET_PAGE_DETAIL ] ) {
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
            [self drawGraph];
        }
    }
}

#pragma mark - 绘图

- (void)preprocessVars
{
    // 累加所有值，方便做百分比计算
    for(NSDictionary * pair in self.plotDataSource[self.plotIdentifiers[0]]) {
        INFO(@"pair[y]: %.2f", [pair[@"y"] doubleValue]);
        _sumOfRecords += [pair[@"y"] doubleValue];
    }
}

- (void)drawGraph
{
    _graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [_graph applyTheme:theme];
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:self.bounds];
    hostingView.hostedGraph = _graph;
    [self.view addSubview:hostingView];

    _graph.paddingLeft    = 2.0;
    _graph.paddingTop     = 20.0;
    _graph.paddingRight   = 2.0;
    _graph.paddingBottom  = 20.0;
    
    _graph.plotAreaFrame.paddingLeft    = 20.0;
    _graph.plotAreaFrame.paddingTop     = 0.0;
    _graph.plotAreaFrame.paddingRight   = 20.0;
    _graph.plotAreaFrame.paddingBottom  = 170.0;
    
    _graph.axisSet = nil;
    
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color                = [CPTColor whiteColor];
    titleStyle.fontName             = @"HeiTi SC";
    titleStyle.fontSize             = 14.0f;

    _graph.titleTextStyle = titleStyle;
    _graph.title          = self.title;
    
    // Add pie chart
    CPTPieChart *piePlot    = [[CPTPieChart alloc] init];
    piePlot.dataSource      = self;
    piePlot.pieRadius       = 65;
    piePlot.identifier      = self.plotIdentifiers[0];
    piePlot.startAngle      = M_PI_4;   // 绘制第一个扇形的起始角度
    piePlot.sliceDirection  = CPTPieDirectionClockwise; // 顺时针
    piePlot.centerAnchor    = CGPointMake(0.5, 0.5);
    piePlot.borderLineStyle = [CPTLineStyle lineStyle];
    piePlot.delegate        = self;
    [_graph addPlot:piePlot];
}

#pragma mark - Plot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.numberOfRecords unsignedIntValue];
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if ( index >= [self.numberOfRecords unsignedIntValue] ) {
        return nil;
    }
    NSNumber * num = nil;
    
    switch (fieldEnum) {
        case CPTPieChartFieldSliceWidthSum:
            num = [NSNumber numberWithDouble:_sumOfRecords];
            break;
        case CPTPieChartFieldSliceWidth:
            num = self.plotDataSource[self.plotIdentifiers[0]][index][@"y"];
            break;
        case CPTPieChartFieldSliceWidthNormalized:
            num = [NSNumber numberWithDouble:([self.plotDataSource[self.plotIdentifiers[0]][index][@"y"] doubleValue] / _sumOfRecords)];
            break;
        default:
            break;
    }
    return num;
}

- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    CPTTextLayer *label            = [[CPTTextLayer alloc] initWithText:self.xLabels[index]];
    CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];
    textStyle.color                = [CPTColor whiteColor];
    textStyle.fontName             = @"HeiTi SC";
    textStyle.fontSize             = 10.0f;
    label.textStyle                = textStyle;
    return label;
}

- (CGFloat)radialOffsetForPieChart:(CPTPieChart *)piePlot recordIndex:(NSUInteger)index
{
    INFO(@"radial offset for index[%d]", index);
    CGFloat offset = 0.0;
    
    if ( index == _offsetIndex ) {  // 只针对当前被选择的扇形块进行偏移
        offset = piePlot.pieRadius / 8.0;
    }
    
    return offset;
}

#pragma mark - Delegate Methods

- (void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    INFO(@"slice[%d] was selected", index);
    
    _offsetIndex = index;   // 将当前被选择的 index 记录下来，用于重绘饼图计算偏移
    [plot reloadData];
    
    // Create style
    static CPTMutableTextStyle *style = nil;
    if (!style) {
        style          = [CPTMutableTextStyle textStyle];
        style.color    = [CPTColor blueColor];
        style.fontSize = 12.0f;
        style.fontName = @"Helvetica";
    }
    
    // Create annotation
    NSNumber  *yValue = [NSNumber numberWithDouble:[self.plotDataSource[self.plotIdentifiers[0]][index][@"y"] doubleValue]];
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
    NSString *annotationText = [NSString stringWithFormat:@"%@\n%.0f(%.2f%%)", self.xLabels[index], 
                                [yValue doubleValue], 100*[yValue doubleValue] / _sumOfRecords];
    
    CPTTextLayer *textLayer           = [[CPTTextLayer alloc] initWithText:annotationText style:style];
    textLayer.paddingLeft = 5.0f;
    textLayer.paddingRight = 5.0f;
    textLayer.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    textLayer.opacity = 0.5f;
    _plotAnnotation.contentLayer = textLayer;
        
    // Get the anchor point for annotation
    CGFloat x = 0.15;   // 这里的坐标是以圆心 (0.5, 0.5) 为参考系的
    CGFloat y = 0.9;
    NSNumber *anchorX = [NSNumber  numberWithFloat:x];
    NSNumber *anchorY = [NSNumber  numberWithDouble:y];
    _plotAnnotation.anchorPlotPoint = [NSArray  arrayWithObjects:anchorX, anchorY, nil];
    
    // Add the annotation
    [plot.graph.plotAreaFrame.plotArea addAnnotation:_plotAnnotation];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    CPTPieChart *piePlot             = (CPTPieChart *)[_graph plotWithIdentifier:self.plotIdentifiers[0]];
    CABasicAnimation *basicAnimation = (CABasicAnimation *)theAnimation;
    
    [piePlot removeAnimationForKey:basicAnimation.keyPath];
    [piePlot setValue:basicAnimation.toValue forKey:basicAnimation.keyPath];
    [piePlot repositionAllLabelAnnotations];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat margin = _graph.plotAreaFrame.borderLineStyle.lineWidth + 5.0;

    CPTPieChart *piePlot = (CPTPieChart *)[_graph plotWithIdentifier:self.plotIdentifiers[0]];
    CGRect plotBounds    = _graph.plotAreaFrame.bounds;
    CGFloat newRadius    = MIN(plotBounds.size.width, plotBounds.size.height) / 2.0 - margin;

    CGFloat y = 0.0;

    if ( plotBounds.size.width > plotBounds.size.height ) {
        y = 0.5;
    }
    else {
        y = (newRadius + margin) / plotBounds.size.height;
    }
    CGPoint newAnchor = CGPointMake(0.5, y);

    // Animate the change
    [CATransaction begin];
    {
        [CATransaction setAnimationDuration:1.0];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"pieRadius"];
        animation.toValue  = [NSNumber numberWithDouble:newRadius];
        animation.fillMode = kCAFillModeForwards;
        animation.delegate = self;
        [piePlot addAnimation:animation forKey:@"pieRadius"];
        
        animation          = [CABasicAnimation animationWithKeyPath:@"centerAnchor"];
        animation.toValue  = [NSValue valueWithBytes:&newAnchor objCType:@encode(CGPoint)];
        animation.fillMode = kCAFillModeForwards;
        animation.delegate = self;
        [piePlot addAnimation:animation forKey:@"centerAnchor"];
    }
    [CATransaction commit];
}

@end
