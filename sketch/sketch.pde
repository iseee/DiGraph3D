int WIDTH = 1200;
int HEIGHT = 800;
int SCALE = 10;		// used throughout to scale the visualization, ie the flow may be 2.5, but the arc will be drawn scale*2.5
int TEXT_Z = 50; 
color BG_COLOR = #000000;
color TEXT_COLOR = #FFFFFF;
boolean EDITING = false;
boolean SOME_NODE_SELECTED = false;
int BAND_STEPS = 300;
int PAN_DELTA = 10;

int PRODUCTION_NODE_LEVEL = -1;
int IMPORT_NODE_LEVEL = -2;
int EXPORT_NODE_LEVEL = -3;

int lastMouseX = 0;
int lastMouseY = 0;
int x_rotation = 0;
int y_rotation = 0;
int zoom = 0;
int panX = 0;
int panY = 0;

PFont font;
Graph _graph;

JavaScript js;

/*
 * This allows the sketch to call external javascript functions, so it can interact with the page.
 * You just prototype the function here in the interface. Then as long as this function is defined 
 * somewhere in your js, you can call it straight from processing code.
 */
interface JavaScript {
	void displaySelectedNodeInfo(Node node);	
	void clearNodeInfo();
	String getColorPickerValue();
	void setColorPickerValue(String val);
	int getTimelineYear();
	void setTimelineYear(int year);
}

/*
 * This is called from javascript on pageload. The js passes a reference to itself to the processing
 * code using this function, allowing use of the interface above.
 */
void bindJavascript(JavaScript jscript) {
	js = jscript;
}


void setup() {
	size(WIDTH, HEIGHT, P3D);
	font = createFont("Arial", 10);
	sphereDetail(15);
	_graph = new Graph(); 
}

void draw() {
	ambientLight(255,255,255);
	background(ColorScheme.getBgColor());

	float cameraY = HEIGHT/2.0;
	float fov = PI/3.0;
	float cameraZ = cameraY / tan(fov / 2.0);
	float aspect = float(WIDTH)/float(HEIGHT);
	perspective(fov, aspect, cameraZ/10.0, cameraZ*10.0);
	translate(WIDTH/2, HEIGHT/2, 0);

	rotateX(x_rotation * PI/500);
	rotateY(y_rotation * PI/500);
	translate(panX,panY, zoom);

	if(null != _graph)
		_graph.draw();
	else {
		text("No data yet!", 0, 0);
	}
}

void mousePressed() {
	setLastMouse();
	if(EDITING) {

		Iterator it = _graph.getNodes().iterator();
		Node n = null;
		boolean nodeSelected = false;
		while(it.hasNext()) {
			n = (Node) it.next();
			if(n.isSelected) {
				// colorpicker needs the # to preface the hex string
				js.setColorPickerValue("#"+hex(n.nodeBaseColor,6));
				n.toggleEditing();	
				nodeSelected = true;
			}
			else {
				// ensure only one node selected at one time
				if(n.selectedForEditing)
					n.toggleEditing();
			}
		}
			it = _graph.getArcs().iterator();
			Arc a = null;
			boolean arcSelected = false; // avoid overlapping arcs being simultaneously selected
			while(it.hasNext()) {
				a = (Arc) it.next();
				//println("checking between "+a.source.name+" and "+a.dest.name); 
				if(a.selected() && !nodeSelected && !arcSelected) {
					a.toggleEditing();
					arcSelected = true;
				}
				else {
					if(a.selectedForEditing)
						a.toggleEditing();
				}
			}

	} // editing
}

void setLastMouse() {
	lastMouseX = mouseX;
	lastMouseY = mouseY;
}

float dragLength() {
	return sqrt( pow(mouseX-lastMouseX,2) + pow(mouseY-lastMouseY,2) );
}

void mouseDragged() {
	if(EDITING) {
		boolean movingNode = false;
		Iterator it = _graph.getNodes().iterator();
		Node n = null;
		while(it.hasNext()) {
			n = (Node) it.next();
			if(n.isSelected) {
				movingNode = true;
				break;
			}
		}
		if(movingNode && null != n) {
			n.moveByDelta(mouseX-pmouseX, mouseY-pmouseY);
		}
	}
	else {
		if(dragLength() > 10)
			setLastMouse();
		y_rotation += (mouseX-lastMouseX);
		x_rotation += (lastMouseY-mouseY);
	}
}

void updateArcRate(int arcIndex, float rate) {
	if(null != _graph)
		_graph.updateArcRate(arcIndex, rate);
}

void updateArcFlow(int arcIndex, float multiplier){
	if(null != _graph)
		_graph.updateArcFlow(arcIndex, multiplier);
}

