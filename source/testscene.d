import std.stdio;
import std.math;
import std.format;
import std.conv;
import std.string;
import std.random;
import std.algorithm;

import raylib;

import interfaces;
import colors;
import img;

struct BillboardInfo
{
	Texture2D img;
	Vector3 pos;
	double scale;
	Color color;
	double dist;
}


class TestScene : Scene
{
	Camera3D camera;
	Vector3[] grassPos;

	this()
	{
		camera.position = Vector3(0.0f, 1.75f, 4.0f);    // Camera position
		camera.target = Vector3(0.0f, 2.0f, 0.0f);      // Camera looking at point
		camera.up = Vector3(0.0f, 1.0f, 0.0f);          // Camera up vector (rotation towards target)
		camera.fovy = 60.0f;                                // Camera field-of-view Y
		camera.projection = CameraProjection.CAMERA_PERSPECTIVE;             // Camera projection type

		foreach(_; 0 .. 1000)
			grassPos ~= Vector3(uniform(-64.0, 64.0), 1.0, uniform(-64.0, 64.0));

		DisableCursor();
	}

	void update()
	{
		UpdateCamera(&camera, CameraMode.CAMERA_FIRST_PERSON);
	}

	void draw(int width, int height)
	{
		BillboardInfo[] bills;

		void addBill(string img, Vector3 pos, double scale, Color color = Colors.WHITE)
		{
			auto dist = Vector3DistanceSqr(pos, camera.position);
			bills ~= BillboardInfo(Img(img), pos, scale, color, dist);
		}

		addBill("gepardi1", Vector3(0,1,0), 0.7);
		addBill("gepardi1", Vector3(10,1,0), 0.6);
		addBill("gepardi1", Vector3(0,1,12), 0.8);

		foreach(pos; grassPos)
			addBill("grass", pos, 2.0);

		bills.sort!((a,b) => a.dist > b.dist);

		ClearBackground(Palette.sky);

		BeginMode3D(camera);
			DrawPlane(Vector3(0.0f, 0.0f, 0.0f), Vector2(1024, 1024), Palette.ochre);

			foreach(bill; bills)
				DrawBillboard(camera, bill.img, bill.pos, 2.4f, Palette.yellow);


		EndMode3D();


		DrawFPS(20, 20);
	}
}
