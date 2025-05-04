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
import res;
import mainscene;

class Cheetah
{
	const roamRadius = 10.0;
	const speed = 3.0;
	const getLostRadius = 35.0;
	const foundRadius = 2.0;

	Vector2 position;
	Vector2 target;
	float height = 0.0;
	float vspeed = 0.0;

	bool flip;

	bool lost;

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

			auto toPlayer = playerPos - position;
			auto cross = direction.x * toPlayer.y - direction.y * toPlayer.x;

			flip = cross < 0;
		}

		// Get new target, close to player (unless currently lost)
		else if (!lost)
		{
			target = Vector2(
				playerPos.x + uniform(-roamRadius, roamRadius),
				playerPos.y + uniform(-roamRadius, roamRadius)
			);
		}

		else // lost and at target: jump higher
		{
			if (height <= 0.0)
			{
				vspeed = speed * 2.3 + uniform(-0.3, 0.3);
			}
			else
			{
				vspeed -= 10.0 * dt;
			}

			height += vspeed * dt;
		}

		// In any case, being close to a lost cub finds it

		if (lost && Vector2Distance(playerPos, position) < foundRadius)
		{
			lost = false;
			writeln("A cub was found!");
		}
	}

	void addBill(MainScene scene)
	{
		scene.addBill("gepardi1", Vector3(position.x, height, position.y), 0.7, flip);
	}

	void getLost()
	{
		target = Vector2(
			position.x + uniform(-getLostRadius, getLostRadius),
			position.y + uniform(-getLostRadius, getLostRadius)
		);

		lost = true;
	}
}
