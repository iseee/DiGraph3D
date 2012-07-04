class Arc {

	Node source;
	Node dest;
	float flow;
	PVector ctrlPt1;
	PVector ctrlPt2;
	int sourceOffset, destOffset;
	float rate = 5;
	boolean selectedForEditing = false;
	
	float[] flowByYears;

	// Assume flowData has at least two entries
	Arc(Node source, Node dest, float[] flowData) {
		this.source = source;
		this.dest = dest;
		flowByYears = flowData;
		this.flow = flowByYears[0];
		sourceOffset = source.associateOutArc(flow);
		destOffset = dest.associateInArc(flow);

		ctrlPt1 = new PVector();
		ctrlPt2 = new PVector();
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

	void updateYear(int year, float lerpVal) {
		// there was a crazy bug, where if here you put nextYear = year+1, Processing would for some reason
		// assign next year the value year with a one appended, rather than added. So if year was 1980,
		// nextYear would get the value 19801! Using the ++ operator seems to work as expected. 
		// I think it has to do with no expilcity typing in javascript. So if you say '5'+4 you get '54'. 
		// Even if you meant it to be numbers.
		int nextYear = year;
		nextYear++;
		nextYear = nextYear>2006?2006:nextYear;
		setFlow(lerp(flowByYears[year-1978], flowByYears[nextYear-1978], lerpVal));
	}

	void draw() {
		setControlPoints();
		float _width = SCALE * flow;
		// calculate the offsets of the arc, based on total arcs of the node, so that
		// multiple arcs don't overlap at the beginning/end
		float topOfBandSrc;
		float topOfBandDst;
		if(source.level < 0) {
			topOfBandDst = dest.getInArcPosition(destOffset);
			if(source.level == -1)
				topOfBandSrc = topOfBandDst;
			else 
				topOfBandSrc = dest.getY()+dest.getHalfHeight()+10;
		}
		else if(dest.level == -3) {
			topOfBandSrc = source.getOutArcPosition(sourceOffset);	
			topOfBandDst = source.getY()+source.getHalfHeight()+10;
		}
		else {
			topOfBandSrc = source.getOutArcPosition(sourceOffset);	
			topOfBandDst = dest.getInArcPosition(destOffset);
		}
		
		float source_x, dest_x;
		if(source.level < 0) {
			dest_x = dest.getX();
			source_x = dest_x - 50;
		}
		else if(dest.level < 0) {
			source_x = source.getX();
			dest_x = source_x + 50;
		}
		else {
			source_x = source.getX();
			dest_x = dest.getX();
		}

		drawBand(_width, topOfBandSrc, topOfBandDst, source_x, dest_x);

		// if the source or destination or the arc is selected, draw a sphere 'flowing' along the arc
		if( (source.isSelected || dest.isSelected) && !EDITING && source.level>0 && dest.level>0) {
			fill(ColorScheme.getArcColor(_width,5,25,false));
			float steps = 150/rate;
			float t = (frameCount % steps)/steps;
			float x = bezierPoint(source_x, ctrlPt1.x, ctrlPt2.x, dest_x, t);
			float y = bezierPoint(topOfBandSrc+_width/2, ctrlPt1.y, ctrlPt2.y, topOfBandDst+_width/2, t);
			float z = 0; 
			pushMatrix();
			translate(x,y,z);
			sphere(_width/2);
			popMatrix();
			showArcInfo(topOfBandSrc, topOfBandDst);
		}
	}

	void setControlPoints() {
		// handle special source/dest nodes with negative levels
		if(source.level < 0) {
			if(source.level == -1)
				ctrlPt1.set(dest.getX()-20, dest.getInArcPosition(destOffset), 0);
			else
				ctrlPt1.set(dest.getX()-20, dest.getInArcPosition(destOffset), 0);
			ctrlPt2.set(dest.getX()-10, dest.getInArcPosition(destOffset), 0);
		}
		else if(dest.level == -3) {
			ctrlPt1.set(source.getX()+10, source.getOutArcPosition(sourceOffset), 0);
			ctrlPt2.set(source.getX()+20, source.getOutArcPosition(sourceOffset), 0);
		}
		else {
			ctrlPt1.set(source.getX()+(dest.getX()-source.getX())/3, source.getOutArcPosition(sourceOffset), 0);
			ctrlPt2.set(source.getX()+2*(dest.getX()-source.getX())/3, dest.getInArcPosition(destOffset), 0);
		}
	}

	void showArcInfo(float topSrc, float topDst) {
		if(source.level < 0 || dest.level < 0) return;
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
	void drawBand(float _width, float srcTop, float dstTop, float source_x, float dest_x) {
		noStroke();
		int steps = BAND_STEPS;
		float t;
		float x, y, z;
		
		fill(source.nodeBaseColor, ColorScheme.getNodeAlpha(source.isSelected || dest.isSelected));
		beginShape(QUAD_STRIP);
		for(int i = 0; i < steps; i++) {
			t = i/float(steps);	
			x = bezierPoint(source_x, ctrlPt1.x, ctrlPt2.x, dest_x, t);
			y = bezierPoint(srcTop, ctrlPt1.y, ctrlPt2.y, dstTop, t);
			z = 0;
			vertex(x,y,z);
			y = bezierPoint(srcTop+_width, ctrlPt1.y+_width, ctrlPt2.y+_width, dstTop+_width, t);
			vertex(x,y,z);
		}
		endShape();
		
		if(selectedForEditing) {
			noFill();
			stroke(ColorScheme.getEditingColor());
			strokeWeight(2);
			// top line
			beginShape();
			vertex(source_x,srcTop,0); // start
			bezierVertex(ctrlPt1.x,ctrlPt1.y,ctrlPt1.z, ctrlPt2.x,ctrlPt2.y,ctrlPt2.z, dest_x,dstTop,0); // cp1,cp2,end
			endShape();
			// bottom line
			beginShape();
			vertex(source_x,srcTop+_width,0); // start
			bezierVertex(ctrlPt1.x,ctrlPt1.y+_width,ctrlPt1.z, ctrlPt2.x,ctrlPt2.y+_width,ctrlPt2.z, dest_x,dstTop+_width,0); // cp1,cp2,end
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
			if(mouseY > top_screen_y && mouseY < bot_screen_y)
				return true;
		}

		return false;
	}

	void toggleEditing() {
		selectedForEditing = !selectedForEditing;
	}

}

