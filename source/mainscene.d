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
import cheetah;

struct BillboardInfo
{
	Texture2D img;
	Vector3 pos;
	double scale;
	bool flip;
	Color color;
	double dist;
}

struct Tree
{
	int id;
	Vector2 pos;
	bool flip;
	float size;
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

class MainScene : Scene
{
	Camera3D camera;
	BillboardInfo[] bills;

	Tree[] trees;
	Cheetah[] cheetahs;

	this()
	{
		camera.position = Vector3(0.0f, 1.75f, 4.0f);    // Camera position
		camera.target = Vector3(0.0f, 2.0f, 0.0f);      // Camera looking at point
		camera.up = Vector3(0.0f, 1.0f, 0.0f);          // Camera up vector (rotation towards target)
		camera.fovy = 60.0f;                                // Camera field-of-view Y
		camera.projection = CameraProjection.CAMERA_PERSPECTIVE;             // Camera projection type

		DisableCursor();

		foreach(_; 0 .. 10)
			cheetahs ~= new Cheetah();
	}

	Vector2 cpos()
	{
		return Vector2(camera.position.x, camera.position.z);
	}

	private void updateTreePos()
	{
		trees = [];

		const dn = 200;
		const space = 25;
		int centerx = cpos.x.floor.to!int;
		int centery = cpos.y.floor.to!int;

		centerx -= centerx % space;
		centery -= centery % space;

		foreach(x; iota(centerx - dn, centerx + dn, space))
		foreach(y; iota(centery - dn, centery + dn, space))
		{
			auto h1 = hash2d(x, y);
			auto h2 = hash2d(5 * x, 17 * y) * space / 2;
			auto h3 = hash2d(27 * x, 87 * y) * space / 2;
			auto flip = hash2d(11 * x, 51 * y) < 0.5;

			int id = [1,1,1,2,3,4][(hash2d(13 * x, 61 * y) * 6).floor.to!int];

			auto size = 4.5 + h3 * 1.0;
			trees ~= Tree(id, Vector2(x + h1, y + h2), flip, size);
		}
	}

	void handleTreeCollision()
	{
		const margin = 2.0;

		foreach(t; trees)
		{
			auto delta = cpos - t.pos;
			auto dist = Vector2Length(delta);
			if (dist < margin)
			{
				delta = delta / dist * margin;
				auto cpos2 = t.pos + delta;
				camera.position.x = cpos.x;
				camera.position.z = cpos.y;
			}
		}
	}

	void update()
	{
		UpdateCamera(&camera, CameraMode.CAMERA_FIRST_PERSON);
		updateTreePos();
		handleTreeCollision();

		foreach(c; cheetahs)
			c.update(cpos);
	}

	void addBill(string img, Vector2 pos, double scale, bool flip = false, Color color = Colors.WHITE)
	{
		auto pos3 = Vector3(pos.x, scale / 2, pos.y);
		auto dist = Vector2DistanceSqr(pos, Vector2(camera.position.x, camera.position.z));
		bills ~= BillboardInfo(Img(img), pos3, scale, flip, color, dist);
	}

	private void addGrass()
	{
		const dn = 100;
		const space = 3;
		int centerx = camera.position.x.floor.to!int;
		int centery = camera.position.z.floor.to!int;

		centerx -= centerx % space;
		centery -= centery % space;

		foreach(x; iota(centerx - dn, centerx + dn, space))
		foreach(y; iota(centery - dn, centery + dn, space))
		{
			auto h1 = hash2d(x, y);
			auto h2 = hash2d(2 * x, 13 * y) * space / 2;
			auto h3 = hash2d(27 * x, 87 * y) * space / 2;
			auto flip = hash2d(7 * x, 19 * y) < 0.5;

			auto size = 0.5 + h3 * 1.7;
			addBill("grass", Vector2(x + h1, y + h2), size, flip, Palette.yellow);
		}
	}

	void draw(int width, int height)
	{
		bills = [];

		addGrass();

		foreach(t; trees)
			addBill("tree" ~ t.id.to!string, t.pos, t.size, t.flip);

		foreach(c; cheetahs)
			c.addBill(this);

		bills.sort!((a,b) => a.dist > b.dist);

		ClearBackground(Palette.sky);

		BeginMode3D(camera);
			DrawPlane(Vector3(0.0f, 0.0f, 0.0f), Vector2(1024, 1024), Palette.ochre);

			foreach(bill; bills)
			{
				auto size = Vector2(bill.scale, bill.scale);
				auto rec = Rectangle(0, 0, bill.img.width, bill.img.height);
				if (bill.flip)
					rec.width *= -1;
				DrawBillboardRec(camera, bill.img, rec, bill.pos, size, bill.color);
			}


		EndMode3D();


		DrawFPS(20, 20);
	}
}
