#coding=utf8

from django.conf.urls import patterns, include, url

from mobioss import views

urlpatterns = patterns('',
	# 用户业务列表
	url(r'^(?P<rtx>\w+)/products$', views.user_products, name='user_products'),

	# 用户某个业务的主菜单
	url(r'^(?P<rtx>\w+)/(?P<product>\w+)/detail$', views.product_detail, name='product_detail'),

	# 用户某个业务某个子菜单
	url(r'^(?P<rtx>\w+)/(?P<product>\w+)/menu/(?P<menuid>\w+)$', views.product_menu_detail, name='product_menu_detail'),

	# 用户某个业务某个具体页面
	url(r'^(?P<rtx>\w+)/(?P<product>\w+)/page/(?P<pageid>\w+)$', views.product_page_detail, name='product_page_detail'),
)
