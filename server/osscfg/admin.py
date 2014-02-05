#coding=utf8

from django.contrib import admin

from osscfg.models import Visitor, Menu, Page, Osser, Product, DB

class ProductAdmin(admin.ModelAdmin):
	search_fields = ('pm', 'osser')
	filter_horizontal = ['pm', 'osser']

class VisitorAdmin(admin.ModelAdmin):
	search_fields = ('products', 'main_menu', 'sub_menu')
	filter_horizontal = ['products', 'main_menu', 'sub_menu']

class OsserAdmin(admin.ModelAdmin):
	filter_horizontal = ['products']

class MenuAdmin(admin.ModelAdmin):
	search_fields = ('product', 'name')
	filter_horizontal = ['menuid']
	readonly_fields = ('hash',)

class PageAdmin(admin.ModelAdmin):
	search_fields = ('product', 'name')
	readonly_fields = ('hash',)

admin.site.register(Visitor, VisitorAdmin)
admin.site.register(Osser, OsserAdmin)
admin.site.register(Product, ProductAdmin)
admin.site.register(Menu, MenuAdmin)
admin.site.register(Page, PageAdmin)
admin.site.register(DB)
