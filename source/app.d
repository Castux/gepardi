import std.stdio;
import std.math;
import std.format;
import std.conv;
import std.string;

import raylib;

import renderer;
import interfaces;
import mainscene;
import res;

void main()
{
	auto renderer = new BasicRenderer("gepardi");
	Res.loadAll();
	Scene currentScene = new MainScene();

	while (!WindowShouldClose())
	{
		if (IsKeyPressed(KeyboardKey.KEY_F))
			renderer.toggleFullscreen();

		currentScene.update();
		renderer.render({ currentScene.draw(renderer.width, renderer.height); });
	}
}
