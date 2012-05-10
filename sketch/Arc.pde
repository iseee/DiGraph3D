class Arc {

	Node source;
	Node dest;
	float flow;
	float radius;
	int cylinderDetail = 30;
	float x1;
	float x2;
	float y1;
	float y2;
	float ctrlPt1_x;  
	float ctrlPt1_y;  
	float ctrlPt2_x;  
	float ctrlPt2_y;  

	Arc(Node source, Node dest, float flow) {
		this.source = source;
		this.dest = dest;
		setFlow(flow);
		source.increaseRadius(radius);
		dest.increaseRadius(radius);
		x1 = source.getX();
		x2 = dest.getX();
		y1 = source.getY();
		y2 = dest.getY();
		ctrlPt1_x = x1+(x2-x1)/3.0;  
		ctrlPt1_y = y1+(y2-y1)/3.0;  
		ctrlPt2_x = x1+2.0*(x2-x1)/3.0;  
		ctrlPt2_y = y1+2.0*(y2-y1)/3.0;  
	}

	void setFlow(float flow) {
		this.flow = flow;
		radius = flow;
	}

	void draw() {
		//stroke(255);
		noFill();
		stroke( 0, map(radius,5,25,0,255), 255);
		bezier(x1,y1,0, ctrlPt1_x, y1,0, x2, ctrlPt2_y,0, x2,y2,0);
		noStroke();
		fill( 0, map(radius,5,25,0,255), 255);
		int steps = 300;
		float t = (frameCount % steps)/float(steps);
		float x = bezierPoint(x1, ctrlPt1_x, x2, x2, t);
		float y = bezierPoint(y1, y1, ctrlPt2_y, y2, t);
		float z = 0;
		pushMatrix();
		translate(x,y,z);
		sphere(radius);
		popMatrix();

		/*
		for (int i = 0; i < steps; i++) {
			float t = i / float(steps);
			float x = bezierPoint(x1, ctrlPt1_x, x2, x2, t);
			float y = bezierPoint(y1, y1, ctrlPt2_y, y2, t);
			float z = 0;
			pushMatrix();
			translate(x,y,z);
			sphere(radius);
			popMatrix();
		}*/
		//drawCylinder(x1,y1,x2,y2, radius);
	}

	void drawCylinder(float fromX, float fromY, float toX, float toY, float rad) {
		float len = sqrt( pow( (toX-fromX), 2 ) + pow( (toY-fromY), 2 ));
		pushMatrix();
		translate(fromX, fromY, 0);
		rotateY(HALF_PI);
		rotateX(atan(-1*(toY-fromY)/(toX-fromX)));
		drawCylinder(rad, len, cylinderDetail);
		popMatrix();
	}
	
	// r=radius, h=height
	void drawCylinder(float r, float h, int sides){
		noStroke();
		fill( 0, map(r,5,25,0,255), 255);

		float angle = TWO_PI/float(sides);

		beginShape(TRIANGLE_STRIP);
		for (int i = 0; i < sides + 1; i++) {
			float x = cos(i*angle) * r;
			float y = sin(i*angle) * r;
			vertex(x, y, 0);
			vertex(x, y, h);    
		}
		endShape(CLOSE);
	}

}

