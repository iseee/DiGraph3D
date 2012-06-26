/*
 * Functions that interact with processing.js sketch
 */

var colorPicker = new Colorpicker();

/*
 * Generates the graph based on JSON data retrieved from remote server
 * Must use a callback, standard for JSONP, because we are accessing a
 * resource outside the current domain. Without JSONP, we will get 
 * Access-origin-policy errors when attempting to retrieve the data.
 */
function loadGraphFromRemote() {
	var pjs = Processing.getInstanceById('sketch');
	if(pjs != null) {
		var url = "http://localhost:2999/canadaenergy?callback=?";
		// jquery ajax call to getJSON, function is the callback on success
		jQuery.getJSON(url, function (data) {  
			console.log(data);
			var graphObj = pjs.getGraph();	
			var nodes = data.graph.nodes;
			for(i = 0; i < nodes.length; i++) {
				var node = nodes[i];
				graphObj.addNode(new pjs.Node(node.id, node.name, node.level));	
			}
			var arcs = data.graph.arcs;
			for(i = 0; i < arcs.length; i++) {
				var arc = arcs[i];
				graphObj.addArc(arc.srcid, arc.dstid, arc.flow, arc.futureflow);
			}
		});  
	}
	else
		setTimeout(loadGraphFromRemote, 255);
}

function rateSliderChanged(index, newValue) {
	var pjs = Processing.getInstanceById('sketch');
	pjs.updateArcRate(index, newValue);
}

function arcFlowSliderChanged(index, mult) {
	var pjs = Processing.getInstanceById('sketch');
	pjs.updateArcFlow(index, mult);
}

var bound = false;
function bindJavascript() {
	var pjs = Processing.getInstanceById('sketch');
	if(null!=pjs) {
		pjs.bindJavascript(this);
		bound = true;
	}
	if(!bound)
		setTimeout(bindJavascript, 250);
}

function displaySelectedNodeInfo(name, flow, carbonFactor, waterFactor) {
	html = "<b>"+name + "</b>: <i>TotalFlow</i>="+flow.toFixed(2)+" <i>CarbonEmissions</i>="+(flow*carbonFactor).toFixed(2)+" <i>WaterEmissions</i>="+(flow*waterFactor).toFixed(2);
	document.getElementById("selectedNode").innerHTML=html;
}

function clearNodeInfo() {
	document.getElementById("selectedNode").innerHTML="";
}

function timeSliderChanged(val) {
	var pjs = Processing.getInstanceById('sketch');
	pjs.updateArcLerps(val);
}

function changeColorScheme() {
	var pjs = Processing.getInstanceById('sketch');
	pjs.ColorScheme.changeColorScheme();
}

function resetNodePositions() {
	var pjs = Processing.getInstanceById('sketch');
	pjs.resetNodePositions();
}

function editCheckboxChange(checked) {
	var pjs = Processing.getInstanceById('sketch');
	pjs.setEditing(checked);
	// call jQuery explicity, rather than usual $ syntax, due to suspected namespace collision with rightjs
	jQuery('html, body').animate({
		scrollTop: jQuery("#editCheckBox").offset().top-50
	},5);
	jQuery('#editing-div').toggle();
}

function renderIndividualControls() {
	var pjs = Processing.getInstanceById('sketch');
	if(pjs != null) {
		var graph = pjs.getGraph();
		var arcs = graph.getArcsArray();
		var html = "<table>";
		for(i=0; i<arcs.length; i++) {
			html+="<tr>";
			html+="<td><span class='label'>Arc "+i+" Flow</span></td>";
  			html+="<td><input type='range' min='0' max='100' value='50' step='1' onchange='arcFlowSliderChanged("+i+",this.value/50)' /></td>";
			html+="</tr>";
		}
		html += "</table>";
	}
	else
		setTimeout(renderIndividualControls, 255);
}

function getColorPickerValue() {
	return colorPicker.toHex();	
}

function setColorPickerValue(val) {
	colorPicker.setValue(val);
}

function resetAllNodeColors() {
	var pjs = Processing.getInstanceById('sketch');
	pjs.resetAllNodeColors();
}

function resetSelectedNodeColor() {
	var pjs = Processing.getInstanceById('sketch');
	pjs.resetSelectedNodeColor();
}


window.onload = function loadScript() {
	bindJavascript();
	loadGraphFromRemote();
	colorPicker.insertTo('color-picker');
	jQuery('#editCheckBox').click(function(){
		editCheckboxChange(!$(this).hasClass('active')); 
	});
	jQuery("button[rel=tooltip]").tooltip();
//	renderIndividualControls();
}
