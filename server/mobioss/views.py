#coding=utf-8
# Create your views here.

from random import randint
from json import dumps
from datetime import date, timedelta
import math
import sys

from django.http import HttpResponse, HttpResponseRedirect
from django.shortcuts import render
from django.template import loader

from osscfg.models import *
from mobioss.utils import DBAPI

reload(sys)
sys.setdefaultencoding('utf-8')

# 共 3 中图表类型
CHART_TYPE = ["Scatter", "Pie", "Bar"]

def _randnum():
	result = randint(100, 999999) / 10000.0
	return '%0.2f' % result


def user_products(request, rtx):
	""" /:rtx/products
		return products list for a user
	"""
	reqdata = request.GET if request.method == 'GET' else request.POST	
	products_list = []
	visitor = Visitor.find_rtx(rtx) # 判断用户是否有权限
	if visitor is not None:
		products = visitor.products.all() # 获取所有业务列表
		product_num = len(products)
		if product_num > 0:
			for product in products:
				p = {
					'product' : product.name_en,
					'id'      : product.id,
					'name_cn'    : product.name_cn,
					'logo'    : '64_%s.png' % product.id
				}
				products_list.append(p)
	else:
		#TODO demo 用户
		print 'rtx: %s 无权限' % rtx
		p = {
			"product" : "demo", 
			"id"      : 100,
			"name_cn"    : "Demo", 
			"logo"    : "demo.png"
		}
		products_list.append(p)
	ctx = { "products_list": products_list }
	return render( request, 'mobioss_user_products.json', ctx )


def product_detail(request, rtx, product):
	""" /:rtx/:product/detail
		返回指定 product 的主菜单
	"""
	reqdata = request.GET if request.method == 'GET' else request.POST	
	detail_list = []
	product = product.lower()
	print 'rtx:', rtx, 'product:', product
	visitor = Visitor.find_rtx(rtx) # 判断用户是否有权限
	if visitor is not None:
		products = visitor.products.filter(name_en=product) # 取得用户有权限的业务列表
		if len(products) != 1:
			return HttpResponse('有访问权限但无产品，此种情况不应该存在')

		main_menus = visitor.main_menu.filter(product=product, is_sub_menu=False)		
		for main_menu in main_menus: # 用户有权限访问该目录
			data_rows = []
			for sub_menu in visitor.sub_menu.filter(product=product, is_sub_menu=True, menuid=main_menu):
				is_folder = sub_menu.is_sub_menu
				title = u'页面:%s' if not is_folder else u'目录:%s'
				row_dict = {
					"sub_title": title % sub_menu.name,
					"content_desc": u"昨天:%sw  前天:%sw  上周:%sw" % (_randnum(), _randnum(), _randnum()),
					"chart_type": CHART_TYPE[randint(0, 2)],
					"is_folder": 'true' if is_folder else 'false',
					"next_id": sub_menu.hash
				}
				data_rows.append(row_dict)
			section_dict = {
				"section_title": main_menu.name,
				"data_rows": data_rows
			}
			detail_list.append(section_dict)
	else:
		# demo 用户
		p = {
			"product"              : "demo", 
			"realtime_online_desc" : u"PCU  昨天:100w  前天:80w  上周:79.7w",
			"act_user_desc"        : u"昨天:95w  前天:83w  上周:79.7w",
			"new_user_desc"        : u"昨天:23w  前天:19w  上周:20.8w",
			"income_desc"          : u"昨天:23w  前天:19w  上周:20.8w"
		}
		detail_list.append(p)
	ctx = { "detail_list": detail_list }
	return render( request, 'mobioss_product_detail.json', ctx )
	

