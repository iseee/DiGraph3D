import json
import string


# level zero nodes
fuelNamesWithMap = [	('Uranium',['urainium'], '#ff0000'), # note urainium is mispelled in current csv files
							('Petroleum', ['crudeOil', 'refPetPrd', 'petroleum'], '#ff00e0'),
							('Coal',['coal'], '#000000'),
							('Electricity', ['electricity'], '#bd6534'),
							('NaturalGas/NGL',['naturalGas', 'NGL'], '#5797c9'),
							('Biomass/other',['biomass', 'geoSteam', 'wind', 'solar'], '#367a2d'),
							('Hydro',['waterFall', 'waterTide', 'waterWave', 'inRiverFlow'], '#5376b3') ]

def findMappedNode(csvName):
	csvLower = string.lower(csvName)
	if csvLower == 'hydrogen' or csvLower == 'otherliqfuel':
		return ""
	for (node, list, color) in fuelNamesWithMap:
		for l in list:
			lLower = string.lower(l)
			if lLower == csvLower:
				return node
	print 'Could not find mapped node for %s' % csvName
	return ""

def findMappedColor(nodeName):
	for (node, list, color) in fuelNamesWithMap:
		lower = string.lower(node).strip()
		nodeNameLower = string.lower(nodeName).strip()
		if lower == nodeNameLower:
				return color
	print 'Could not find mapped color for %s' % nodeName
	return "" 




nodes = dict() 
arcs = list() 

# manually create the fuel nodes
for (fuel,list,color) in fuelNamesWithMap:
	nodes[fuel] = {'id':len(nodes), 'level':1, 'color':color}
# add the electricity node
nodes['Electricity']['level'] = 6
# modify fuels that have no disposition data
nodes['Biomass/other']['level'] = 4 
nodes['Hydro']['level'] = 4

# read and interpret data, by assigning arcs between the fuel nodes and electricity nodes
# there are two csv files with the elec gen data
print "reading elecGenRenewablesUranium.csv..." 
renewableElecCsv = open('elecGenRenewablesUranium.csv', 'r')

# some crappy file verification
line = renewableElecCsv.readline()
assert line == 'entity: /year\n', "entity is not correct in elecGenRenewablesUranium.csv"
line = renewableElecCsv.readline()
assert line == 'unit of measure: petajoule\n', "unit of measure is not correct"
line = renewableElecCsv.readline()
assert line.split(',')[0] == 'renewables', "first row of table should start with renewables"

# read actual data
for line in renewableElecCsv:
	split = line.split(',')
	csvName = split[0].strip('"')
	# find correct node to assign data to
	node = findMappedNode(csvName)
	if node: 
		arcs.append({"srcid":nodes[node]['id'], "dstid":nodes['Electricity']['id'], "flow":[float(val)/1000 for val in split[1:]]})

renewableElecCsv.close()
print "done"


print 'reading fuelUsedElecGen.csv'
fuelUsedElecGenCsv = open('fuelUsedElecGen.csv', 'r')

line = fuelUsedElecGenCsv.readline()
assert line == 'entity: /year\n', "entity is not correct"
line = fuelUsedElecGenCsv.readline()
assert line == 'unit of measure: petajoule\n', "unit of measure is not correct"
line = fuelUsedElecGenCsv.readline()

for line in fuelUsedElecGenCsv:
	split = line.split(',')
	csvName = split[0].strip('"')
	# find correct node to assign data to
	node = findMappedNode(csvName)
	if node: 
		arcs.append({"srcid":nodes[node]['id'], "dstid":nodes['Electricity']['id'], "flow":[float(val)/1000 for val in split[1:]]})

fuelUsedElecGenCsv.close()
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
		nodes[useName] = {'id':len(nodes)+1, 'level':9}
	srcNode = findMappedNode(fuelName)
	if srcNode:
		arcs.append({ 'srcid':nodes[srcNode]['id'], 'dstid':nodes[useName]['id'], 'flow':[float(val)/1000 for val in split[2:]]})

finalDemandCsv.close()
print "done"


# read disposition data #
print "reading fuelDisposition.csv..."
print "We intentionally ignore hydrogen and otherLiqFuels, they are insignificantly small amounts"
fuelDispositionCsv = open('fuelDisposition.csv', 'r')

line = fuelDispositionCsv.readline()
assert line == 'entity: /year\n', "entity is not correct in fuelDisposition.csv"
line = fuelDispositionCsv.readline()
assert line == 'unit of measure: petajoule\n', "unit of measure is not correct"
line = fuelDispositionCsv.readline() # read header line

for line in fuelDispositionCsv:
	split = line.split(',')
	fuelName = split[0].strip('"')
	dispType = split[1].strip('"')
	fuelNode = findMappedNode(fuelName)
	# create a unique dispNode for each fuel, put production and import in level 0, export in level 4, ignore use
	if fuelNode:
		if string.lower(dispType) == 'imports':
			dispNode = string.join([fuelName, ' Import'])
			if dispNode not in nodes:
				nodes[dispNode] = {'id':len(nodes)+1, 'level':-2, 'color':findMappedColor(fuelNode)}
			arcs.append( {'srcid':nodes[dispNode]['id'], 'dstid':nodes[fuelNode]['id'], 'flow':[float(val)/1000 for val in split[2:]] } )
		elif string.lower(dispType) == 'production':
			dispNode = string.join([fuelName, ' Prod'])
			if dispNode not in nodes:
				nodes[dispNode] = {'id':len(nodes)+1, 'level':-1, 'color':findMappedColor(fuelNode)}
			arcs.append( {'srcid':nodes[dispNode]['id'], 'dstid':nodes[fuelNode]['id'], 'flow':[float(val)/1000 for val in split[2:]] } )
		elif string.lower(dispType) == 'exports':
			dispNode = string.join([fuelName, ' Export'])
			if dispNode not in nodes:
				nodes[dispNode] = {'id':len(nodes)+1, 'level':-3, 'color':findMappedColor(fuelNode)}
			arcs.append( {'srcid':nodes[fuelNode]['id'], 'dstid':nodes[dispNode]['id'], 'flow':[float(val)/1000 for val in split[2:]] } )

fuelDispositionCsv.close()
print 'done'


# format data for export to json
data = {'graph':{'nodes':[{'name':name,'id':info.get('id'),'level':info.get('level'), 'color':info.get('color')} for (name,info) in nodes.items()], 'arcs':arcs}}

# write to json file
jsonFile = open('../assets/json/historicalData.json', 'w')
json.dump(data, jsonFile, indent=3)
jsonFile.close()
print "historicalData.json successfully generated"






