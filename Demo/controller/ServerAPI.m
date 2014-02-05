
#import "ServerAPI.h"


@implementation ServerAPI

DEF_MESSAGE( GET_USER_PRODUCTS );           // 获取用户的产品列表
DEF_MESSAGE( GET_PRODUCT_DETAIL );          // 获取产品详情
DEF_MESSAGE( GET_MENU_DETAIL ); 			// 获取业务菜单
DEF_MESSAGE( GET_PAGE_DETAIL );				// 获取业务页面明细


- (void)GET_USER_PRODUCTS:(BeeMessage *)msg
{
	if ( msg.sending ) {
		// SERVER_URL/:rtx/products
        NSString * reqURI = [NSString stringWithFormat:@"%@/%@/products", SERVER_URL, [USER_DEFAULTS stringForKey:@"username"]];
		msg.HTTP_GET( reqURI );
	}
	else if ( msg.succeed ) {
		NSArray * resp = msg.responseJSONArray;
		if ( nil == resp ) {
            ERROR(@"resp is nil");
			msg.failed = YES;
			return;
		}
		msg.OUTPUT( @"response", resp );
	}
}

- (void)GET_PRODUCT_DETAIL:(BeeMessage *)msg
{
	if ( msg.sending ) {
		// SERVER_URL/:rtx/:product/detail
        NSString * reqURI = [NSString stringWithFormat:@"%@/%@/%@/detail",
                             SERVER_URL,
                             [USER_DEFAULTS stringForKey:@"username"],
                             msg.GET_INPUT(@"productName")];
		msg.HTTP_GET( reqURI );
	}
	else if ( msg.succeed ) {
		NSArray * resp = msg.responseJSONArray;
		if ( nil == resp ) {
            ERROR(@"resp is nil");
			msg.failed = YES;
			return;
		}
		msg.OUTPUT( @"response", resp );
	}
}

- (void)GET_MENU_DETAIL:(BeeMessage *)msg
{
	if ( msg.sending ) {
		// SERVER_URL/:rtx/:product/menu/:menuid
        NSString * reqURI = [NSString stringWithFormat:@"%@/%@/%@/menu/%@",
                             SERVER_URL,
                             [USER_DEFAULTS stringForKey:@"username"],
                             msg.GET_INPUT(@"subMenuInfo")[@"productName"],
                             msg.GET_INPUT(@"subMenuInfo")[@"next_id"]];
		msg.HTTP_GET( reqURI );
	}
	else if ( msg.succeed ) {
		NSArray * resp = msg.responseJSONArray;
		if ( nil == resp ) {
			ERROR(@"resp is nil");
			msg.failed = YES;
			return;
		}
		msg.OUTPUT( @"response", resp );
	}
}

- (void)GET_PAGE_DETAIL:(BeeMessage *)msg
{
	if ( msg.sending ) {
		// SERVER_URL/:rtx/:product/page/:pageid
        NSString * reqURI = [NSString stringWithFormat:@"%@/%@/%@/page/%@", 
                             SERVER_URL,
                             [USER_DEFAULTS stringForKey:@"username"],
                             msg.GET_INPUT(@"pageInfo")[@"productName"],
                             msg.GET_INPUT(@"pageInfo")[@"next_id"]];
		msg.HTTP_GET( reqURI );
	}
	else if ( msg.succeed ) {
		NSArray * resp = msg.responseJSONArray;
		if ( nil == resp ) {
			ERROR(@"resp is nil");
			msg.failed = YES;
			return;
		}
		msg.OUTPUT( @"response", resp[0] );
	}
}


@end
