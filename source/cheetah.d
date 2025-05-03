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
import mainscene;

class Cheetah
{
	const margin = 20.0;
	const speed = 3.0;

	Vector2 position;
	Vector2 target;
	float height = 0.0;
	float vspeed = 0.0;

	void update(Vector2 playerPos)
	{
		auto dt = GetFrameTime();

		// Get to target
		if (Vector2Distance(target, position) > 0.5)
		{
			if (height <= 0.0)
			{
				vspeed = speed * 1.1 + uniform(-0.3, 0.3);
			}
			else
			{
				vspeed -= 8.0 * dt;
			}

			height += vspeed * dt;

			auto direction = Vector2Normalize(target - position);
			position += direction * speed * dt;
		}

		// Get new target, close to player
		else
		{
			target = Vector2(
				playerPos.x + uniform(-margin/2, margin/2),
				playerPos.y + uniform(-margin/2, margin/2)
			);
		}
	}

	void addBill(MainScene scene)
	{
		scene.addBill("gepardi1", Vector3(position.x, height, position.y), 0.7);
	}
}
