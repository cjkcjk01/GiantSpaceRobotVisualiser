////////////////////////////////////////////////////////////
// CandyWarp  by mojovideotech
//
// based on :  
// glslsandbox.com/e#38710.0
// Posted by Trisomie21
// modified by @hintz
//
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0
////////////////////////////////////////////////////////////

uniform float scale;     // Default : 84.0  Min :  10.0 Max : 100.0
uniform float cycle;     // Default :  0.4  Min :  0.01 Max :   0.99
uniform float thickness; // Default :  0.1  Min : -0.5  Max :   1.0
uniform float loops;     // Default : 61.0  Min : 10.0  Max : 100.0
uniform float warp;      // Default :  2.5  Min : -5.0  Max :   5.0
uniform float hue;       // Default :  0.33 Min : -0.5  Max :   0.5
uniform float tint;      // Default :  0.1  Min : -0.5  Max :   0.5
uniform float rate;      // Default :  1.25 Min : -3.0  Max :   3.0
//uniform boolean invert;

uniform vec2 iResolution;
uniform float time;


void main(void)
{
	float s = iResolution.y / scale;
	float radius = iResolution.x / cycle;
	float gap = s * (1.0 - thickness);
	vec2 pos = gl_FragCoord.xy - iResolution.xy * 0.5;
	float d = length(pos);
	float T = time * rate;
	d += warp * (sin(pos.y * 0.25 / s + T) * sin(pos.x * 0.25 / s + T * 0.5)) * s * 5.0;
	float v = mod(d + radius / (loops * 2.0), radius / loops);
	v = abs(v - radius / (loops * 2.0));
	v = clamp(v - gap, 0.0, 1.0);
	d /= radius - T;
	vec3 m = fract((d - 1.0) * vec3(loops * hue, -loops, loops * tint) * 0.5);
	//if (invert) {gl_FragColor = vec4(m / v, 1.0);}
	//else {
	gl_FragColor = vec4(m * v, 1.0);
//}
}