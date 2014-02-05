//
//  TXMobileAuthenticationMessage.h
//  MobileCore
//
//  Created by nonesu on 10/10/12.
//
//

#import <Foundation/Foundation.h>

@interface TXMobileAuthenticationMessage : NSObject
{
    int _code;
    NSString * _text;
}

@property int code;
@property (nonatomic,retain) NSString *text;

@end
