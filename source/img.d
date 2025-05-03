import std.file;
import std.path;
import std.stdio;
import std.string;

import raylib;

class Img
{
	const imgDir = "img";
	static Texture2D[string] textures;

	static loadAll()
	{
		foreach(path; dirEntries("img", "*.{png,jpg}", SpanMode.shallow))
		{
			auto name = path.stripExtension.baseName;
			textures[name] = LoadTexture(path.toStringz);
		}
	}

	static opCall(string name)
	{
		return textures[name];
	}
}
