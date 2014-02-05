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
//  SplashBoard_iPhone.m
//  Demo
//
//  Created by hao on 13-9-24.
//  Copyright (c) 2013年 hao. All rights reserved.
//

#import "SplashBoard_iPhone.h"

#pragma mark -

@interface SplashBoard_iPhone()
{
	//<#@private var#>
}
@end

@implementation SplashBoard_iPhone

SUPPORT_AUTOMATIC_LAYOUT( YES );
SUPPORT_RESOURCE_LOADING( YES );

DEF_NOTIFICATION( PLAY_DONE )

ON_SIGNAL2( BeeUIBoard, signal )
{
	[super handleUISignal:signal];
	
	if ( [signal is:BeeUIBoard.CREATE_VIEWS] )
	{
		[self hideNavigationBarAnimated:NO];
	}
	else if ( [signal is:BeeUIBoard.DELETE_VIEWS] )
	{
	}
	else if ( [signal is:BeeUIBoard.WILL_APPEAR] )
	{
		$(@"#slogan, #logo").ALPHA( 0.0f );
	}
	else if ( [signal is:BeeUIBoard.DID_APPEAR] )
	{
		$(@"#logo, #slogan")
		.FADE_IN()
		.DURATION( 0.5f )
		.DELAY( 0.1f );
        
		$(@"#logo")
		.BOUNCE()
		.DURATION( 0.5f )
		.DELAY( 0.5f )
		.ON_COMPLETE( ^{
            
			$(self)
			.FADE_OUT()
			.DURATION( 0.5f )
			.DELAY( 0.15f );
			
			$(self)
			.ZOOM_IN( $(@"#zoom-in-here").frame )
			.DURATION( 0.75f )
			.ON_COMPLETE( ^{
				
				[self postNotification:self.PLAY_DONE];
                
			});
		});
	}
}

@end
