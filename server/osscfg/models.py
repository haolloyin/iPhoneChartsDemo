#coding=utf8

from django.db import models
from django.core.validators import URLValidator, validate_ipv4_address

import hashlib
from time import time
from random import randint

ALPHABET = 'abcdefghijklmnopqrstuvwxyz1234567890'

def randomStr():
	s = ''
	for i in range(11):
		s += ALPHABET[randint(0, 35)]
	return s

class Osser(models.Model):
	id = models.AutoField(primary_key=True)
	rtx = models.CharField(max_length=20, null=False, blank=False)
	name = models.CharField(max_length=20, null=True, blank=True, default='')
	leader = models.CharField(max_length=20, null=True, blank=True, default='')
	products = models.ManyToManyField('Product', null=True, blank=True, related_name='products')
	created_at = models.DateTimeField(auto_now_add=True)
	last_updated = models.DateTimeField(auto_now=True)

	def __unicode__(self):
		return u'[%s, %s, %s]' % (self.rtx, self.name, self.leader)

class Product(models.Model):
	id = models.AutoField(primary_key=True)
	name_en = models.CharField(max_length=20, null=False, blank=False, default='')
	name_cn = models.CharField(max_length=20, null=True, blank=True, default='')
	pm = models.ManyToManyField('Visitor', null=True, blank=True, related_name='visitor_pm')
	osser = models.ManyToManyField('Osser', null=True, blank=True, related_name='osser')
	studio_en = models.CharField(max_length=20, null=True, blank=True, default='')
	studio_cn = models.CharField(max_length=20, null=True, blank=True, default='')

	def __unicode__(self):
		return u'[%s, %s]' % (self.name_en, self.name_cn)

class DB(models.Model):
	id = models.AutoField(primary_key=True)
	name_en = models.CharField(max_length=10, null=True, blank=True)
	host = models.CharField(max_length=20, null=True, blank=True, validators=[validate_ipv4_address])
	db = models.CharField(max_length=20, null=True, blank=True)
	username = models.CharField(max_length=20, null=True, blank=True)
	password = models.CharField(max_length=20, null=True, blank=True)
	product = models.ForeignKey('Product', null=True, blank=True, related_name='db_product')
	port = models.CharField(max_length=10, null=True, blank=True, default='3306')

	def __unicode__(self):
		return u'[%s, %s, %s]' % (self.name_en, self.db, self.host)


class Menu(models.Model):
	id = models.AutoField(primary_key=True)
	product = models.CharField(max_length=50, null=False, blank=True, default='')
	name = models.CharField(max_length=50, null=True, blank=True, default='')
	hash = models.CharField(max_length=100, null=True, blank=True, default='', editable=True)
	order_id = models.IntegerField(max_length=5, null=True, blank=True, default=1)

	#is_sub_menu=True时，menuid 指向父目录（虽然是 m2m，但实际是 一对一），否则指向子目录（一对多）
	is_sub_menu = models.BooleanField(default=True)
	menuid = models.ManyToManyField('self', null=True, blank=True, default=None, related_name='menuid', 
		help_text='<b>is_sub_menu=True</b> 时,<b>menuid</b> 指向唯一父目录，否则指向子目录（一对多）<br>')

	is_visible = models.BooleanField(default=True)
	is_enabled = models.BooleanField(default=True)
	created_at = models.DateTimeField(auto_now_add=True)
	last_updated = models.DateTimeField(auto_now=True)

	class Meta:
		ordering = ['product', 'name', 'order_id', '-last_updated', 'id']
		unique_together = (('id', 'product', 'hash'))

	def __unicode__(self):
		return u'[%s, %s, %s>%s]' % (self.id, self.product, u'二级目录' if self.is_sub_menu else u'一级目录', self.name)

	def save(self, *args, **kwargs):
		super(Menu, self).save()
		if self.hash == '':
			tmp = '%s%s%s%s' % (self.id, self.product, str(time())[: -3], randomStr())
			hash = hashlib.new('md5', tmp).hexdigest()
			self.hash = hash
			super(Menu, self).save()

class Page(models.Model):
	id = models.AutoField(primary_key=True)
	product = models.CharField(max_length=100, null=False, blank=True, default='null')
	name = models.CharField(max_length=50, null=True, blank=True, default='')
	hash = models.CharField(max_length=100, null=False, blank=False, default='', editable=True)
	orderby = models.IntegerField(max_length=5, null=True, blank=True, default=1)
	chartTypeChoices = (
		('Scatter', '折线图'), ('Bar', '柱状图'), ('Pie', '饼图'),
	)
	chart_type = models.CharField(max_length=20, null=True, blank=True, choices=chartTypeChoices, default='Scatter')
	desc_sql = models.TextField(max_length=500, null=False, blank=True, default='')
	detail_sql = models.TextField(max_length=500, null=False, blank=True, default='')

	main_menu = models.ForeignKey(Menu, null=True, blank=True, related_name='page_main_menu')
	sub_menu = models.ForeignKey(Menu, null=True, blank=True, related_name='page_sub_menu')
	db = models.ForeignKey(DB, null=True, blank=True, related_name='page_db')

	is_visible = models.BooleanField(default=True)
	is_enabled = models.BooleanField(default=True)
	created_at = models.DateTimeField(auto_now_add=True)
	last_updated = models.DateTimeField(auto_now=True)

	class Meta:
		ordering = ['product', 'name', 'orderby', '-last_updated', 'id']
		unique_together = (('id', 'product', 'hash'))

	def __unicode__(self):
		main_menu = '' if self.main_menu == None else self.main_menu.name
		sub_menu = '' if self.sub_menu == None else self.sub_menu.name
		return u'[%s, %s, %s, %s>%s>%s]' % (self.id, self.product, self.chart_type, main_menu, sub_menu, self.name)

	def save(self, *args, **kwargs):
		super(Page, self).save()
		if self.hash == '':
			tmp = '%s%s%s%s' % (self.id, self.product, str(time())[: -3], randomStr())
			hash = hashlib.new('md5', tmp).hexdigest()
			self.hash = hash
			super(Page, self).save()

class Visitor(models.Model):
	id = models.AutoField(primary_key=True)
	rtx = models.CharField(max_length=20, null=False, blank=False)
	name = models.CharField(max_length=20, null=True, blank=True, default='')
	leader = models.CharField(max_length=20, default='null', null=True, blank=True)

	products = models.ManyToManyField('Product', null=True, blank=True, related_name='visitor_products')
	main_menu = models.ManyToManyField(Menu, null=True, blank=True, related_name='visitor_main_menu')
	sub_menu = models.ManyToManyField(Menu, null=True, blank=True, related_name='visitor_sub_menu')

	created_at = models.DateTimeField(auto_now_add=True)
	last_updated = models.DateTimeField(auto_now=True)

	class Meta:
		ordering = ['rtx', '-last_updated', 'id']
		unique_together = (('id', 'rtx'))

	def __unicode__(self):
		return '[id:%s, %s, %s]' % (self.id, self.rtx, self.name)

	@classmethod
	def find_rtx(cls, rtx):
		v = Visitor.objects.filter(rtx=rtx)
		return v[0] if len(v) == 1 else None



			