void keyPressed() {
	if(key == 'r' || key == 'R')
		resetRotation();
	else if(key == ',')
		zoomOut();
	else if(key == '.')
		zoomIn();
	else if(key == CODED) {
		if(keyCode == UP) 
			pan(0,PAN_DELTA);
		else if(keyCode == DOWN)
			pan(0,-PAN_DELTA);
		else if(keyCode == LEFT)
			pan(PAN_DELTA,0);
		else if(keyCode == RIGHT)
			pan(-PAN_DELTA,0);
	}
}

void resetRotation() {
	x_rotation = 0;
	y_rotation = 0;
}

Graph getGraph() {
	return _graph;
}


/*
 * Bound param between 0 and 1
 */
float boundParam(float param) {
	if(param < 0)
		return 0;
	if(param > 1)
		return 1;
	return param;
}

/*
 * Allows user to reset node positions to original
 */
void resetNodePositions() {
	_graph.updateNodePositions();
}

void setEditing(boolean state) {
	EDITING = state;
}

void resetAllNodeColors() {
	Iterator it = _graph.getNodes().iterator();
	Node n = null;
	while(it.hasNext()) {
		n = (Node) it.next();
		n.nodeCurrentColor = n.nodeBaseColor;
	}
	js.setColorPickerValue("#"+hex(n.nodeCurrentColor,6));
}

void resetSelectedNodeColor() {
	Iterator it = _graph.getNodes().iterator();
	Node n = null;
	while(it.hasNext()) {
		n = (Node) it.next();
		if(n.selectedForEditing) {
			n.nodeCurrentColor = n.nodeBaseColor;
			js.setColorPickerValue("#"+hex(n.nodeCurrentColor,6));
			break;
		}
	}
}

void zoomIn() {
	zoom += 10;
}

void zoomOut() {
	zoom -= 10;
}

void pan(int dx, int dy) {
	panX += dx;
	panY += dy;
}

static class ColorScheme {

	final static color BG_COLOR_DARK = #000000; 	// black
	final static color BG_COLOR_LIGHT = 245; 		// off white

	final static color TEXT_COLOR_DARK = #FFFFFF;
	final static color TEXT_COLOR_LIGHT = #000000;

	// color(gray, alpha) cannot be used in static context, so use hex notation 0xARGB
	final static color CARBON_BUBBLE_COLOR_DARK = 0x32e6e6e6; // equiv to color(230,50);
	final static color CARBON_BUBBLE_COLOR_LIGHT = 0x64323232; // equiv to color(50,100);
	final static color WATER_DROPLET_COLOR = 0x640000ff; // equiv to color(0,0,255,100);

	final static color EDITING_COLOR_DARK = #f8f800;
	final static color EDITING_COLOR_LIGHT = #f8f800;

	final static color NODE_BASE_COLOR = 0xffff0000;


	/*
	 * Processing doesn't seem to currently support enums, so for the dark/light scheme we just
	 * hack using ints for now, 0=dark, 1=light
	 */
	static int currentScheme = 1;

	static void changeColorScheme() {
		if(currentScheme == 0)
			currentScheme = 1;
		else
			currentScheme = 0;
	}

	/*
	 * Common if statement when querying for scheme dependant color.
	 * @params darkSchemeColor: color to be returned if currently using dark scheme
	 *	        lightSchemeColor: color to be returned if currently using light scheme
	 */
	static color getColorBasedOnScheme(color darkSchemeColor, color lightSchemeColor) {
		if(currentScheme == 0)
			return darkSchemeColor;
		if(currentScheme == 1)
			return lightSchemeColor;
		return lightSchemeColor; //default
	}

	static color getBgColor() {
		return getColorBasedOnScheme(BG_COLOR_DARK, BG_COLOR_LIGHT); 
	}

	static color getTextColor() {
		return getColorBasedOnScheme(TEXT_COLOR_DARK, TEXT_COLOR_LIGHT);
	}

	/*
	 * The following methods use static references to the color() method, which is not static.
	 * The processing IDE will complain about this and not compile/run. This does however work
	 * fine when compiled to javascript.
	 */

	static color getArcColor(float width, float min, float max, boolean selected) {
		int alpha = selected?100:255;
		return color(0, map(width, min, max, 0, 255), 255, alpha);
	}

	static int getNodeAlpha(boolean selected) {
		int alpha  = 255;	
		if(SOME_NODE_SELECTED && !selected)
			alpha = 100;
		
		return alpha;
	}

	static color getNodeBaseColor() {
		return NODE_BASE_COLOR;
	}

	static color getCarbonBubbleColor() {
		return getColorBasedOnScheme(CARBON_BUBBLE_COLOR_DARK, CARBON_BUBBLE_COLOR_LIGHT);
	}

	static color getWaterDropletColor() {
		return WATER_DROPLET_COLOR;
	}

	static color getEditingColor() {
		return getColorBasedOnScheme(EDITING_COLOR_DARK, EDITING_COLOR_LIGHT);
	}
}















