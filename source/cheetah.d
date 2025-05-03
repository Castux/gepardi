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
	Vector2 position;
	Vector2 target;

	this()
	{
		position = Vector2(uniform(-10, 10), uniform(-10, 10));
	}

	void addBill(MainScene scene)
	{
		scene.addBill("gepardi1", position, 0.7);
	}
}
