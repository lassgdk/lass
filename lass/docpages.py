#!/usr/bin/env python

from __future__ import print_function
import os, jinja2, markdown
from lass import DIR_LASS_DATA

DIR_DOCS_SRC = os.path.join(DIR_LASS_DATA, "docs", "src")
env = jinja2.Environment(loader=jinja2.FileSystemLoader(os.path.join(DIR_DOCS_SRC, "templates")))

class Documentation(object):

	def __init__(self, views, data={}):
		self.views = views
		self.data = data

	@property
	def routes(self, views=None, routePrefix=""):

		routeList = []

		if not views:
			views = self.views

		for view in views:
			if view.get("pages"):
				routeList.append(routes(views=view, routePrefix=routePrefix+view.route))
			else:
				flattened.append(routePrefix + view.route)

"""
	fpr view in 
"""

def build():

	"""
	/getting-started
	/components
		/graphics
			/ShapeRenderer
	/scripting
		/basics
			/lua
			/lass-flavoured-lua
		/modules
			/lass
				/class
				/stdext
			/love

	"""