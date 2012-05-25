int WIDTH = 1200;
int HEIGHT = 800;
int SCALE = 8;		// used throughout to scale the visualization, ie the flow may be 2.5, but the arc will be drawn scale*2.5
int TEXT_Z = 50; 
color BG_COLOR = #000000;
color TEXT_COLOR = #FFFFFF;

int lastMouseX = 0;
int lastMouseY = 0;
int x_rotation = 0;
int y_rotation = 0;

PFont font;
Graph _graph;

JavaScript js;

/*
 * This allows the sketch to call external javascript functions, so it can interact with the page.
 * You just prototype the function here in the interface. Then as long as this function is defined 
 * somewhere in your js, you can call it straight from processing code.
 */
interface JavaScript {
	void displaySelectedNodeInfo(String name, float flow, float carbonEmission, float waterEmission);	
	void clearNodeInfo();
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
	lights();
	background(BG_COLOR);

	float cameraY = HEIGHT/2.0;
	float fov = PI/3.0;
	float cameraZ = cameraY / tan(fov / 2.0);
	float aspect = float(WIDTH)/float(HEIGHT);
	perspective(fov, aspect, cameraZ/10.0, cameraZ*10.0);
	translate(WIDTH/2, HEIGHT/2, 0);

	rotateX(x_rotation * PI/500);
	rotateY(y_rotation * PI/500);

	if(null != _graph)
		_graph.draw(WIDTH, HEIGHT);
	else {
		text("No data yet!", 0, 0);
	}

}

void mousePressed() {
	setLastMouse();
}

void setLastMouse() {
	lastMouseX = mouseX;
	lastMouseY = mouseY;
}

float dragLength() {
	return sqrt( pow(mouseX-lastMouseX,2) + pow(mouseY-lastMouseY,2) );
}

void mouseDragged() {
	if(dragLength() > 10)
		setLastMouse();
	y_rotation += (mouseX-lastMouseX);
	x_rotation += (lastMouseY-mouseY);
}

void updateArcRate(int arcIndex, float rate) {
	if(null != _graph)
		_graph.updateArcRate(arcIndex, rate);
}

void updateArcFlow(int arcIndex, float multiplier){
	if(null != _graph)
		_graph.updateArcFlow(arcIndex, multiplier);
}

void updateArcLerps(float val) {
	if(null != _graph)
		_graph.updateArcLerps(val);
}

void keyPressed() {
	if(key == 'r' || key == 'R')
		resetRotation();
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


