class Node {

	int radius = 0;
	PVector position;
	int id;
	float inStartX;
	ArrayList assocArcPositions;
	String name;
	PFont font = createFont("Arial", 10);
	int level;

	Node(int id, String name, int level) {
		position = new PVector(0,0,0);
		this.id = id;
		assocArcPositions = new ArrayList();
		this.name = name;
		this.level = level;
	}

	void setPosition(float x, float y) {
		position.set(x,y,0);
		inStartX = position.x+(position.x/2);
	}

	float getX() {
		return position.x;
	}

	float getY() {
		return position.y;
	}

	void increaseRadius(float delta) {
		radius += delta;	
	}

	// when associating new arc, add the width of that arc
	// to the positions list. This will tell the subsequent
	// arc it's y coordinate later on. 
	// Tell the arc its position in the list
	int associateArc(float flowIncrease) {
		increaseRadius(flowIncrease);
		if(assocArcPositions.size() > 0) {
			float prevElem = (Float) assocArcPositions.get(assocArcPositions.size()-1);
			assocArcPositions.add(prevElem+flowIncrease*2);
		}
		else {
			assocArcPositions.add(flowIncrease*2);	
		}
		
		return assocArcPositions.size() - 1;

	}

	float getArcPosition(int index) {
		// should give the value in index -1, or zero if first arc
		if(index == 0) {
			return 0;
		}

		if(index < 0 || index > assocArcPositions.size()-1) {
			return -1;
		}

		return (Float) assocArcPositions.get(index-1);
	}

	// when one of the associated arcs flows change, we
	// need to update this nodes radius, and the positions
	// of the arcs on the node
	void updateArcPositions(int index, float newArcFlow) {
		float prevFlow = (Float) assocArcPositions.get(index);
		float delta = 2*newArcFlow - prevFlow;
		increaseRadius(newArcFlow - (prevFlow/2));
		for(int i = index; i < assocArcPositions.size(); i++) {
			assocArcPositions.set(i, (Float) assocArcPositions.get(i)+delta);
		}
	}

	int getRadius() {
		return radius;
	}

	void draw() {
		noStroke();
		fill(255, 0, 0);
		pushMatrix();
		translate(position.x, position.y, 0);
		// draw a hexahedron to represent the node
		//sides
		beginShape(QUAD_STRIP);
		vertex(-radius/4, radius, -radius/4); 	//1
		vertex(-radius/4, -radius, -radius/4); //2
		vertex(radius/4, radius, -radius/4); 	//3
		vertex(radius/4,-radius, -radius/4); 	//4
		vertex(radius/4, radius, radius/4);		//5
		vertex(radius/4, -radius, radius/4);	//6
		vertex(-radius/4, radius, radius/4);	//7
		vertex(-radius/4, -radius, radius/4);	//8
		vertex(-radius/4, radius, -radius/4);	
		vertex(-radius/4, -radius, -radius/4);
		endShape();
		//top
		beginShape();
		vertex(-radius/4, radius, -radius/4); 	//1
		vertex(radius/4, radius, -radius/4); 	//3
		vertex(radius/4, radius, radius/4);		//5
		vertex(-radius/4, radius, radius/4);	//7
		endShape();
		//bottom();
		beginShape();
		vertex(-radius/4, -radius, -radius/4); //2
		vertex(radius/4,-radius, -radius/4); 	//4
		vertex(radius/4, -radius, radius/4);	//6
		vertex(-radius/4, -radius, radius/4);	//8
		endShape();
		//sphere(radius==0?5:radius); // draw node even if no incoming/outcoming edges
		textSize(12);
		fill(255);
		float xpos;
		if(position.x < 0)
			xpos = -80;
		else 
			xpos = radius<10?10:radius;
		text(name, xpos, 0);
		popMatrix();
/*
		// animation of incoming/outgoing while spheres
		int steps = 150;
		float t = (frameCount % steps)/float(steps);
		float dx = t*(inStartX-position.x);
		fill(255, 100);
		pushMatrix();
		translate(inStartX,position.y,0);
		if(radius != 0) // processing.js renders a small sphere even if call sphere(0), so explicitly check
			sphere(radius);
		popMatrix();
		pushMatrix();
		if(position.x < 0) {
			translate(inStartX-dx,position.y,0);
		}
		else {
			translate(position.x+dx,position.y,0);
		}
		if(radius != 0) {
			sphere(radius);
		}
		popMatrix();
*/
	}

	boolean selected() {
		float screen_x = screenX(position.x, position.y, position.z);
		float screen_y = screenY(position.x, position.y, position.z);
		return ( (mouseX > screen_x-radius && mouseX < screen_x+radius) && (mouseY < screen_y+radius && mouseY > screen_y-radius) );
	}
}

