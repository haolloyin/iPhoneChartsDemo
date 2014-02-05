
#import "Bee.h"


#pragma mark - enums


@interface ServerAPI : BeeController

AS_MESSAGE( GET_USER_PRODUCTS );           	// 获取用户的产品列表
AS_MESSAGE( GET_PRODUCT_DETAIL );          	// 获取产品详情
AS_MESSAGE( GET_MENU_DETAIL ); 				// 获取业务菜单详情
AS_MESSAGE( GET_PAGE_DETAIL );				// 获取业务页面详情

@end
