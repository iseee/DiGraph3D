/*
 * Represents a directed graph, consisting of nodes and arcs.
 */

class Graph {

	/*
	 * We use the term level to describe the horizontal positioning of a node. The canvas is divided
	 * into 10 sections, determined by dx in updateNodePositions(). 
	 * Canvas:
	 * -------------------------------------------------------------
	 * |     |     |     |     |     |     |     |     |     |     |
	 * |     |     |     |     |     |     |     |     |     |     |
	 * |     |     |     |     |     |     |     |     |     |     |
	 * |     |     |     |     |     |     |     |     |     |     |
	 * |     |     |     |     |     |     |     |     |     |     |
	 * |     |     |     |     |     |     |     |     |     |     |
	 * |     |     |     |     |     |     |     |     |     |     |
	 * |     |     |     |     |     |     |     |     |     |     |
	 * |     |     |     |     |     |     |     |     |     |     |
	 * |     |     |     |     |     |     |     |     |     |     |
	 * |     |     |     |     |     |     |     |     |     |     |
	 * |     |     |     |     |     |     |     |     |     |     |
	 * |     |     |     |     |     |     |     |     |     |     |
	 * -------------------------------------------------------------
	 * 0     1     2     3     4     5     6     7     8     9     10     LEVEL
	 *
	 * The level is specified in the json input data, and determines where that node will
	 * be programatically placed on the canves. Nodes in the same level are placed evenly in 
	 * the vertical space. Node positions can be manually edited in the browser.
	 * We use a hashmap of hashmaps to store the nodes. This way we can place nodes of the same
	 * level together, for easier vertical placement later. The inner hashmap, indexed by node id
	 * somewhat speeds up individual node lookup for displaying info and editing etc.
	 * Negative levels are reserved for special nodes. These nodes are not drawn, and are positioned
	 * relative to another node. They are used to conceptually represent import/export/production 
	 */
	HashMap nodes  = new HashMap();
	ArrayList<Arc> arcs;
	boolean timelineAnimPlaying = false;
	int animTimer = 0;

	Graph() {
		arcs = new ArrayList();
	}

	void addNode(Node node) {
		// if we have not seen this level, add a hashmap for it into the nodes map
		if(!nodes.containsKey(node.level)) {
			nodes.put(node.level, new HashMap());
		}
		// add the node, indexed by id, into the hashmap for its corresponding level
		nodes.get(node.level).put(node.id, node);
		updateNodePositions();
	}

	boolean addArc(int srcID, int dstID, float[] flowData) {
		Node src = getNode(srcID);
		Node dst = getNode(dstID);
		if(src==null || dst==null) 
			return false;
		
		arcs.add(new Arc(src,dst,flowData));	
		return true;
	}

	/*
	 * Arranges the nodes based on the 'level' they are in. Within each level, nodes
	 * are spaced vertically evenly
	 */
	void updateNodePositions() {
		// iterate over levels
		Iterator levels = nodes.values().iterator();
		HashMap level;
		while(levels.hasNext()) {
			level = (HashMap) levels.next();
			float dy = height/float(level.size()+1);
			float dx = width/10.0;
			Node n;
			Iterator it = level.values().iterator();
			int i = 1;
			// iterate over nodes in this level
			while(it.hasNext()){
				n = (Node)it.next();
				// hack for level 4, where refined petrol is.
				if(n.level == 4)
					dy = height/float(n.level);
				n.setPosition(-1*width/2+dx*n.level, -1*height/2+i*dy);
				i++;
			}

		}

		// check spacing of nodes in first level for crowding
		int buffer = 50;
		if(nodes.get(1) != null) {
			int numElem = nodes.get(1).size();
			Node[] levelOneNodes = nodes.get(1).values().toArray();
			Node cur, prev;
			// start at second element
			for(int i = 1; i < numElem; ++i) {
				cur = levelOneNodes[i];
				prev = levelOneNodes[i-1];
				// if cur is inside prev bounding box, they overlap, cur should be moved down
				PVector[] curBoundBox = cur.getBoundingBox();
				PVector[] prevBoundBox = prev.getBoundingBox();
				float prevBottomY = prevBoundBox[1].y;
				float curTopY = curBoundBox[0].y;
				if(curTopY < prevBottomY+buffer+prev.getHalfHeight())  { // overlap, with pixel buffer
					float newBottomY = prevBottomY+buffer+cur.getHalfHeight()*2;
					if(newBottomY > height/2) {
						newBottomY = height/2;
						SCALE = SCALE - 1;
					}
					cur.setPosition(cur.position.x, newBottomY-cur.getHalfHeight());
				}
			}
		}
	}
	
	Node getNode(int id) {
		Node n = null;
		Iterator levels = nodes.values().iterator();
		HashMap level;
		while(levels.hasNext()) {
			level = (HashMap) levels.next();
			n = (Node)level.get(id);
			if(null != n) {
				// found node
				break;
			}
		}
		return n;
	}

	void draw() {
		pushMatrix();
		Arc a;
		for(int i = 0; i < arcs.size(); i++) {
			a = (Arc) arcs.get(i);
			a.draw();
		}
		Iterator levels = nodes.values().iterator();
		HashMap level;
		Node n;
		while(levels.hasNext()) {
			level = (HashMap)levels.next();
			Iterator it = level.values().iterator();
			while(it.hasNext()) {
				n = (Node)it.next(); 
				n.draw();
			}
		}
		popMatrix();

		if(timelineAnimPlaying) {
			incrementTimeline();
		}
	}

	ArrayList<Node> getNodes() {
		ArrayList result = new ArrayList();
		Iterator levels = nodes.values().iterator();
		HashMap level;
		while(levels.hasNext()) {
			level = (HashMap)levels.next();
			result.addAll(level.values());
		}
		return result;
	}

	ArrayList<Arc> getArcs() {
		return arcs;
	}

	Arc[] getArcsArray() {
		return (Arc[]) arcs.toArray();
	}

	void updateArcRate(int arcIndex, float rate) {
		Arc a = arcs.get(arcIndex);
		if(null != a)
			a.updateRate(rate);
	}

	void updateArcFlow(int arcIndex, float multiplier) {
		Arc a = arcs.get(arcIndex);
		if(null != a)
			a.updateFlow(multiplier);
	}
	
	void updateArcYear(int year, float lerpVal) {
		Iterator it = arcs.iterator();
		Arc a;
		while(it.hasNext()) {
			a = (Arc) it.next();
			a.updateYear(year, lerpVal);
		}
		updateNodePositions();
	}

	void toggle_timelineAnimPlaying() {
		timelineAnimPlaying =  !timelineAnimPlaying;
		animTimer = 0;
	}

	void incrementTimeline() {
		// get current year, increment, update
		int curYear = js.getTimelineYear();
		animTimer++;
		if(animTimer == 10) {
			animTimer = 0;
			curYear++;
			curYear = curYear>2006?1978:curYear;
			js.setTimelineYear(curYear);
		}
		updateArcYear(curYear, float(animTimer)/10.0);
	}
}
