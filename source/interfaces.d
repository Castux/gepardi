interface Renderer
{
	void render(void delegate() cb);
	void toggleFullscreen();
	int width();
	int height();
}

interface Scene
{
	void update();
	void draw(int width, int height);
}
