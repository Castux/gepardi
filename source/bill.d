import std.math;
import raylib;

// Draw billboards based on player position, not rotation

void drawBillboard2(Camera camera, Texture2D texture, Vector3 position, float scale, Color tint)
{
	Rectangle source = { 0.0f, 0.0f, cast(float)texture.width, cast(float)texture.height };

	drawBillboard2Rec(camera, texture, source, position, Vector2(scale*abs(cast(float)source.width/source.height), scale ), tint);
}

// Draw a billboard (part of a texture defined by a rectangle)
void drawBillboard2Rec(Camera camera, Texture2D texture, Rectangle source, Vector3 position, Vector2 size, Color tint)
{
	// NOTE: Billboard locked on axis-Y
	Vector3 up = { 0.0f, 1.0f, 0.0f };

	drawBillboard2Pro(camera, texture, source, position, up, size, Vector2Scale(size, 0.5), 0.0f, tint);
}

void drawBillboard2Pro(Camera camera, Texture2D texture, Rectangle source, Vector3 position, Vector3 up, Vector2 size, Vector2 origin, float rotation, Color tint)
{
	// Compute the up vector and the right vector
	Matrix matView = MatrixLookAt(camera.position, position, camera.up);
	Vector3 right = { matView.m0, matView.m4, matView.m8 };
	right = Vector3Scale(right, size.x);
	up = Vector3Scale(up, size.y);

	// Flip the content of the billboard while maintaining the counterclockwise edge rendering order
	if (size.x < 0.0f)
	{
		source.x += size.x;
		source.width *= -1.0;
		right = Vector3Negate(right);
		origin.x *= -1.0f;
	}
	if (size.y < 0.0f)
	{
		source.y += size.y;
		source.height *= -1.0;
		up = Vector3Negate(up);
		origin.y *= -1.0f;
	}

	// Draw the texture region described by source on the following rectangle in 3D space:
	//
	//                size.x          <--.
	//  3 ^---------------------------+ 2 \ rotation
	//    |                           |   /
	//    |                           |
	//    |   origin.x   position     |
	// up |..............             | size.y
	//    |             .             |
	//    |             . origin.y    |
	//    |             .             |
	//  0 +---------------------------> 1
	//                right
	Vector3 forward;
	if (rotation != 0.0) forward = Vector3CrossProduct(right, up);

	Vector3 origin3D = Vector3Add(Vector3Scale(Vector3Normalize(right), origin.x), Vector3Scale(Vector3Normalize(up), origin.y));

	Vector3[4] points;
	points[0] = Vector3Zero();
	points[1] = right;
	points[2] = Vector3Add(up, right);
	points[3] = up;

	for (int i = 0; i < 4; i++)
	{
		points[i] = Vector3Subtract(points[i], origin3D);
		if (rotation != 0.0) points[i] = Vector3RotateByAxisAngle(points[i], forward, rotation*DEG2RAD);
		points[i] = Vector3Add(points[i], position);
	}

	Vector2[4] texcoords;
	texcoords[0] = Vector2( cast(float)source.x/texture.width, cast(float)(source.y + source.height)/texture.height );
	texcoords[1] = Vector2( cast(float)(source.x + source.width)/texture.width, cast(float)(source.y + source.height)/texture.height );
	texcoords[2] = Vector2( cast(float)(source.x + source.width)/texture.width, cast(float)source.y/texture.height );
	texcoords[3] = Vector2( cast(float)source.x/texture.width, cast(float)source.y/texture.height );

	rlSetTexture(texture.id);
	rlBegin(RL_QUADS);

		rlColor4ub(tint.r, tint.g, tint.b, tint.a);
		for (int i = 0; i < 4; i++)
		{
			rlTexCoord2f(texcoords[i].x, texcoords[i].y);
			rlVertex3f(points[i].x, points[i].y, points[i].z);
		}

	rlEnd();
	rlSetTexture(0);
}
