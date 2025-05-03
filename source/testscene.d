import std.stdio;
import std.math;
import std.format;
import std.conv;
import std.string;

import raylib;

import interfaces;
import colors;
import img;

class TestScene : Scene
{
	Camera3D camera;

	this()
	{
		camera.position = Vector3(0.0f, 2.0f, 4.0f);    // Camera position
		camera.target = Vector3(0.0f, 2.0f, 0.0f);      // Camera looking at point
		camera.up = Vector3(0.0f, 1.0f, 0.0f);          // Camera up vector (rotation towards target)
		camera.fovy = 60.0f;                                // Camera field-of-view Y
		camera.projection = CameraProjection.CAMERA_PERSPECTIVE;             // Camera projection type

		DisableCursor();
	}

	void update()
	{
		UpdateCamera(&camera, CameraMode.CAMERA_FIRST_PERSON);
	}

	void draw(int width, int height)
	{
		ClearBackground(Palette.sky);

		BeginMode3D(camera);
			DrawPlane(Vector3(0.0f, 0.0f, 0.0f), Vector2(1024, 1024), Palette.ochre);
			DrawBillboard(camera, Img("gepardi1"), Vector3(0,1,0), 2.0f, Colors.WHITE);
		EndMode3D();


		DrawFPS(20, 20);
	}
}
