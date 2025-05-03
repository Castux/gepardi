import std.stdio;
import std.math;
import std.format;
import std.conv;
import std.string;

import raylib;

import renderer;
import interfaces;
import testscene;

void main()
{
	auto renderer = new BasicRenderer("gepardi");
	Scene currentScene = new TestScene();

	while (!WindowShouldClose())
	{
		if (IsKeyPressed(KeyboardKey.KEY_F))
			renderer.toggleFullscreen();

		currentScene.update();
		renderer.render({ currentScene.draw(renderer.width, renderer.height); });
	}
}
