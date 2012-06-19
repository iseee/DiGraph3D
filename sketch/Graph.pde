/*
 * Represents a directed graph, consisting of nodes and arcs.
 */

class Graph {

	/*
	 * nodes are arranged in 'levels'. A level is a section of the canvas. The canvas is split into five
	 * sections, which we refer to as levels. A level consists of some nodes, which will be drawn stacked
	 * vertically. This is kind of a hack. Rather than automatically determining the horizontal spacing
	 * between nodes based on connectivity, we manually enter which level they should be in. So nodes that
	 * are only sources, will be in level 1 (left most section of canvas), and nodes which are only destinations
	 * are usually in level 5 (rightmost). The intermediate nodes which have both incoming and outgoing arcs, fill
	 * the other intermediate levels
	 */
	HashMap[] nodes  = {new HashMap(), new HashMap(), new HashMap(), new HashMap(), new HashMap()};
	ArrayList<Arc> arcs;

	Graph() {
		arcs = new ArrayList();
	}

	void addNode(Node node) {
		nodes[node.level].put(node.id, node);
		updateNodePositions();
	}

	boolean addArc(int srcID, int dstID, float flow, float futureFlow) {
		Node src = getNode(srcID);
		Node dst = getNode(dstID);
		if(src==null || dst==null) 
			return false;
		
		arcs.add(new Arc(src,dst,flow,futureFlow));	
		return true;
	}

	// update each level
	void updateNodePositions() {
		// iterate over levels
		for(int j = 0; j<nodes.length; j++) {	
			float dy = height/float(nodes[j].size()+1);
			float dx = width/10.0;
			Node n;
			Iterator it = nodes[j].values().iterator();
			int i = 1;
			// iterate over nodes in this level
			while(it.hasNext()){
				n = (Node)it.next();
				n.setPosition(-1*width/2+dx*(2*j+1), -1*height/2+i*dy);
				i++;
			}
		}
	}
	
	Node getNode(int id) {
		boolean found = false;
		Node n = null;
		for(int i = 0; i < nodes.length; i++) {
			n = (Node)nodes[i].get(id);
			if(null != n) {
				found = true;
				break;
			}
		}
		return n;
	}

	/*
	 * @params width of canvas
	 *         height of canvas
	 */
	void draw(int width, int height) {
		pushMatrix();
		Arc a;
		for(int i = 0; i < arcs.size(); i++) {
			a = (Arc) arcs.get(i);
			a.draw();
		}
		Node n;
		for(int i = 0; i < nodes.length; i++) {
			Iterator it = nodes[i].values().iterator();
			while(it.hasNext()) {
				n = (Node)it.next(); 
				n.draw();
			}
		}
		popMatrix();
	}

	ArrayList<Node> getNodes() {
		ArrayList result = new ArrayList(nodes[0].values());
		result.addAll(nodes[1].values());
		result.addAll(nodes[2].values());
		result.addAll(nodes[3].values());
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
	
	void updateArcLerps(float val) {
		Iterator it = arcs.iterator();
		Arc a;
		while(it.hasNext()) {
			a = (Arc) it.next();
			a.updateLerp(val);
		}
	}
}
