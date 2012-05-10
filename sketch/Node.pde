class Node {

	int radius = 5;
	PVector position;
	int id;

	Node(int id) {
		position = new PVector(0,0,0);
		this.id = id;
	}

	void setPosition(float x, float y) {
		position.set(x,y,0);
	}

	float getX() {
		return position.x;
	}

	float getY() {
		return position.y;
	}

	void draw() {
		noStroke();
		fill(255, 0, 0);
		pushMatrix();
		translate(position.x, position.y, 0);
		sphere(radius);
		popMatrix();
	}

	boolean selected() {
		float screen_x = screenX(position.x, position.y, position.z);
		float screen_y = screenY(position.x, position.y, position.z);
		//float screen_x = position.x;
		//float screen_y = position.y;
		return ( (mouseX > screen_x-radius && mouseX < screen_x+radius) && (mouseY < screen_y+radius && mouseY > screen_y-radius) );
	}
}

