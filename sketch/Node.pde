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
	boolean isSelected = false;
	CarbonBubbleAnimation carbonBubbleAnim;
	WaterDropletAnimation waterDropletAnim;

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
		carbonBubbleAnim = new CarbonBubbleAnimation();
		waterDropletAnim = new WaterDropletAnimation();
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
			if(!isSelected) { // means node just became selected
				isSelected = true;
				// start animations
				PVector start = new PVector();
				start.set(position);
				start.sub(0, getFlow()*SCALE/2, 0);
				carbonBubbleAnim.initiate(start, carbonEmission*getFlow());
				start.set(position);
				start.add(0, getFlow()*SCALE/2+5, 0);
				waterDropletAnim.initiate(start, waterEmission*getFlow());
			}
			alpha = 255;
			if(null != js) {
				js.displaySelectedNodeInfo(name, getFlow(), carbonEmission, waterEmission);
			}
			drawEmissions();
		}
		else {
			if(isSelected) { // node not currently selected, but isSelected is true, means just became not selected
				isSelected = false;
				js.clearNodeInfo();
			}
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
		if(carbonEmission > 0)
			carbonBubbleAnim.draw();
		if(waterEmission > 0)
			waterDropletAnim.draw();
	}
}

/*
 * Animated bubbles rising from the node when selected. Rate they rise
 * is proportional to the amount of emissions. The spheres slowly increase
 * in radius as they rise. 
 */
class CarbonBubbleAnimation {
	
	ArrayList<CarbonBubble> bubbles;
	int start;

	CarbonBubbleAnimation() {
		bubbles = new ArrayList<CarbonBubble>();
	}

	void initiate(PVector pos, float emission) {
		bubbles.clear();
		for(int i = 0; i < 5; i++) {
			bubbles.add(new CarbonBubble(pos, emission));
		}
		start = frameCount;
	}

	void draw() {
		CarbonBubble b;
		Iterator<CarbonBubble> it = bubbles.iterator();
		int i = 0;
		while(it.hasNext()) {
			b = it.next();
			b.draw(start,i++);
		}
	}
}

class CarbonBubble {

	PVector velocity;
	PVector bubPos;
	PVector start;
	float startRadius = 5;
	float maxRadius = 20;
	float emission;
	float yMax = 200;

	CarbonBubble(PVector position, float emission)  {
		bubPos = new PVector();
		bubPos.set(position);
		start = new PVector();
		start.set(bubPos);
		velocity = new PVector(0.0, -emission, 0.0);
		this.emission = emission;
	}
	
	void draw(int animStart, int i) {
		if( (frameCount - animStart) > (i*20) ) {
			noStroke();
			fill(230,50);
			pushMatrix();
			translate(bubPos.x, bubPos.y);
			float t = abs( (start.y-bubPos.y)/yMax);
			sphere(lerp(startRadius, maxRadius, t));
			popMatrix();
			bubPos.add(velocity);
			if(bubPos.y < -height/2+startRadius || start.y-bubPos.y > yMax)
				bubPos.set(start);
		}
	}
}

/*
 * Animated droplets falling from node to represent water emissions.
 * This may need to be modified to signify water usage instead.
 */
class WaterDropletAnimation {
	ArrayList<WaterDroplet> droplets;
	int start;

	WaterDropletAnimation() {
		droplets = new ArrayList<WaterDroplet>();
	}

	void initiate(PVector pos, float emission) {
		droplets.clear();
		for(int i = 0; i < 5; i++) {
			droplets.add(new WaterDroplet(pos, emission));
		}
		start = frameCount;
	}

	void draw() {
		WaterDroplet w;
		Iterator<WaterDroplet> it = droplets.iterator();
		int i = 0;
		while(it.hasNext()) {
			w = it.next();
			w.draw(start,i++);
		}
	}
}

class WaterDroplet {

	PVector velocity;
	PVector gravity = new PVector(0,0.5,0);
	PVector dropPos;
	PVector start;
	float startRadius = 1;
	float maxRadius = 10;
	float curRadius = startRadius;
	float emission;
	float yMax = 300;

	WaterDroplet(PVector position, float emission)  {
		dropPos = new PVector();
		dropPos.set(position);
		start = new PVector();
		start.set(dropPos);
		velocity = new PVector(0.0, emission, 0.0);
		this.emission = emission;
	}
	
	void draw(int animStart, int i) {
		if( (frameCount - animStart) > (i*emission) ) {
			noStroke();
			fill(0,0, 255,100);
			pushMatrix();
			translate(dropPos.x, dropPos.y);
			sphere(curRadius++);
			curRadius = curRadius>maxRadius?maxRadius:curRadius;
			popMatrix();
			if(curRadius >= maxRadius) {
				dropPos.add(velocity);
				velocity.add(gravity);
				if(dropPos.y > height/2-startRadius || dropPos.y-start.y > yMax){
					dropPos.set(start);
					velocity.set(0,emission,0);
					curRadius = startRadius;
				}
			}
		}
	}
}


