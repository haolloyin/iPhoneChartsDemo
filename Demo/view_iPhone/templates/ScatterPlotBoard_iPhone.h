//
//   ______    ______    ______    
//  /\  __ \  /\  ___\  /\  ___\   
//  \ \  __<  \ \  __\_ \ \  __\_ 
//   \ \_____\ \ \_____\ \ \_____\ 
//    \/_____/  \/_____/  \/_____/ 
//
//  Powered by BeeFramework
//
//
//  ScatterPlotBoard_iPhone.h
//  Demo
//
//  Created by hao on 13-8-13.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "Bee.h"
#import "CorePlot-CocoaTouch.h"

#pragma mark -

@interface ScatterPlotBoard_iPhone : BeeUIBoard < CPTPlotDataSource, CPTAxisDelegate, CPTScatterPlotDelegate, CPTBarPlotDelegate >
{
    CPTXYGraph * _graph;
    NSArray * _colorArray;
    NSArray * _plotSymbolArray;
}

@property (readwrite, nonatomic, strong) NSDictionary * plotDataSource;
@property (readwrite, nonatomic, strong) NSArray * plotIdentifiers;
@property (readwrite, nonatomic, strong) NSArray * xLabels;
@property (readwrite, nonatomic, strong) NSNumber * numberOfPlots;
@property (readwrite, nonatomic, strong) NSNumber * numberOfRecords;

@property (readwrite, nonatomic) double minForY;
@property (readwrite, nonatomic) double maxForY;




- (void)preprocessVars;

- (void)configGraphAndHostView;

- (void)configPlots;

- (void)configAxes;

-(CPTPlotRange *)CPTPlotRangeFromFloat:(float)location length:(float)length;

@end
