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
//  PlotBoard_iPhone.h
//  Demo
//
//  Created by hao on 13-8-12.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "Bee.h"
#import "CorePlot-CocoaTouch.h"

#pragma mark -

@interface PlotBoard_iPhone : BeeUIBoard <CPTPlotDataSource>

@property (nonatomic, retain) NSMutableArray * dataArray;

@end
