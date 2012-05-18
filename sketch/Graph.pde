class Graph {

	HashMap[] nodes  = {new HashMap(), new HashMap(), new HashMap(), new HashMap(), new HashMap()};
	ArrayList<Arc> arcs;

	Graph() {
		arcs = new ArrayList();
	}

	void addNode(Node node) {
		nodes[node.level].put(node.id, node);
		updateNodePositions();
	}

	boolean addArc(int srcID, int dstID, float flow) {
		Node src = getNode(srcID);
		Node dst = getNode(dstID);
		if(src==null || dst==null) 
			return false;
		
		arcs.add(new Arc(src,dst,flow));	
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

	// height and width of canvas
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
}
