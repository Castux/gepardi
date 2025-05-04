import std.algorithm;
import std.conv;
import std.format;
import std.math;
import std.stdio;
import std.string;

import raylib;

import interfaces;

class BasicRenderer : Renderer
{
	const initWidth = 800;
	const initHeight = 600;

	this(string title)
	{
		SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);
		SetTraceLogLevel(TraceLogLevel.LOG_WARNING);
		//SetTargetFPS(60);

		InitWindow(initWidth, initHeight, title.toStringz);
		InitAudioDevice();
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
