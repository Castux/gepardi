import std.stdio;
import std.math;
import std.format;
import std.conv;
import std.string;
import std.random;
import std.algorithm;
import std.range;

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

const M1 = 1597334677U;     //1719413*929
const M2 = 3812015801U;     //140473*2467*11

float hash2d(int x, int y)
{
	x *= M1;
	y *= M2;

	uint n = (x ^ y) * M1;

	return n * 1.0 / uint.max;
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

		void addBill(string img, Vector2 pos, double scale, Color color = Colors.WHITE)
		{
			auto pos3 = Vector3(pos.x, scale / 2, pos.y);
			auto dist = Vector3DistanceSqr(pos3, camera.position);
			bills ~= BillboardInfo(Img(img), pos3, scale, color, dist);
		}

		addBill("gepardi1", Vector2(0,0), 0.7);
		addBill("gepardi1", Vector2(10,0), 0.6);
		addBill("gepardi1", Vector2(0,12), 0.8);

		const dn = 100;
		const space = 3;
		int centerx = camera.position.x.floor.to!int;
		int centery = camera.position.y.floor.to!int;

		centerx -= centerx % 3;
		centery -= centery % 3;

		foreach(x; iota(centerx - dn, centerx + dn, 3))
		foreach(y; iota(centery - dn, centery + dn, 3))
		{
			auto h1 = hash2d(x, y);
			auto h2 = hash2d(2 * x, 13 * y) * space / 2;
			auto h3 = hash2d(27 * x, 87 * y) * space / 2;

			auto size = 0.5 + h3 * 1.7;
			addBill("grass", Vector2(x + h1, y + h2), size);
		}

		bills.sort!((a,b) => a.dist > b.dist);

		ClearBackground(Palette.sky);

		BeginMode3D(camera);
			DrawPlane(Vector3(0.0f, 0.0f, 0.0f), Vector2(1024, 1024), Palette.ochre);

			foreach(bill; bills)
				DrawBillboard(camera, bill.img, bill.pos, bill.scale, Palette.yellow);


		EndMode3D();


		DrawFPS(20, 20);
	}
}
