class Node {

	int radius = 0;
	PVector position;
	int id;
	float inStartX;

	Node(int id) {
		position = new PVector(0,0,0);
		this.id = id;
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

	void draw() {
		noStroke();
		fill(255, 0, 0);
		pushMatrix();
		translate(position.x, position.y, 0);
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
		popMatrix();

		// animation of incoming/outgoing while spheres
		int steps = 150;
		float t = (frameCount % steps)/float(steps);
		float dx = t*(inStartX-position.x);
		pushMatrix();
		translate(inStartX,position.y,0);
		fill(255);
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
	}

	boolean selected() {
		float screen_x = screenX(position.x, position.y, position.z);
		float screen_y = screenY(position.x, position.y, position.z);
		//float screen_x = position.x;
		//float screen_y = position.y;
		return ( (mouseX > screen_x-radius && mouseX < screen_x+radius) && (mouseY < screen_y+radius && mouseY > screen_y-radius) );
	}
}

