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
		drawBand();
		//stroke(255);

		fill( 0, map(radius,5,25,0,255), 255);
		int steps = 300;
		float t = (frameCount % steps)/float(steps);
		float x = bezierPoint(source.getX(), ctrlPt1.x, ctrlPt2.x, dest.getX(), t);
		float y = bezierPoint(source.getY(), ctrlPt1.y, ctrlPt2.y, dest.getY(), t);
		float z = 0;
		pushMatrix();
		translate(x,y,z);
		sphere(radius);
		popMatrix();
	}

	void drawBand() {
		//noFill();
		fill( 0, map(flow,5,25,0,255), 255);
		beginShape(QUAD_STRIP);
		int steps = 300;
		float t;
		float x, y, z;
		for(int i = 0; i < steps; i++) {
		 	t = i/float(steps);	
			x = bezierPoint(source.getX(), ctrlPt1.x, ctrlPt2.x, dest.getX(), t);
			y = bezierPoint(source.getY()+radius, ctrlPt1.y+radius, ctrlPt2.y+radius, dest.getY()+radius, t);
			z = 0;
			vertex(x,y,z);
			y = bezierPoint(source.getY()-radius, ctrlPt1.y-radius, ctrlPt2.y-radius, dest.getY()-radius, t);
			vertex(x,y,z);
		}
		endShape();
		
	}


}

