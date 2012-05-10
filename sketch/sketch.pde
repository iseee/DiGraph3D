int WIDTH = 1200;
int HEIGHT = 800;

int lastMouseX = 0;
int lastMouseY = 0;
int x_rotation = 0;
int y_rotation = 0;

PFont font;
Graph _graph;
int selectedNodeId = -1;

void setup() {
	size(WIDTH, HEIGHT, P3D);
	font = createFont("Arial", 10);
	sphereDetail(15);
	_graph = new Graph();
	
	// generate some random graph
	int numSource = int(random(1,5));
	int numSink = int(random(1,5));
	for(int i = 0; i < numSink; i++) {
		Node dst = new Node((i+1)*10);
		_graph.addSink(dst);
	}
	for(int j = 0; j < numSource; j++) {
		Node src = new Node(j+1);
		_graph.addSource(src);
	}
	for(int i = 0; i < numSource; i++) {
		for(int j = 0; j < numSink; j++) {
			// add some random edges
			int rnd = int(random(0,1000));
			if(rnd<500)
				_graph.addArc(i+1,(j+1)*10,rnd%20+5);
		}
	}

	
}

void draw() {
	lights();
	background(50);

	float cameraY = HEIGHT/2.0;
	float fov = PI/3.0;
	float cameraZ = cameraY / tan(fov / 2.0);
	float aspect = float(WIDTH)/float(HEIGHT);
	perspective(fov, aspect, cameraZ/10.0, cameraZ*10.0);
	translate(WIDTH/2, HEIGHT/2, 0);

	fill(255);
	textSize(15);
	noStroke();
	if(selectedNodeId != -1) {
		text("Node: "+ selectedNodeId, -WIDTH/2+10,-HEIGHT/2+20);
		text("Radius: "+ _graph.getNode(selectedNodeId).radius, -WIDTH/2+10, -HEIGHT/2+45); 
	}

	rotateX(x_rotation * PI/500);
	rotateY(y_rotation * PI/500);
	ArrayList<Node> nodes = _graph.getNodes();
	Node n;
	// find selected node after rotation, but write text before
	boolean found = false;
	for(int i=0; i<nodes.size(); i++) {
		n = nodes.get(i);
		if(n.selected()) {
			selectedNodeId = n.id;
			found = true;
		}
	}
	if(!found)
		selectedNodeId = -1;

_graph.draw(WIDTH, HEIGHT);
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
