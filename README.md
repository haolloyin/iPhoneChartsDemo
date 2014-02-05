iPhoneChartsDemo
================

用 CorePlot 和 BeeFramework 在 iPhone 上画图表。  
Core Plot and BeeFramework demo project for making charts on iPhone.  
  

  
### 简介

只是一个尝试用 [Core Plot 2D图表库](https://github.com/core-plot/core-plot)（iOS版）和 [Bee-Framework](https://github.com/gavinkwoe/BeeFramework) 框架（0.4版本，最近更强大的0.5已发布）快速开发的一个原型，用于在 iPhone 上展示各个产品的运营情况（各种图表），基于某种考虑被老大拍死。

其实仅仅用到这两个框架极少的一点功能，其中只用 Core Plot 画了最简单的折线图、柱状图、饼图，几乎没有交互功能；Bee-Framework 也只是体验了用 CSS 语法进行 UI 布局，用 MVC 开发模式，用内置的 HTTP 接口。

P.S. 代码写得非常烂，因为 iOS 还没入门。 -_-#
  

### 运行

`server` 目录是基于 Python [Django 1.5](https://www.djangoproject.com) 的服务端，使用时在 `server` 目录下执行 `python manage.py runserver` 启动服务器。

在 Xcode 4.6.1 和 5.0.2 下用 iPhone iOS 6.1 模拟器编译运行。

server 返回的是个数不一定的随机数，可以在 `server/mobioss/views.py` 的 `product_page_detail` 函数进行修改，如下：

```python
for i in range(0, numberOfPlots):
    for j in range(0, numberOfRecords):
        # item = { 'x': j, 'y': j+1 }                           # 整数直线
        # item = { 'x': j, 'y': 8+(i-6)*(randint(0, 10)/10.0) } # 随机数
        item = { 'x': j, 'y': math.sin(j/math.pi)+i+1 }         # 正弦函数
        data_dict[identifiers[i]].append( item )
```  
  


GIF 图演示，12+ MB（GIFBrewery 生成的图太占空间），最好等它下载完再看：  
https://github.com/haolloyin/iPhoneChartsDemo/blob/master/demo_20140205.gif  

![demo-gif](https://github.com/haolloyin/iPhoneChartsDemo/blob/master/demo_20140205.gif?raw=true)  
  
