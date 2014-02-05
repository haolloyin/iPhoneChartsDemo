//
//  Helper.h
//  Demo
//
//  Created by hao on 13-10-1.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject

+ (NSDictionary *)maxAndMinInArray:(NSArray *)array;

+ (NSDictionary *)fontDictWithFontSize:(float)fontSize andColor:(UIColor *)color;

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)msg
               cancelTitle:(NSString *)cancelTitle
                otherTitle:(NSString *)otherTitle;

@end
