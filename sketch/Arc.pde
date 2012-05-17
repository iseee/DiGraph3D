class Arc {

	Node source;
	Node dest;
	float origFlow;
	float flow;
	float radius;
	PVector ctrlPt1;
	PVector ctrlPt2;
	int sourceOffset, destOffset;
	float rate = 0.5;
	
	Arc(Node source, Node dest, float flow) {
		this.source = source;
		this.dest = dest;
		origFlow = flow;
		setFlow(flow);
		sourceOffset = source.associateArc(radius);
		destOffset = dest.associateArc(radius);

		ctrlPt1 = new PVector(source.getX()+(dest.getX()-source.getX())/3, source.getY(), 0);
		ctrlPt2 = new PVector(source.getX()+2*(dest.getX()-source.getX())/3, dest.getY(), 0);
	}

	void setFlow(float flow) {
		this.flow = flow;
		radius = flow*6;
	}

	void updateFlow(float multiplier) {
		setFlow(origFlow*multiplier);
		source.updateArcPositions(sourceOffset, radius);
		dest.updateArcPositions(destOffset, radius);
	}

	void draw() {
		// calculate the offsets of the arc, based on total arcs of the node, so that
		// multiple arcs don't overlap at the beginning/end
		float topOfBandSrc = source.getArcPosition(sourceOffset);	
		float topOfBandDst = dest.getArcPosition(destOffset);

		drawBand(topOfBandSrc, topOfBandDst);
		//stroke(255);

		fill( 0, map(radius,5,25,0,255), 255, 100);
		float steps = 150/rate;
		float t = (frameCount % steps)/steps;
		float x = bezierPoint(source.getX(), ctrlPt1.x, ctrlPt2.x, dest.getX(), t);
		float y = bezierPoint(topOfBandSrc+radius, ctrlPt1.y, ctrlPt2.y, topOfBandDst+radius, t);
		float z = 0;
		pushMatrix();
		translate(x,y,z);
		sphere(radius);
		popMatrix();
	}

	void drawBand(float srcTop, float dstTop) {
		noStroke();
		float alpha = 100;
		if(source.selected() || dest.selected())
			alpha = 255;
		fill(0, map(radius,5,25,0,255), 255, alpha);
		beginShape(QUAD_STRIP);
		int steps = 300;
		float t;
		float x, y, z;
		for(int i = 0; i < steps; i++) {
			t = i/float(steps);	
			x = bezierPoint(source.getX(), ctrlPt1.x, ctrlPt2.x, dest.getX(), t);
			y = bezierPoint(srcTop, ctrlPt1.y-radius, ctrlPt2.y-radius, dstTop, t);
			z = 0;
			vertex(x,y,z);
			y = bezierPoint(srcTop+2*radius, ctrlPt1.y+radius, ctrlPt2.y+radius, dstTop+2*radius, t);
			vertex(x,y,z);
		}
		endShape();
	}

	void updateRate(float newRate) {
		rate = newRate;
	}

}

