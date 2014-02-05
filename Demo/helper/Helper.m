//
//  Helper.m
//  Demo
//
//  Created by hao on 13-10-1.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+ (NSDictionary *)maxAndMinInArray:(NSArray *)array
{
	NSNumber * max = [NSNumber numberWithFloat:0.0f];
	NSNumber * min = [NSNumber numberWithFloat:0.0f];;
    
	for ( int i = 0; i < [array count]; ++i ) {
		if ( array[i] > max ) {
			max = array[i];
		}
		
		if ( array[i] < min ) {
			min = array[i];
		}
	}
    
	return @{ @"max": max, @"min": min };
}

+ (NSDictionary *)fontDictWithFontSize:(float)fontSize andColor:(UIColor *)color
{
	NSDictionary * fontDict = @{
                             NSFontAttributeName:[UIFont fontWithName:@"Heiti SC" size:fontSize],
                             NSForegroundColorAttributeName:color
                             };
    
    return fontDict;
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)msg
               cancelTitle:(NSString *)cancelTitle
                otherTitle:(NSString *)otherTitle
{
    UIAlertView *alert = nil;
    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil)
                                       message:NSLocalizedString(msg, nil)
                                      delegate:self
                             cancelButtonTitle:cancelTitle
                             otherButtonTitles:NSLocalizedString(otherTitle, nil), nil];
    [alert show];
}

@end
