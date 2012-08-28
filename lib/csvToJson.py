import json
import string


# level zero nodes
fuelNamesWithMap = [	('Uranium',['urainium'], '#ff0000'), # note urainium is mispelled in current csv files
							('Crude Oil', ['crudeOil'] , '#ff00e0'),
							('RefinedPetrol', ['refPetPrd', 'petroleum'], '#dd00ff'),
							('Coal',['coal'], '#000000'),
							('Electricity', ['electricity'], '#bd6534'),
							('NaturalGas/NGL',['naturalGas', 'NGL'], '#5797c9'),
							('Biomass/other',['biomass', 'geoSteam', 'wind', 'solar', 'hydrogen', 'otherLiqFuel'], '#367a2d'),
							('Hydro',['waterFall', 'waterTide', 'waterWave', 'inRiverFlow'], '#5376b3') ]

def findMappedNode(csvName):
	csvLower = string.lower(csvName)
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

# for list representing history or flow between src and dst, increment every element
# of list by corresponding item in values
# src,dst string names of nodes
# values, list of string values to add
def accumulate(src,dst,values):
	toAdd = [float(val)/1000 for val in values]
	if arcTable[nodes[src]['id']][nodes[dst]['id']] is not None:
		arcTable[nodes[src]['id']][nodes[dst]['id']] = map(lambda a,b: a+b, arcTable[nodes[src]['id']][nodes[dst]['id']], toAdd)
	else:
		arcTable[nodes[src]['id']][nodes[dst]['id']] = toAdd 

nodes = dict() 
arcs = list() 

# initialize an 2d array, which will store cumulative flows between nodes, then arcs for each will 
# added at the end. This eliminates multiple arcs between same two nodes, which is not needed currently
arcTable = []
TABLE_DIM = 100
for i in range(TABLE_DIM):
	arcTable.append([None for k in range(TABLE_DIM)])

# manually create the fuel nodes
for (fuel,list,color) in fuelNamesWithMap:
	nodes[fuel] = {'id':len(nodes), 'level':1, 'color':color}
# add the electricity node
nodes['Electricity']['level'] = 6
nodes['RefinedPetrol']['level']= 4

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
		accumulate(node,'Electricity',split[1:])

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
		accumulate(node,'Electricity',split[1:])

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
		accumulate(srcNode,useName,split[2:])

finalDemandCsv.close()
print "done"


# read disposition data #
print "reading fuelDisposition.csv..."
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
	# create a unique dispNode for each fuel, ignore use for now
	# use special negative levels for the import, export, production nodes
	# production -1, import -2, export -3
	if fuelNode:
		if string.lower(dispType) == 'imports':
			dispNode = string.join([fuelName, ' Import'])
			if dispNode not in nodes:
				nodes[dispNode] = {'id':len(nodes)+1, 'level':-2, 'color':findMappedColor(fuelNode)}
			accumulate(dispNode,fuelNode,split[2:])
		elif string.lower(dispType) == 'production':
			dispNode = string.join([fuelName, ' Prod'])
			if dispNode not in nodes:
				# refined petroleum production is a special case. It is produced from crude oil
				if fuelName == 'refPetPrd':
					dispNode = 'Crude Oil'		
				else:
					nodes[dispNode] = {'id':len(nodes)+1, 'level':-1, 'color':findMappedColor(fuelNode)}
			accumulate(dispNode,fuelNode,split[2:])
		elif string.lower(dispType) == 'exports':
			dispNode = string.join([fuelName, ' Export'])
			if dispNode not in nodes:
				nodes[dispNode] = {'id':len(nodes)+1, 'level':-3, 'color':findMappedColor(fuelNode)}
			accumulate(fuelNode,dispNode,split[2:])

fuelDispositionCsv.close()
print 'done'

# create arcs from arcTable
for i in range(len(arcTable)):
	for j in range(len(arcTable[i])):
		list = arcTable[i][j]
		if list is not None:
			arcs.append( {'srcid':i, 'dstid':j, 'flow':list} )

# format data for export to json
data = {'graph':{'nodes':[{'name':name,'id':info.get('id'),'level':info.get('level'), 'color':info.get('color')} for (name,info) in nodes.items()], 'arcs':arcs}}

# write to json file
jsonFile = open('../assets/json/historicalData.json', 'w')
json.dump(data, jsonFile, indent=3)
jsonFile.close()
print "historicalData.json successfully generated"






