#coding=utf8

try:
	import MySQLdb
except:
	pass
from datetime import datetime, date

def flatten_list(result=[]):
	'''将给定的查询结果(两列：中文,数值)打平为一行字符串
	'''
	assert(isinstance(result, list))
	result_str = ' '.join([ '%s:%.1f' % (row[0], row[1]) for row in result ])
	return result_str

def time_format(dt):
	'''时间格式化，转为 str 类型，如果不是 datetime 实例，直接返回其 str
	'''
	if isinstance(dt, datetime):
		dt = dt.strftime('%Y-%m-%d %H:%M:%S')
	elif isinstance(dt, date):
		dt = dt.strftime('%Y-%m-%d')
	else:
		dt = str(dt)
	return dt

class DBAPI(object):
	def __init__(self, host='127.0.0.1', user='root', pwd='root', port=3306, db='dbCrossOssResult', charset='utf8'):
		self.host = host
		self.user = user
		self.pwd = pwd
		self.db = db
		self.charset = charset

	def select(self, sql, flatten=False):
		conn = None
		cursor = None
		try:
			conn = MySQLdb.connect(host=self.host, user=self.user, passwd=self.pwd, db=self.db, charset=self.charset)
			cursor = conn.cursor()
			row_num = cursor.execute(sql)
			if not flatten:
				result = []
				for row in cursor.fetchall():
					line = []
					for col in row:
						line.append(time_format(col))
					result.append(','.join(line))
				return result
			else:
				return flatten_list(cursor.fetchall())	# 将查询结果打平成一个字符串
		except Exception, e:
			print 'select error:', e
		finally:
			cursor.close()
			conn.close()


if '__main__' == __name__:
	api = DBAPI(pwd='root', db='mobioss')
	sql = 'select * from tbRealOnline order by dtStatTime desc limi 10'
	rs = api.select(sql)
