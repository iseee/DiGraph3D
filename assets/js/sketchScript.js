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
bindJavascript();

function displaySelectedNodeInfo(name, flow) {
	document.getElementById("selectedNode").innerHTML=name+": "+flow.toFixed(2);
}

function timeSliderChanged(val) {
	var pjs = Processing.getInstanceById('sketch');
	pjs.updateArcLerps(val);
}
