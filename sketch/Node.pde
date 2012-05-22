class Node {

	PVector position;
	int id;
	float inStartX;
	ArrayList assocInArcPositions;
	ArrayList assocOutArcPositions;
	String name;
	int level;
	float inFlow = 0;
	float outFlow = 0;
	// a fraction of the total flow can be shown as emissions
	float carbonEmission = 0;
	float waterEmission = 0;

	Node(int id, String name, int level) {
		initialize(id, name, level);	
	}

	Node(int id, String name, int level, float carbonEmission, float waterEmission) {
		initialize(id, name, level);
		this.carbonEmission = boundParam(carbonEmission);
		this.waterEmission = boundParam(waterEmission);
	}

	void initialize(int id, String name, int level) {
		position = new PVector(0,0,0);
		assocInArcPositions = new ArrayList();
		assocOutArcPositions = new ArrayList();
		this.id = id;
		this.name = name;
		this.level = level;
	}

	float getFlow() {
		return max(inFlow,outFlow);
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

	int associateInArc(float flowIncrease) {
		inFlow+=flowIncrease;	
		if(assocInArcPositions.size() > 0) {
			float prevElem = (Float) assocInArcPositions.get(assocInArcPositions.size()-1);
			assocInArcPositions.add(prevElem+flowIncrease*SCALE);
		}
		else {
			assocInArcPositions.add(flowIncrease*SCALE);	
		}
		
		return assocInArcPositions.size() - 1;

	}

	int associateOutArc(float flowIncrease) {
		outFlow+=flowIncrease;
		if(assocOutArcPositions.size() > 0) {
			float prevElem = (Float) assocOutArcPositions.get(assocOutArcPositions.size()-1);
			assocOutArcPositions.add(prevElem+flowIncrease*SCALE);
		}
		else {
			assocOutArcPositions.add(flowIncrease*SCALE);	
		}
		
		return assocOutArcPositions.size() - 1;

	}

	float getInArcPosition(int index) {
		// should give the value in index -1, or zero if first arc
		if(index == 0) {
			return position.y-(getFlow()*SCALE/2);
		}

		if(index < 0 || index > assocInArcPositions.size()-1) {
			return -1;
		}

		return position.y-(getFlow()*SCALE/2)+((Float) assocInArcPositions.get(index-1));
	}

	float getOutArcPosition(int index) {
		// should give the value in index -1, or zero if first arc
		if(index == 0) {
			return position.y-(getFlow()*SCALE/2);
		}

		if(index < 0 || index > assocOutArcPositions.size()-1) {
			return -1;
		}

		return position.y-(getFlow()*SCALE/2)+((Float) assocOutArcPositions.get(index-1));
	}

	void updateInArcPositions(int index, float flowDelta) {
		inFlow+=flowDelta;
		float delta = SCALE*flowDelta;
		for(int i = index; i < assocInArcPositions.size(); i++) {
			assocInArcPositions.set(i, (Float) assocInArcPositions.get(i)+delta);
		}
	}

	void updateOutArcPositions(int index, float flowDelta) {
		outFlow+=flowDelta;
		float delta = SCALE*flowDelta;
		for(int i = index; i < assocOutArcPositions.size(); i++) {
			assocOutArcPositions.set(i, (Float) assocOutArcPositions.get(i)+delta);
		}
	}


	void draw() {
		noStroke();
		float alpha = 100;
		if(selected()){
			alpha = 255;
			if(null != js) {
				js.displaySelectedNodeInfo(name, getFlow(), carbonEmission, waterEmission);
			}
			drawEmissions();
		}

		float half_width = getFlow()*SCALE/8;
		float half_height = getFlow()*SCALE/2;

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
		fill(TEXT_COLOR);
		if(position.x < 0){
			textAlign(RIGHT);
		}
		else {
			textAlign(LEFT);
		}
		text(name, 0, 0, TEXT_Z);
		popMatrix();
	}

	/*
	 * Determine if this node is selected.
	 * Selected means that the mouse is hovering over the node.
	 * This will work even when the scene is rotated, using the screenX/Y functions.
	 * returns	true if mouse over node, false otherwise
	 */
	boolean selected() {
		float _width = getFlow()*SCALE/2;
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
		float radius = carbonEmission*getFlow()*SCALE;
		float dy = position.y-(getFlow()*SCALE/2)-(radius/4)*(frameCount%radius);
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
		float radius = waterEmission*getFlow()*SCALE;
		float dy = position.y+(getFlow()*SCALE/2)+(radius/4)*(frameCount%radius);
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