def product_menu_detail(request, rtx, product, menuid):
	""" /:rtx/:product/menu/:menuid
		根据 menuid 返回指定 product 的“二级目录”
	"""
	reqdata = request.GET if request.method == 'GET' else request.POST
	product = product.lower()
	print 'rtx:', rtx, 'product:', product
	menu_detail = []
	visitor = Visitor.find_rtx(rtx)
	if visitor is not None:
		products = visitor.products.filter(name_en=product)
		if len(products) != 1:
			# TODO 无此业务的权限
			return HttpResponse('无此业务的权限')
		
		menu = visitor.sub_menu.filter(product=product, hash=menuid)
		if len(menu) != 1:
			# TODO
			return HttpResponse('该业务对应的二级目录查找不存在')

		menu = menu[0]
		data_rows = []
		for page in Page.objects.filter(sub_menu=menu):		
			# print menu.name, page.name
			row_dict = {
				"sub_title": page.name,
				"content_desc": u"昨天:%sw  前天:%sw  上周:%sw" % (_randnum(), _randnum(), _randnum()),
				"chart_type": page.chart_type,
				"is_folder": 'false',
				"next_id": page.hash
			}
			data_rows.append(row_dict)
		section_dict = {
			"section_title": menu.name,
			"data_rows": data_rows
		}
		menu_detail.append(section_dict)
	else:
		# TODO demo 用户
		return HttpResponse('demo 用户')
	ctx = { "menu_detail": menu_detail }
	return render( request, 'mobioss_sub_menu_detail.json', ctx )


def product_page_detail(request, rtx, product, pageid):
	""" /:rtx/:product/page/:pageid
		根据 pageid 返回指定 product 的具体页面数据
	"""
	reqdata = request.GET if request.method == 'GET' else request.POST
	product = product.lower()
	print 'rtx:', rtx, 'product:', product

	plot = {}
	visitor = Visitor.find_rtx(rtx)
	if visitor is not None:
		products = visitor.products.filter(name_en=product)
		if len(products) != 1:
			# TODO 业务不存在
			return HttpResponse('业务不存在')

		page = Page.objects.filter(hash=pageid)
		if len(page) != 1:
			# TODO 页面不存在
			return HttpResponse('页面不存在')
		page = page[0]
		db = page.db
		# 查询得到图表信息
		# api = DBAPI(host=db.host, user=db.username, pwd=db.password, port=db.port, db=db.db)
		# result = api.select(page.detail_sql)
		# xlabels = []
		# identifiers = []
		# data_dict = {}

		# # NOTE，结果集的列顺序：type、横坐标、数值
		# x = 0
		# for row in result:
		# 	cols = row.split(',')
		# 	if cols[1] not in xlabels:
		# 		xlabels.append(cols[1])
		# 	item = { 'x': x, 'y': cols[2] }
		# 	if cols[0] in data_dict:
		# 		data_dict[cols[0]].append(item)
		# 	else:
		# 		data_dict[cols[0]] = [item]
		# 	x += 1
		# identifiers = data_dict.keys
		# numberOfPlots = len(data_dict)
		# numberOfRecords = x / numberOfPlots
		# # print 'data_dict', data_dict
		# print 'numberOfPlots', numberOfPlots, 'numberOfRecords', numberOfRecords, 'xlables: ', len(xlabels)
		# # print 'xlabels:\n', xlabels

		########### test ###########
		numberOfPlots = randint(1, 3)
		numberOfRecords = randint(8, 20)
		xlabels = []
		identifiers = []
		data_dict = {}
		# today = date.today()
		today = date(2013, 9, 1)

		for i in range(0, numberOfPlots):
			identifier = 'scatter%s' % i
			identifiers.append(identifier)
			data_dict.update( {identifier: []} )

		for i in range(0, numberOfRecords):
			xlabels.append((today + timedelta(days=i)).isoformat())

		for i in range(0, numberOfPlots):
			for j in range(0, numberOfRecords):
				# item = { 'x': j, 'y': j+1 } 							# 整数直线
				# item = { 'x': j, 'y': 8+(i-6)*(randint(0, 10)/10.0) } # 随机数
				item = { 'x': j, 'y': math.sin(j/math.pi)+i+1 } 		# 正弦函数
				data_dict[identifiers[i]].append( item )

		# print 'data_dict', data_dict
		# print 'numberOfPlots', numberOfPlots
		# print 'numberOfRecords', numberOfRecords
		# print 'xlables: ', len(xlabels), xlabels

		plot = {
			"number_of_plots"   : numberOfPlots,
			"number_of_records" : numberOfRecords,
			"plot_identifiers"  : identifiers,
			"x_labels"          : xlabels,
			"plot_data_source"  : data_dict
		}
	ctx = { 'plot': plot }
	return render( request, 'mobioss_plot_data.json', ctx )


