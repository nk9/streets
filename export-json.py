#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import json
import MySQLdb

def main():
		exporter = Exporter()


class Exporter(object):
	def __init__(self):
		self.db = None
		self.dbName = ""
		self.data = {}

		self.startDB()
		
		self.populateStreets()
		self.populateEntites()
		self.populateNeighborhoods()
		self.populateBrowseList()
	
		print json.dumps(self.data) #, sort_keys=True, indent=4, separators=(',', ': '))


	def populateStreets(self):
		streets = {}
	
		cur = self.db.cursor()

		cur.execute("SELECT `ITEM_ID`,TRIM(`NAME`),STREET_LEVEL,POLYLINE,NUM_WAYS FROM `" + self.dbName + "`.`STREET_DETAILS`")

		for i in range(cur.rowcount):
			row = cur.fetchone()
			street = {}

			street_id = str(row[0])
			
			street["name"] = str(row[1])
			street["weight"] = int(row[2])
			street["polygon"] = 0
			street["polyline"] = json.loads(str(row[3]))
			street["dimensions"] = 2 if (int(row[4]) == 1) else 3
			street["history"] = ""
			street["image"] = ""
			street["link"] = ""
			street["entityIds"] = "1"
			street["themes"] = ["Islingtonians"]

			streets[street_id] = street

		self.data["streets"] = streets


	def populateEntites(self):
		self.data["entities"] = {1: {"name": "Joseph Islington", "desc": "The first Islingtonian", "image": "", "link": ""}}


	def populateNeighborhoods(self):
		self.data["neighborhoods"] = {"Mildmay": {"name": "Mildmay", "history": "Where Tom lives", "image": "", "link": "", "entityIds": "", "themes": ["Islingtonians"]}}

	def populateBrowseList(self):
		self.data["browseList"] = ["1"]


	def startDB(self):
		if len(sys.argv) < 4:
			print "Invalid syntax, need DB user, DB password, and DB name"
			sys.exit(1)
		else:
			db_user = sys.argv[1]
			db_password = sys.argv[2]
			
			self.dbName = sys.argv[3]
			
			self.db = MySQLdb.connect(host="localhost", user=db_user, passwd=db_password, db=self.dbName)


# Default function is main()
if __name__ == '__main__':
	main()