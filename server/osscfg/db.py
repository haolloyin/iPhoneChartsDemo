#coding=utf8

from random import randint
from osscfg.models import *

alphabet = 'abcdefghijklmnopqrstuvwxyz'
main_menus = ['用户类', '有效用户类', '在线类', '收入类', '特性']
page_name = ['']


def random_rtx():
	name = ''
	for i in range(1, randint(3, 6)):
		name += alphabet[randint(0, 25)]
	return name

def clean():
	Page.objects.all().delete()
	Menu.objects.all().delete()
	Visitor.objects.all().delete()
	DB.objects.all().delete()
	Product.objects.all().delete()
	Osser.objects.all().delete()

def init():
	# 初始化实际可用的配置信息
	osser = Osser(rtx='ihaoli')
	osser.save()

	p1 = Product(name_en='qt', name_cn='QT语音')
	p1.save()
	p1.osser.add(osser)

	p2 = Product(name_en='cross', name_cn='Cross')
	p2.save()
	p2.osser.add(osser)

	m1 = Menu(product='cross', name='实时在线', is_sub_menu=True)	
	m1.save()
	m2 = Menu(product='cross', name='历史在线', is_sub_menu=True)
	m2.save()
	m4 = Menu(product='cross', name='服务器容量', is_sub_menu=True)
	m4.save()

	m3 = Menu(product='cross', name='在线类', is_sub_menu=False)
	m3.save()
	m3.menuid.add(m1)
	m3.menuid.add(m2)
	m3.menuid.add(m4)
	m3.save()

	m1.menuid.add(m3)
	m1.save()
	m2.menuid.add(m3)
	m2.save()
	m4.menuid.add(m3)
	m4.save()

	db1 = DB()
	db1.name_en = 'cross'
	db1.host = '127.0.0.1'
	db1.db = 'dbCrossOssResult'
	db1.username = 'root'
	db1.password = 'root'
	db1.product = p2
	db1.save()

	db2 = DB()
	db2.name_en = 'cross'
	db2.host = '10.157.96.15'
	db2.db = 'dbCrossOssResult'
	db2.username = 'cross_oss'
	db2.password = 'cross#2012'
	db2.product = p2
	db2.save()

	page1 = Page(product='cross', name='各大区实时在线（server）')
	page1.db = db2
	page1.main_menu = m3
	page1.sub_menu = m1
	page1.detail_sql = '''
SELECT vGameName, dtStatTime , iUserNum FROM (     
  SELECT DISTINCT DATE_FORMAT(dtStatTime,'%Y-%m-%d %H:%i:00') AS dtStatTime, iUserNum, b.vGameName     
  FROM tbRealOnline a LEFT JOIN dbOssConf.tbGameIdConf b ON a.iChannelId=b.iGameId 
  WHERE dtStatTime BETWEEN '2013-10-08 22:00:00' AND '2013-10-08 23:59:59' AND DATE_FORMAT(dtStatTime,'%i')%10=0
      AND a.iChannelId IN (1, 2103041, 2104833)
  GROUP BY dtStatTime, a.iChannelId 
) ta 
ORDER BY dtStatTime, vGameName	
	'''
	page1.chart_type = 'Scatter'
	page1.save()

	page2 = Page(product='cross', name='最高在线和平均在线（local）')
	page2.db = db1
	page2.chart_type = 'Bar'
	page2.main_menu = m3
	page2.sub_menu = m2
	page2.detail_sql = '''
SELECT vGameName, dtStatTime , iUserNum FROM (     
  SELECT DISTINCT DATE_FORMAT(dtStatTime,'%Y-%m-%d %H:%i:00') AS dtStatTime, iUserNum, b.vGameName     
  FROM tbRealOnline a LEFT JOIN dbOssConf.tbGameIdConf b ON a.iChannelId=b.iGameId 
  WHERE dtStatTime BETWEEN '2013-10-08 23:00:00' AND '2013-10-08 23:59:59' AND DATE_FORMAT(dtStatTime,'%i')%10=0
      AND a.iChannelId IN (1, 2103041)
  GROUP BY dtStatTime, a.iChannelId 
) ta 
ORDER BY dtStatTime, vGameName
	'''
	page2.save()

	page3 = Page(product='cross', name='实时有效在线（local）')
	page3.db = db1
	page3.main_menu = m3
	page3.sub_menu = m1
	page3.chart_type = 'Bar'
	page3.detail_sql = '''
SELECT vGameName, dtStatTime , iUserNum FROM (     
  SELECT DISTINCT DATE_FORMAT(dtStatTime,'%Y-%m-%d %H:%i:00') AS dtStatTime, iUserNum, b.vGameName     
  FROM tbRealOnline a LEFT JOIN dbOssConf.tbGameIdConf b ON a.iChannelId=b.iGameId 
  WHERE dtStatTime BETWEEN '2013-10-08 20:00:00' AND '2013-10-08 23:59:59' AND DATE_FORMAT(dtStatTime,'%i')%10=0
      AND a.iChannelId IN (1, 2103041, 2104833)
  GROUP BY dtStatTime, a.iChannelId 
) ta 
ORDER BY dtStatTime, vGameName
	'''
	page3.save()

	page4 = Page(product='cross', name='固定房间实时在线（local）')
	page4.db = db1
	page4.main_menu = m3
	page4.sub_menu = m1
	page4.chart_type = 'Pie'
	page4.detail_sql = '''
SELECT dtStatTime, vGameName, iUserNum FROM (     
  SELECT DISTINCT DATE_FORMAT(dtStatTime,'%Y-%m-%d %H:%i:00') AS dtStatTime, iUserNum, b.vGameName     
  FROM tbRealOnline a LEFT JOIN dbOssConf.tbGameIdConf b ON a.iChannelId=b.iGameId 
  WHERE dtStatTime='2013-10-08 20:00:00'  AND DATE_FORMAT(dtStatTime,'%i')%10=0
      AND a.iChannelId IN (1, 2103041, 2104833)
  GROUP BY dtStatTime, a.iChannelId 
) ta 
order by dtStatTime, vGameName
	'''
	page4.save()

	page5 = Page(product='cross', name='主动/被动PCU（server）')
	page5.db = db2
	page5.main_menu = m3
	page5.sub_menu = m2
	page5.chart_type = 'Bar'
	page5.detail_sql = '''
SELECT dtStatTime, vGameName, iUserNum FROM (     
  SELECT DISTINCT DATE_FORMAT(dtStatTime,'%Y-%m-%d %H:%i:00') AS dtStatTime, iUserNum, b.vGameName     
  FROM tbRealOnline a LEFT JOIN dbOssConf.tbGameIdConf b ON a.iChannelId=b.iGameId 
  WHERE dtStatTime='2013-10-08 21:00:00'  AND DATE_FORMAT(dtStatTime,'%i')%10=0
      AND a.iChannelId IN (1, 2103041, 2104833)
  GROUP BY dtStatTime, a.iChannelId 
) ta 
order by dtStatTime, vGameName
	'''
	page5.save()

	page6 = Page(product='cross', name='各房间模式PCU（server）')
	page6.db = db2
	page6.main_menu = m3
	page6.sub_menu = m2
	page6.chart_type = 'Scatter'
	page6.detail_sql = '''
SELECT vGameName, dtStatTime , iUserNum FROM (     
  SELECT DISTINCT DATE_FORMAT(dtStatTime,'%Y-%m-%d %H:%i:00') AS dtStatTime, iUserNum, b.vGameName     
  FROM tbRealOnline a LEFT JOIN dbOssConf.tbGameIdConf b ON a.iChannelId=b.iGameId 
  WHERE dtStatTime BETWEEN '2013-10-08 12:00:00' AND '2013-10-08 23:59:59' AND DATE_FORMAT(dtStatTime,'%i')%10=0
      AND a.iChannelId IN (1, 2103041)
  GROUP BY dtStatTime, a.iChannelId 
) ta 
ORDER BY dtStatTime, vGameName
	'''
	page6.save()

	v = Visitor(rtx='ihaoli', name='码农一号')
	v.save()
	v.products.add(p1)
	v.products.add(p2)
	v.main_menu.add(m3)
	v.sub_menu.add(m1)
	v.sub_menu.add(m2)
	v.sub_menu.add(m4)
	

if '__main__' == __name__:
	db_init()
