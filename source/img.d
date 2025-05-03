import raylib;

class Img
{
	static Texture2D[string] textures;

	static loadAll()
	{
		textures["gepardi1"] = LoadTexture("img/gepardi1.png");
	}

	static opCall(string name)
	{
		return textures[name];
	}
}
