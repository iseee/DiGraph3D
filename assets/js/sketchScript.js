function rateSliderChanged(newValue) {
	var pjs = Processing.getInstanceById('sketch');
	pjs.updateRate(newValue);
}
