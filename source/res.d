import std.file;
import std.path;
import std.stdio;
import std.string;

import raylib;

class Res
{
	const imgDir = "img";
	static Texture2D[string] textures;

	static const fontPath = "res/Lacquer-Regular.ttf";
	static Font font;

	static Music music;

	static loadAll()
	{
		foreach(path; dirEntries("img", "*.{png,jpg}", SpanMode.shallow))
		{
			auto name = path.stripExtension.baseName;
			textures[name] = LoadTexture(path.toStringz);
		}

		font = LoadFontEx(fontPath.toStringz, 90, null, 0);
		music = LoadMusicStream("res/536200__badoink__14yovi.wav");
	}
}

Texture2D Img(string name)
{
	return Res.textures[name];
}
