class Arc {

	Node source;
	Node dest;
	float origFlow;
	float flow;
	PVector ctrlPt1;
	PVector ctrlPt2;
	int sourceOffset, destOffset;
	float rate = 5;

	// param for hack to show transistion between two 'states'
	float futureFlow;
	
	Arc(Node source, Node dest, float flow, float futureFlow) {
		this.source = source;
		this.dest = dest;
		this.flow = flow;
		origFlow = flow;
		sourceOffset = source.associateArc(flow);
		destOffset = dest.associateArc(flow);
		this.futureFlow = futureFlow;

		ctrlPt1 = new PVector(source.getX()+(dest.getX()-source.getX())/3, source.getY(), 0);
		ctrlPt2 = new PVector(source.getX()+2*(dest.getX()-source.getX())/3, dest.getY(), 0);
	}

	/*
	 * When the flow of the arc is changed, the source and destination nodes of the
	 * arc must be notified, so they can update the stacking positions of the various
	 * arcs associated with the node.
	 */
	void setFlow(float newFlow) {
		source.updateArcPositions(sourceOffset, newFlow-flow);
		dest.updateArcPositions(destOffset, newFlow-flow);
		flow = newFlow;
	}

	void updateFlow(float multiplier) {
		setFlow(origFlow*multiplier);
	}

	/*
	 * The arc can be between two different states, the original flow (origFlow) and
	 * some future flow (futureFlow). We linearly interpolate between the two states
	 * @param val: linear interpolation parameter, 0<=val<=1 (enforced by boundParam)
	 */
	void updateLerp(float val) {
		setFlow(lerp(origFlow, futureFlow, boundParam(val)));
	}

	void draw() {
		float _width = SCALE * flow;
		// calculate the offsets of the arc, based on total arcs of the node, so that
		// multiple arcs don't overlap at the beginning/end
		float topOfBandSrc = source.getArcPosition(sourceOffset);	
		float topOfBandDst = dest.getArcPosition(destOffset);

		drawBand(_width, topOfBandSrc, topOfBandDst);

		// if the source or destination or the arc is selected, draw a sphere 'flowing' along the arc
		if(source.selected() || dest.selected()) {
			fill( 0, map(_width,5,25,0,255), 255, 100);
			float steps = 150/rate;
			float t = (frameCount % steps)/steps;
			float x = bezierPoint(source.getX(), ctrlPt1.x, ctrlPt2.x, dest.getX(), t);
			float y = bezierPoint(topOfBandSrc+_width/2, ctrlPt1.y, ctrlPt2.y, topOfBandDst+_width/2, t);
			float z = 0; 
			pushMatrix();
			translate(x,y,z);
			sphere(_width/2);
			popMatrix();
			showArcInfo(topOfBandSrc, topOfBandDst);
		}
	}

	void showArcInfo(float topSrc, float topDst) {
		fill(255);
		textSize(15);
		if(source.selected()) {
			textAlign(RIGHT);
			text(nf(flow,1,2), dest.getX()-10, topDst, TEXT_Z); 
		}
	}
	/*
	 * Draw the arc, as a band from source to destination. The width of the band is
	 * proportional to the flow of the arc. Arc will be drawn less opaque if neither associated node is selected. 
	 * @param _width: the width of the arc, proportional to flow
	 * @param srcTop: y coord of the top of the band at the source. This depends on the source, and how many
	 * other arcs are associated with it, and their size. The source must be queried for this
	 * @param dstTop: similar to srcTop, but the y coord at the destination, rather than source
	 */
	void drawBand(float _width, float srcTop, float dstTop) {
		noStroke();
		float alpha = 100;
		int steps = 300;
		float t;
		float x, y, z;
		
		// solid color if source/dest selected, more transparant otherwise
		if(source.selected() || dest.selected()) {
			alpha = 255;
		}
		fill(0, map(_width,5,25,0,255), 255, alpha);
		beginShape(QUAD_STRIP);
		for(int i = 0; i < steps; i++) {
			t = i/float(steps);	
			x = bezierPoint(source.getX(), ctrlPt1.x, ctrlPt2.x, dest.getX(), t);
			y = bezierPoint(srcTop, ctrlPt1.y-_width/2, ctrlPt2.y-_width/2, dstTop, t);
			z = 0;
			vertex(x,y,z);
			y = bezierPoint(srcTop+_width, ctrlPt1.y+_width/2, ctrlPt2.y+_width/2, dstTop+_width, t);
			vertex(x,y,z);
		}
		endShape();
	}

	void updateRate(float newRate) {
		rate = newRate;
	}

}

