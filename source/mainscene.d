import std.stdio;
import std.math;
import std.format;
import std.conv;
import std.string;
import std.random;
import std.algorithm;
import std.range;
import std.array;

import raylib;

import interfaces;
import colors;
import res;
import cheetah;

import bill;

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

	const cubLoosingRate = 15.0;
	double nextLostCub = 0.0;

	double cubMessageOpacity = 0.0;

	const cameraLow = 1.75;
	const cameraHigh = 3.15;

	bool gameOver;
	double gameStartTime;
	double gameOverTime;

	this()
	{
		resetGame();
	}

	void resetGame()
	{
		camera.position = Vector3(0.0f, cameraLow, 4.0f);    // Camera position
		camera.target = Vector3(0.0f, 2.0f, 0.0f);      // Camera looking at point
		camera.up = Vector3(0.0f, 1.0f, 0.0f);          // Camera up vector (rotation towards target)
		camera.fovy = 60.0f;                                // Camera field-of-view Y
		camera.projection = CameraProjection.CAMERA_PERSPECTIVE;             // Camera projection type

		DisableCursor();

		cheetahs = [];
		foreach(_; 0 .. 10)
			cheetahs ~= new Cheetah();

		nextLostCub = 0.0;
		updateNextLostCubTime();

	 	gameOver = false;
		gameStartTime = GetTime();
		gameOverTime = double.nan;
	}

	Vector2 cpos()
	{
		return Vector2(camera.position.x, camera.position.z);
	}

	private void updateTreePos()
	{
		trees = [];

		const dn = 400;
		const space = 30;
		int centerx = cpos.x.quantize(space).to!int;
		int centery = cpos.y.quantize(space).to!int;

		foreach(x; iota(centerx - dn, centerx + dn, space))
		foreach(y; iota(centery - dn, centery + dn, space))
		{
			auto h1 = hash2d(x, y);
			auto h2 = hash2d(5 * x, 17 * y) * space * 0.75;
			auto h3 = hash2d(27 * x, 87 * y) * space * 0.75;
			auto flip = hash2d(11 * x, 51 * y) < 0.5;

			int id = [1,1,1,2,3,4][(hash2d(13 * x, 61 * y) * 6).floor.to!int];

			auto size = 4.5 + h3 * 0.8;
			trees ~= Tree(id, Vector2(x + h1, y + h2), flip, size);
		}
	}

	void handleTreeCollision()
	{
		foreach(t; trees)
		{
			auto margin = Cheetah.foundRadius * 0.8;
			auto delta = cpos - t.pos;
			auto dist = Vector2Length(delta);
			if (dist < margin)
			{
				delta = delta / dist * margin;
				auto cpos2 = t.pos + delta;
				camera.position.x = cpos2.x;
				camera.position.z = cpos2.y;
			}
		}
	}

	void updateNextLostCubTime()
	{
		// Progressive difficulty: from 1.0 to 0.33
		auto factor = 1.0 - cheetahs.count!"a.lost".to!double / cheetahs.count / 3.0;

		if (nextLostCub == 0.0)
			nextLostCub = GetTime() + 5.0;
		else
			nextLostCub = GetTime() + cubLoosingRate * uniform(0.5, 1.5) * factor;

		writefln("Next lost: %f", nextLostCub);
	}

	void updateCamera()
	{
		auto standing = actionButtonDown;

		auto target = standing ? cameraHigh : cameraLow;
		auto delta = (target - camera.position.y) * GetFrameTime() * 8.0;

		camera.position.y += delta;
		camera.target.y += delta;

		if (!standing)
			UpdateCamera(&camera, CameraMode.CAMERA_FIRST_PERSON);
	}

	void update()
	{
		if (!gameOver)
		{
			updateCamera();
			updateTreePos();
			handleTreeCollision();
		}

		if (GetTime() > nextLostCub)
		{
			auto notLost = cheetahs.filter!"!a.lost".array;
			if (notLost.length != 0)
			{
				notLost.choice.getLost();
				writeln("Oh no, a cub got lost!");

				setMessage(lostMessage);
				updateNextLostCubTime();
			}
		}

		cubMessageOpacity -= GetFrameTime() * 1.0 / 2.0;
		if (cubMessageOpacity < 0.0) cubMessageOpacity = 0.0;

		foreach(c; cheetahs)
		{
			auto found = c.update(cpos);
			if (found)
				setMessage(foundMessage);
		}

		checkEndGame();

		if (gameOver && actionButtonDown)
			resetGame();

		if (!IsMusicStreamPlaying(Res.music))
			PlayMusicStream(Res.music);
		else
			UpdateMusicStream(Res.music);
	}

	void addBill(string img, Vector2 pos, double scale, bool flip = false, Color color = Colors.WHITE)
	{
		auto pos3 = Vector3(pos.x, scale / 2, pos.y);
		auto dist = Vector2DistanceSqr(pos, Vector2(camera.position.x, camera.position.z));
		bills ~= BillboardInfo(Img(img), pos3, scale, flip, color, dist);
	}

	void addBill(string img, Vector3 pos, double scale, bool flip = false, Color color = Colors.WHITE)
	{
		auto pos3 = Vector3(pos.x, pos.y + scale / 2, pos.z);
		auto dist = Vector2DistanceSqr(Vector2(pos.x, pos.z), Vector2(camera.position.x, camera.position.z));
		bills ~= BillboardInfo(Img(img), pos3, scale, flip, color, dist);
	}

	private void addGrass()
	{
		const dn = 100;
		const space = 3;
		int centerx = camera.position.x.quantize(space).to!int;
		int centery = camera.position.z.quantize(space).to!int;

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

	void drawLostCubsCounter()
	{
		const width = 60.0;
		auto img = Img("cubface");
		auto scale = width / img.width;

		foreach(i; 0 .. cheetahs.count!"a.lost")
		{
			DrawTextureEx(
				Img("cubface"),
				Vector2((i + 0.5) * width, width * 0.5),
				rotation: 0.0,
				scale: scale,
				Colors.WHITE
			);
		}
	}

	const lostMessage = "Oh no, a cub got lost!";
	const foundMessage = "Yay, found!";
	string message;

	void setMessage(string s)
	{
		message = s;
		cubMessageOpacity = 1.0;
	}

	void drawMessage()
	{
		if (gameOver || cubMessageOpacity == 0.0) return;

		const size = 90.0;
		const spacing = 0.0;
		auto textSize = MeasureTextEx(Res.font, message.toStringz, size, spacing);    // Measure string size for Font

		auto displaySize = IsWindowFullscreen() ?
			Vector2(GetRenderWidth(), GetRenderHeight()) :
			Vector2(GetScreenWidth(), GetScreenHeight());

		auto pos = displaySize / 2.0 - textSize / 2.0;
		DrawTextEx(Res.font, message.toStringz, pos, size, spacing, ColorAlpha(Palette.blue, cubMessageOpacity));
	}

	const gameOverMessage = "Oh no, all the cubs are lost!\nScore: %d";

	void drawGameOver()
	{
		if (!gameOver) return;

		auto msg = gameOverMessage.format((gameOverTime - gameStartTime).to!int);

		const size = 90.0;
		const spacing = 0.0;
		auto textSize = MeasureTextEx(Res.font, msg.toStringz, size, spacing);    // Measure string size for Font

		auto displaySize = IsWindowFullscreen() ?
			Vector2(GetRenderWidth(), GetRenderHeight()) :
			Vector2(GetScreenWidth(), GetScreenHeight());

		auto pos = displaySize / 2.0 - textSize / 2.0;
		DrawTextEx(Res.font, msg.toStringz, pos, size, spacing, Palette.brown);
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

			auto planeCenter = camera.position;
			planeCenter.y = 0.0;
			DrawPlane(planeCenter, Vector2(2000, 2000), Palette.ochre);

			drawBillboard3(camera, Img("sun"),
				camera.position + Vector3(100, 600, 600),
				200.0,
				Palette.yellow
			);

			drawBillboard2(camera, Img("mountain"),
				camera.position + Vector3(500, 140, -500),
				300.0,
				Palette.ochre
			);
			drawBillboard2(camera, Img("mountain"),
				camera.position + Vector3(-200, 100, -300),
				300.0,
				Palette.ochre
			);

			foreach(bill; bills)
			{
				auto size = Vector2(bill.scale, bill.scale);
				auto rec = Rectangle(0, 0, bill.img.width, bill.img.height);
				if (bill.flip)
					rec.width *= -1;
				DrawBillboardRec(camera, bill.img, rec, bill.pos, size, bill.color);
			}
		EndMode3D();

		drawLostCubsCounter();
		drawMessage();
		drawGameOver();

		if (IsKeyDown(KeyboardKey.KEY_P))
			DrawFPS(20, 20);
	}

	void checkEndGame()
	{
		if (!cheetahs.all!"a.lost" || gameOver)
			return;

		gameOver = true;
		gameOverTime = GetTime();
	}

	bool actionButtonDown()
	{
		return IsKeyDown(KeyboardKey.KEY_SPACE)
			|| IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN);
	}
}
