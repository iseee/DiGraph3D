import json

renewableElecCsv = open('elecGenRenewablesUranium.csv', 'r')

line = renewableElecCsv.readline()
assert line == 'entity: /year\n', "entity is not correct"
line = renewableElecCsv.readline()
assert line == 'unit of measure: petajoule\n', "unit of measure is not correct"
line = renewableElecCsv.readline()
assert line.split(',')[0] == 'renewables', "first row of table should start with renewables"

nodes = list() 
nodes.append({'name':'electricity', 'id':1, 'level':4})
arcs = list() 

for line in renewableElecCsv:
	split = line.split(',')
	name = split[0].strip('"')
	nodes.append({"name":name, "id":len(nodes)+1, "level":0})
	arcs.append({"srcid":len(nodes), "dstid":1, "flow":float(split[1]), "futureflow":float(split[len(split)-1])})

renewableElecCsv.close()


data = {'graph':{'nodes':nodes, 'arcs':arcs}}

jsonFile = open('../assets/json/historicalData.json', 'w')
json.dump(data, jsonFile, indent=3)
jsonFile.close()
