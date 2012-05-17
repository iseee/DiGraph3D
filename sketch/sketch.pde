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
	_graph = genCanadaSankeyGraph(); 
}

Graph genCanadaSankeyGraph() {
	Graph g = new Graph();
	String[] srcNames = {"Uranium", "Hydro", "Natural Gas", "Biomass", "Coal", "Petroleum"};
	String[] dstNames = {"Residential", "Industrial", "Transportation", "Non-fuel", "Export"};
	Node n;
	for(int i=0; i < srcNames.length; i++) {
		n = new Node(i+1, srcNames[i],0);
		g.addNode(n);
	}
	for(int i=0; i < dstNames.length; i++) {
		n = new Node((i+1)*10, dstNames[i],3);
		g.addNode(n);
	}

	n = new Node(100, "Electric Power", 1);
	g.addNode(n);
	n = new Node(101, "Distributed Electricity", 2);
	g.addNode(n);
	
	g.addArc(100,101,2.0);
	g.addArc(5,100,1.16);

	g.addArc(1,50,7.61);		
	g.addArc(1,10,0.5);
	g.addArc(1,20,0.5);
	g.addArc(2,10,0.8);
	g.addArc(2,20,0.3);
	g.addArc(3,50,4.15);
	g.addArc(3,10,1.25);
	g.addArc(3,20,1.72);
	g.addArc(3,30,0.01);
	g.addArc(3,40,0.43);
	g.addArc(4,10,0.2);
	g.addArc(4,20,0.5);
	g.addArc(5,10,1.5);
	g.addArc(5,20,0.2);
	g.addArc(5,50,0.74);
	g.addArc(6,10,0.26);
	g.addArc(6,20,0.88);
	g.addArc(6,30,2.34);
	g.addArc(6,40,0.47);
	g.addArc(6,50,4.45);
	return g;
}
/*
Graph genRandomGraph() {
	Graph graph = new Graph();
	int numSource = int(random(1,5));
	int numSink = int(random(1,5));
	for(int i = 0; i < numSink; i++) {
		Node dst = new Node((i+1)*10, "fdsa");
		graph.addSink(dst);
	}
	for(int j = 0; j < numSource; j++) {
		Node src = new Node(j+1, "asdf");
		graph.addSource(src);
	}
	for(int i = 0; i < numSource; i++) {
		for(int j = 0; j < numSink; j++) {
			// add some random edges
			int rnd = int(random(0,1000));
			if(rnd<500)
				graph.addArc(i+1,(j+1)*10,rnd%20+5);
		}
	}
	return graph;
}
*/
void draw() {
	lights();
	background(150);

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
		text("Node: "+ _graph.getNode(selectedNodeId).name, -WIDTH/2+10,-HEIGHT/2+20);
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
}

void resetRotation() {
	x_rotation = 0;
	y_rotation = 0;
}
