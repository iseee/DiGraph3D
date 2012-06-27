class Arc {

	Node source;
	Node dest;
//	float origFlow;
	float flow;
	PVector ctrlPt1;
	PVector ctrlPt2;
	int sourceOffset, destOffset;
	float rate = 5;
	boolean selectedForEditing = false;

	// param for hack to show transistion between two 'states'
//	float futureFlow;
	
	float[] flowByYears;

	// Assume flowData has at least two entries
	Arc(Node source, Node dest, float[] flowData) {
		this.source = source;
		this.dest = dest;
		flowByYears = flowData;
		this.flow = flowByYears[0];
		sourceOffset = source.associateOutArc(flow);
		destOffset = dest.associateInArc(flow);

		ctrlPt1 = new PVector(source.getX()+(dest.getX()-source.getX())/3, source.getY(), 0);
		ctrlPt2 = new PVector(source.getX()+2*(dest.getX()-source.getX())/3, dest.getY(), 0);
	}

	/*
	 * When the flow of the arc is changed, the source and destination nodes of the
	 * arc must be notified, so they can update the stacking positions of the various
	 * arcs associated with the node.
	 */
	void setFlow(float newFlow) {
		source.updateOutArcPositions(sourceOffset, newFlow-flow);
		dest.updateInArcPositions(destOffset, newFlow-flow);
		flow = newFlow;
	}

	void updateFlow(float multiplier) {
		setFlow(flowByYears[0]*multiplier);
	}

	/*
	 * The arc can be between two different states, the original flow (origFlow) and
	 * some future flow (futureFlow). We linearly interpolate between the two states
	 * @param val: linear interpolation parameter, 0<=val<=1 (enforced by boundParam)
	 */
	void updateYear(int year) {
		setFlow(flowByYears[year-1978]);
	}

	void draw() {
		float _width = SCALE * flow;
		// calculate the offsets of the arc, based on total arcs of the node, so that
		// multiple arcs don't overlap at the beginning/end
		float topOfBandSrc = source.getOutArcPosition(sourceOffset);	
		float topOfBandDst = dest.getInArcPosition(destOffset);

		drawBand(_width, topOfBandSrc, topOfBandDst);

		// if the source or destination or the arc is selected, draw a sphere 'flowing' along the arc
		if( (source.isSelected || dest.isSelected) && !EDITING) {
			fill(ColorScheme.getArcColor(_width,5,25,false));
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
		fill(ColorScheme.getTextColor());
		textSize(15);
		if(source.isSelected) {
			textAlign(RIGHT);
			text(nf(flow,1,2), dest.getX()-10, topDst, TEXT_Z); 
		}
		if(dest.isSelected) {
			textAlign(LEFT);
			text(nf(flow,1,2), source.getX()+10, topSrc, TEXT_Z);
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
		int steps = BAND_STEPS;
		float t;
		float x, y, z;
		
		fill(ColorScheme.getArcColor(_width,5,25, source.isSelected || dest.isSelected));
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
		
		if(selectedForEditing) {
			noFill();
			stroke(ColorScheme.getEditingColor());
			strokeWeight(2);
			// top line
			beginShape();
			vertex(source.getX(),srcTop,0); // start
			bezierVertex(ctrlPt1.x,ctrlPt1.y-_width/2,ctrlPt1.z, ctrlPt2.x,ctrlPt2.y-_width/2,ctrlPt2.z, dest.getX(),dstTop,0); // cp1,cp2,end
			endShape();
			// bottom line
			beginShape();
			vertex(source.getX(),srcTop+_width,0); // start
			bezierVertex(ctrlPt1.x,ctrlPt1.y+_width/2,ctrlPt1.z, ctrlPt2.x,ctrlPt2.y+_width/2,ctrlPt2.z, dest.getX(),dstTop+_width,0); // cp1,cp2,end
			endShape();
			stroke(100);
			noStroke();
		}
	}

	void updateRate(float newRate) {
		rate = newRate;
	}

	boolean selected() {
		float src_screen_x = screenX(source.getX(), source.getY(), source.getZ());	
		float dst_screen_x = screenX(dest.getX(), dest.getY(), dest.getZ());	

		if(mouseX < dst_screen_x && mouseX > src_screen_x) {
			float _width = SCALE * flow;
			float srcTop = source.getOutArcPosition(sourceOffset);	
			float dstTop = dest.getInArcPosition(destOffset);
			float t = (mouseX - src_screen_x) / (dst_screen_x - src_screen_x);
			int topY = bezierPoint(srcTop, ctrlPt1.y-_width/2, ctrlPt2.y-_width/2, dstTop, t);
			int botY = bezierPoint(srcTop+_width, ctrlPt1.y+_width/2, ctrlPt2.y+_width/2, dstTop+_width, t);
			float top_screen_y = screenY(0, topY, 0);
			float bot_screen_y = screenY(0, botY, 0);
			/* debug println's
			println("between "+source.name+" and "+dest.name);
			println(t);
			println("topY: "+topY);
			println("botY: "+botY);
			println("top_screen_y: "+top_screen_y);
			println("bot_screen_y: "+bot_screen_y);
			println("mouseY: "+mouseY);
			*/
			if(mouseY > top_screen_y && mouseY < bot_screen_y)
				return true;
		}

		return false;
	}

	void toggleEditing() {
		selectedForEditing = !selectedForEditing;
	}

}

