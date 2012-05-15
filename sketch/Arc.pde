class Arc {

	Node source;
	Node dest;
	float flow;
	float radius;
	PVector ctrlPt1;
	PVector ctrlPt2;
	
	Arc(Node source, Node dest, float flow) {
		this.source = source;
		this.dest = dest;
		setFlow(flow);
		source.increaseRadius(radius);
		dest.increaseRadius(radius);

		ctrlPt1 = new PVector(source.getX()+(dest.getX()-source.getX())/3, source.getY(), 0);
		ctrlPt2 = new PVector(source.getX()+2*(dest.getX()-source.getX())/3, dest.getY(), 0);
	}

	void setFlow(float flow) {
		this.flow = flow;
		radius = flow;
	}

	void draw() {
		//stroke(255);
		/*noFill();
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
*/
		drawBand();
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

	void drawBand() {
		//noFill();
		fill( 0, map(flow,5,25,0,255), 255);
		float half_width = flow/2;
		beginShape(QUAD_STRIP);
		int steps = 300;
		float t;
		float x, y, z;
		for(int i = 0; i < steps; i++) {
		 	t = i/float(steps);	
			x = bezierPoint(source.getX(), ctrlPt1.x, ctrlPt2.x, dest.getX(), t);
			y = bezierPoint(source.getY()+half_width, ctrlPt1.y+half_width, ctrlPt2.y+half_width, dest.getY()+half_width, t);
			z = 0;
			vertex(x,y,z);
			y = bezierPoint(source.getY()-half_width, ctrlPt1.y-half_width, ctrlPt2.y-half_width, dest.getY()-half_width, t);
			vertex(x,y,z);
		}
		endShape();
		
	}


}

