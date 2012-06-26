import json

nodes = dict() 
nodes['electricity'] = {'id':1, 'level':2}
arcs = list() 


print "reading elecGenRenewablesUranium.csv..." 
renewableElecCsv = open('elecGenRenewablesUranium.csv', 'r')

line = renewableElecCsv.readline()
assert line == 'entity: /year\n', "entity is not correct in elecGenRenewablesUranium.csv"
line = renewableElecCsv.readline()
assert line == 'unit of measure: petajoule\n', "unit of measure is not correct"
line = renewableElecCsv.readline()
assert line.split(',')[0] == 'renewables', "first row of table should start with renewables"

for line in renewableElecCsv:
	split = line.split(',')
	name = split[0].strip('"')
	nodes[name]={"id":len(nodes)+1, "level":0}
	arcs.append({"srcid":len(nodes), "dstid":1, "flow":(float(split[1])/1000), "futureflow":(float(split[len(split)-1])/1000)})

renewableElecCsv.close()
print "done"


print "reading finalDemand.csv..."
finalDemandCsv = open('finalDemand.csv', 'r')

line = finalDemandCsv.readline()
assert line == 'entity: /year\n', "entity is not correct in finalDemand.csv"
line = finalDemandCsv.readline()
assert line == 'unit of measure: petajoule\n', "unit of measure is not correct"
line = finalDemandCsv.readline() # read header line

for line in finalDemandCsv:
	split = line.split(',')
	useName = split[0].strip('"')
	fuelName = split[1].strip('"')
	if useName not in nodes:
		nodes[useName] = {'id':len(nodes)+1, 'level':4}
	if fuelName not in nodes:
		nodes[fuelName] = {'id':len(nodes)+1, 'level':0}
	arcs.append({ 'srcid':nodes.get(fuelName).get('id'), 'dstid':nodes.get(useName).get('id'), 'flow':(float(split[2])/1000), 'futureflow':(float(split[len(split)-1])/1000)})


finalDemandCsv.close()
print "done"


# format data for export to json
data = {'graph':{'nodes':[{'name':name,'id':info.get('id'),'level':info.get('level')} for (name,info) in nodes.items()], 'arcs':arcs}}

# write to json file
jsonFile = open('../assets/json/historicalData.json', 'w')
json.dump(data, jsonFile, indent=3)
jsonFile.close()
print "historicalData.json successfully generated"
