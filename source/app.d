import std.stdio;
import std.math;
import std.format;
import std.conv;
import std.string;

import raylib;

import renderer;

void main()
{
	auto renderer = new Renderer();

	while (!WindowShouldClose())
	{
		if (IsKeyPressed(KeyboardKey.KEY_F))
			renderer.toggleFullscreen();

		renderer.render({
			ClearBackground(Colors.SKYBLUE);

			DrawCircle(
				(renderer.width / 2.0 + sin(GetTime() / 6.0) * 10.0).to!int,
				(renderer.height / 2.0 + cos(GetTime() / 4.0) * 15.0).to!int,
				(sin(GetTime() / 6.0) + 1.0) * 20.0,
				Colors.RED
			);
			DrawRectanglePro(Rectangle(40, 40, 20, 20), Vector2(10, 10), GetTime() * 30, Colors.GOLD);
			DrawText(("FPS: %d".format(GetFPS())).toStringz, 3, 3, 0, Colors.WHITE);
		});
	}
}
