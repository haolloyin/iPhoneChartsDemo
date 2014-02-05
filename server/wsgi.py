#coding=utf8

import os
import sys

reload(sys)
sys.setdefaultencoding('utf8')

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "server.settings")

from django.core.handlers.wsgi import WSGIHandler
application = WSGIHandler()

