import std.stdio;
import std.math;
import std.format;
import std.conv;
import std.string;

import raylib;

import interfaces;

class TestScene : Scene
{
	int count = 0;

	void update()
	{
		count++;
	}

	void draw(int width, int height)
	{
		ClearBackground(Colors.SKYBLUE);

		DrawCircle(
			(width / 2.0 + sin(GetTime() / 6.0) * 10.0).to!int,
			(height / 2.0 + cos(GetTime() / 4.0) * 15.0).to!int,
			(sin(GetTime() / 6.0) + 1.0) * 20.0,
			Colors.RED
		);
		DrawRectanglePro(Rectangle(40, 40, 20, 20), Vector2(10, 10), GetTime() * 30, Colors.GOLD);
		DrawFPS(20, 20);
		DrawText("Count: %d".format(count).toStringz, 20, 40, 20, Colors.DARKGREEN);
	}
}
