class Graph {

	HashMap sources;
	HashMap sinks;
	ArrayList<Arc> arcs;

	Graph() {
		sources = new HashMap();
		sinks = new HashMap();	
		arcs = new ArrayList();
	}

	void addSource(Node node) {
		sources.put(node.id, node);
		updateSourcePositions();
	}

	void addSink(Node node) {
		sinks.put(node.id, node);
		updateSinkPositions();
	}

	boolean addArc(int srcID, int dstID, float flow) {
		Node src = (Node)sources.get(srcID);
		Node dst = (Node)sinks.get(dstID);
		if(src==null || dst==null) 
			return false;
		
		arcs.add(new Arc(src,dst,flow));	
		return true;
	}

	void updateSourcePositions() {
		float dy = height/float(sources.size()+1);
		float dx = width/5.0;
		Node n;
		Iterator it = sources.values().iterator();
		int i = 1;
		while(it.hasNext()){
			n = (Node)it.next();
			n.setPosition(-1*width/2+dx, -1*height/2+i*dy);
			i++;
		}
	}
	
	void updateSinkPositions() {
		float dy = height/float(sinks.size()+1);
		float dx = width/5.0;
		Node n;
		Iterator it = sinks.values().iterator();
		int i = 1;
		while(it.hasNext()){
			n = (Node)it.next();
			n.setPosition(width/2-dx, -1*height/2+i*dy);
			i++;
		}

	}

	Node getNode(int id) {
		Node n = (Node)sources.get(id);
		if(null == n)
			n = (Node)sinks.get(id);
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
		Iterator it = sources.values().iterator();
		while(it.hasNext()) {
			n = (Node)it.next();
			n.draw();
		}
		it = sinks.values().iterator();
		while(it.hasNext()) {
			n = (Node)it.next(); 
			n.draw();
		}
		popMatrix();
	}

	ArrayList<Node> getNodes() {
		ArrayList result = new ArrayList(sources.values());
		result.addAll(new ArrayList(sinks.values()));
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
