import json
import string


# level zero nodes
fuelNamesWithMap = [	('Uranium',['urainium']), # note urainium is mispelles in current csv files
							('Petroleum', ['crudeOil', 'refPetPrd', 'petroleum']),
							('Coal',['coal']),
							('Electricity', ['electricity']),
							('NaturalGas/NGL',['naturalGas', 'NGL']),
							('LiquidFuels',['hydrogen', 'otherLiqFuel']),
							('Biomass/other',['biomass', 'geoSteam', 'wind', 'solar']),
							('Hydro',['waterFall', 'waterTide', 'waterWave', 'inRiverFlow']) ]

def findMappedNode(csvName):
	for (node, list) in fuelNamesWithMap:
		for l in list:
			lLower = string.lower(l)
			csvLower = string.lower(csvName)
			if lLower == csvLower:
				return node
	print 'Could not find mapped node for %s' % csvName
	return ""



nodes = dict() 
arcs = list() 

# manually create the fuel nodes
for (fuel,list) in fuelNamesWithMap:
	nodes[fuel] = {'id':len(nodes), 'level':0}
# add the electricity node
nodes['Electricity']['level'] = 2
# modify fuels that have no disposition data, they well be level 1
nodes['Biomass/other']['level'] = 1 
nodes['Hydro']['level'] = 1

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
		nodes[useName] = {'id':len(nodes)+1, 'level':4}
	srcNode = findMappedNode(fuelName)
	if srcNode:
		arcs.append({ 'srcid':nodes[srcNode]['id'], 'dstid':nodes[useName]['id'], 'flow':[float(val)/1000 for val in split[2:]]})

finalDemandCsv.close()
print "done"


# read disposition data #
#print "reading fuelDisposition.csv"
#fuelDispositionCsv = open('fuelDisposition.csv', 'r')
#
#line = fuelDispositionCsv.readline()
#assert line == 'entity: /year\n', "entity is not correct in fuelDisposition.csv"
#line = fuelDispositionCsv.readline()
#assert line == 'unit of measure: petajoule\n', "unit of measure is not correct"
#line = fuelDispositionCsv.readline() # read header line
#
#for line in fuelDispositionCsv:
#	split = line.split(',')
#	fuelName = split[0].strip('"')
#	dispType = split[1].strip('"')
#	fuelNode = findMappedNode(fuelName)
#	if fuelNode:
#
#fuelDispositionCsv.close();
#print 'done'


# format data for export to json
data = {'graph':{'nodes':[{'name':name,'id':info.get('id'),'level':info.get('level')} for (name,info) in nodes.items()], 'arcs':arcs}}

# write to json file
jsonFile = open('../assets/json/historicalData.json', 'w')
json.dump(data, jsonFile, indent=3)
jsonFile.close()
print "historicalData.json successfully generated"






