import std.file;
import std.path;
import std.stdio;
import std.string;

import raylib;

class Img
{
	const imgDir = "img";
	static Texture2D[string] textures;

	static const fontPath = "res/Lacquer-Regular.ttf";
	static Font font;

	static loadAll()
	{
		foreach(path; dirEntries("img", "*.{png,jpg}", SpanMode.shallow))
		{
			auto name = path.stripExtension.baseName;
			textures[name] = LoadTexture(path.toStringz);
		}

		font = LoadFontEx(fontPath.toStringz, 90, null, 0);
	}

	static opCall(string name)
	{
		return textures[name];
	}
}
