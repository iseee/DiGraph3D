class Node {

	PVector position;
	int id;
	float inStartX;
	ArrayList assocArcPositions;
	String name;
	int level;
	float totalFlow = 0;
	// a fraction of the total flow can be shown as emissions
	float carbonEmission = 0;
	float waterEmission = 0;

	Node(int id, String name, int level) {
		initialize(id, name, level);	
	}

	Node(int id, String name, int level, float carbonEmission, float waterEmission) {
		initialize(id, name, level);
		if(carbonEmission < 0)
			carbonEmission = 0;
		if(carbonEmission > 1)
			carbonEmission = 1;
		if(waterEmission < 0)
			waterEmission = 0;
		if(waterEmission > 1)
			waterEmission = 1;
		this.carbonEmission = carbonEmission;
		this.waterEmission = waterEmission;
		
	}

	void initialize(int id, String name, int level) {
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

	void increaseFlow(float delta) {
		totalFlow += delta;
	}


	// when associating new arc, add the width of that arc
	// to the positions list. This will tell the subsequent
	// arc it's y coordinate later on. 
	// Tell the arc its position in the list
	int associateArc(float flowIncrease) {
		increaseFlow(flowIncrease);
		if(assocArcPositions.size() > 0) {
			float prevElem = (Float) assocArcPositions.get(assocArcPositions.size()-1);
			assocArcPositions.add(prevElem+flowIncrease*SCALE);
		}
		else {
			assocArcPositions.add(flowIncrease*SCALE);	
		}
		
		return assocArcPositions.size() - 1;

	}

	float getArcPosition(int index) {
		// should give the value in index -1, or zero if first arc
		if(index == 0) {
			return position.y-(totalFlow*SCALE/2);
		}

		if(index < 0 || index > assocArcPositions.size()-1) {
			return -1;
		}

		return position.y-(totalFlow*SCALE/2)+((Float) assocArcPositions.get(index-1));
	}

	// when one of the associated arcs flows change, we
	// need to update this nodes flow, and the positions
	// of the arcs on the node
	void updateArcPositions(int index, float flowDelta) {
		increaseFlow(flowDelta);
		float delta = SCALE*flowDelta;
		for(int i = index; i < assocArcPositions.size(); i++) {
			assocArcPositions.set(i, (Float) assocArcPositions.get(i)+delta);
		}
	}


	void draw() {
		noStroke();
		float alpha = 100;
		if(selected()){
			alpha = 255;
			if(null != js) {
				js.displaySelectedNodeInfo(name, totalFlow, carbonEmission, waterEmission);
			}
			drawEmissions();
		}

		float half_width = totalFlow*SCALE/8;
		float half_height = totalFlow*SCALE/2;

		fill(255, 0, 0, alpha);
		stroke(100);
		pushMatrix();
		translate(position.x, position.y, 0);
		// draw a hexahedron to represent the node
		//sides
		beginShape(QUAD_STRIP);
		vertex(-half_width, half_height, -half_width); 	//1
		vertex(-half_width, -half_height, -half_width); //2
		vertex(half_width, half_height, -half_width); 	//3
		vertex(half_width,-half_height, -half_width); 	//4
		vertex(half_width, half_height, half_width);		//5
		vertex(half_width, -half_height, half_width);	//6
		vertex(-half_width, half_height, half_width);	//7
		vertex(-half_width, -half_height, half_width);	//8
		vertex(-half_width, half_height, -half_width);	//1	
		vertex(-half_width, -half_height, -half_width);	//2
		endShape();
		//top
		beginShape();
		vertex(-half_width, half_height, -half_width); 	//1
		vertex(half_width, half_height, -half_width); 	//3
		vertex(half_width, half_height, half_width);		//5
		vertex(-half_width, half_height, half_width);	//7
		endShape();
		//bottom();
		beginShape();
		vertex(-half_width, -half_height, -half_width); //2
		vertex(half_width,-half_height, -half_width); 	//4
		vertex(half_width, -half_height, half_width);	//6
		vertex(-half_width, -half_height, half_width);	//8
		endShape();
	
		// label
		textSize(12);
		fill(255);
		if(position.x < 0){
			textAlign(RIGHT);
		}
		else {
			textAlign(LEFT);
		}
		text(name, 0, 0, 50);
		popMatrix();
	}

	/*
	 * Determine if this node is selected.
	 * Selected means that the mouse is hovering over the node.
	 * This will work even when the scene is rotated, using the screenX/Y functions.
	 * returns	true if mouse over node, false otherwise
	 */
	boolean selected() {
		float _width = totalFlow*SCALE/2;
		float screen_x = screenX(position.x, position.y, position.z);
		float screen_y = screenY(position.x, position.y, position.z);
		return ( (mouseX > screen_x-_width && mouseX < screen_x+_width) && (mouseY < screen_y+_width && mouseY > screen_y-_width) );
	}

	void drawEmissions() {
		drawCarbonDioxBubbles();
		drawWaterBubbles();
	}

	/*
	 * Draw spheres rising from a node, to represent carbon emissions.
	 * The sphere rises only to the top of the screen, it grows in radius as
	 * it rises
	 */
	void drawCarbonDioxBubbles() {
		float radius = carbonEmission*totalFlow*SCALE;
		float dy = position.y-(totalFlow*SCALE/2)-(radius/4)*(frameCount%radius);
		if(dy<-height/2+radius)
			dy = -height/2+radius;
		pushMatrix();
		translate(position.x, dy);
		noStroke();
		fill(100);
		sphere(frameCount%radius);
		popMatrix();
	}

	/*
	 * Draw a sphere falling downwards from the node, to represent water emissions.
	 * Sphere increases in radius as it falls, only falls to bottom of screen, where
	 * it stops.
	 */
	void drawWaterBubbles() {
		float radius = waterEmission*totalFlow*SCALE;
		float dy = position.y+(totalFlow*SCALE/2)+(radius/4)*(frameCount%radius);
		if(dy>height/2-radius)
			dy = height/2-radius;
		pushMatrix();
		translate(position.x, dy);
		noStroke();
		fill(0,0, 255);
		sphere(frameCount%radius);
		popMatrix();
	}

}

