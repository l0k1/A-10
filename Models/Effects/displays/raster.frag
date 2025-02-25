#version 120

uniform float osg_SimulationTime;

uniform sampler2D BaseTex;
uniform sampler2D DirtTex;
uniform sampler2D Scanlines;

uniform int display_enabled;

float SCANTHICK = 2.0;
float INTENSITY = 0.15;
float BRIGHTBOOST = 0.15;
float DISTORTION = 0.00;

vec2 distort(vec2 position)
{
	position = vec2(2.0 * position - 1.0);
	position = position /(1.0 - DISTORTION * length(position));
	position =(position + 1.0) * 0.5;
	return position;
}

vec3 scanline(vec3 texel)
{
	vec3 scanlines = texture2D(Scanlines, vec2(310, 250)*gl_TexCoord[0].xy).rgb;
	texel *= 1.5*scanlines;
	return texel;
}

void main()
{
	vec3 texel = vec3(0.0, 0.0, 0.0);
	float dirt = 0.3*texture2D(DirtTex, gl_TexCoord[0].xy).a;

	// crt-effect
	if(display_enabled > 0) {
		vec2 position = distort(gl_TexCoord[0].xy);

		if(position.x > 0.0 && position.y > 0.0 && position.x < 1.0 && position.y < 1.0) {
			texel = texture2D(BaseTex, position).rgb;
			texel = scanline(texel);
		}
	}
	texel = max(texel, vec3(dirt));
	gl_FragColor = vec4(texel, 1.0);
}
