import std.algorithm;
import std.conv;
import std.format;
import std.math;
import std.stdio;

import raylib;

class Renderer
{
	const initWidth = 800;
	const initHeight = 600;

	this()
	{
		SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);
		SetTraceLogLevel(TraceLogLevel.LOG_WARNING);

		//SetTargetFPS(60);

		InitWindow(initWidth, initHeight, "gepardi");
	}

	~this()
	{
		CloseWindow();
	}

	void render(void delegate() cb)
	{
		BeginDrawing();
			cb();
		EndDrawing();
	}

	void toggleFullscreen()
	{
		if (IsWindowFullscreen())
		{
			ToggleFullscreen();
			SetWindowSize(initWidth, initHeight);
		}
		else
		{
			auto monitor = GetCurrentMonitor();
			SetWindowSize(GetMonitorWidth(monitor), GetMonitorHeight(monitor));
			ToggleFullscreen();
		}
	}

	int width() { return GetScreenWidth(); }
	int height() { return GetScreenHeight(); }
}
