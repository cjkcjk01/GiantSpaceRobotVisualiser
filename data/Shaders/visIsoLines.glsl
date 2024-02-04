/*{
  "CREDIT": "by mojovideotech",
  "CATEGORIES" : [
    "generator"
  ],
  "INPUTS" : [
	{
		"NAME" : 		"rate",
		"TYPE" : 		"float",
		"DEFAULT" : 	0.5,
		"MIN" : 		0.0,
		"MAX" : 		3.0
	},
	{
		"NAME" : 		"scale",
		"TYPE" : 		"float",
		"DEFAULT" : 	20.0,
		"MIN" : 		2.0,
		"MAX" : 		24.0
	},
	{
		"NAME" : 		"edge",
		"TYPE" : 		"float",
		"DEFAULT" : 	0.33,
		"MIN" : 		0.0,
		"MAX" : 		1.5
	},
	{
		"NAME" : 		"gamma",
		"TYPE" : 		"float",
		"DEFAULT" : 	-0.2,
		"MIN" : 		-0.5,
		"MAX" : 		0.25
	},
   	{
		"NAME" : 		"cycle",
		"TYPE" : 		"float",
		"DEFAULT" : 	1.25,
		"MIN" : 		-6.0,
		"MAX" : 		6.0
	},
	{
      "NAME": "style",
      "TYPE": "long",
      "VALUES": [
        0,
        1,
        2,
        3
      ],
      "LABELS": [
        "Greyscale",
        "Color",
        "Glow",
        "Anaglyph"
      ],
      "DEFAULT": 1
	},
   	{
   		"NAME" : 		"invert",
     	"TYPE" : 		"bool",
     	"DEFAULT" : 	false
   	}
  ],
  "ISFVSN" : 2.0
}
*/

////////////////////////////////////////////////////////////////////
// IsoLines  by mojovideotech
//
// based on :
// shadertoy.com\/view\/XdlyzS by FabriceNeyret2
//
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0
////////////////////////////////////////////////////////////////////



#define   twpi    6.2831853   // two pi, 2*pi

// --- noise from procedural pseudo-Perlin ( adapted from IQ ) ---------

#define hash3(p)  fract(sin(1e3*dot(p,vec3(1,57,-13.7)))*4375.5453)     

float noise3( vec3 x , out vec2 g) {
    vec3 p = floor(x),f = fract(x);
    vec3 F = f*f*(3.0-2.0*f);
    float v000 = hash3(p+vec3(0,0,0)), v100 = hash3(p+vec3(1,0,0)),
          v010 = hash3(p+vec3(0,1,0)), v110 = hash3(p+vec3(1,1,0)),
          v001 = hash3(p+vec3(0,0,1)), v101 = hash3(p+vec3(1,0,1)),
          v011 = hash3(p+vec3(0,1,1)), v111 = hash3(p+vec3(1,1,1));
    g.x = 6.*f.x*(1.-f.x)                     
          * mix( mix( v100 - v000, v110 - v010, F.y),
                 mix( v101 - v001, v111 - v011, F.y), F.z);
    g.y = 6.*f.y*(1.-f.y)
          * mix( mix( v010 - v000, v110 - v100, F.x),
                 mix( v011 - v001, v111 - v101, F.x), F.z);
    return mix( mix(mix( v000, v100, F.x),      
                    mix( v010, v110, F.x),F.y),
                mix(mix( v001, v101, F.x),       
                    mix( v011, v111, F.x),F.y), F.z);
}

float noise(vec3 x, out vec2 g) {  
    vec2 g0,g1;
    float n = (noise3(x,g0)+noise3(x+11.5,g1)) / 2.0;
    g = (g0+g1)/2.0;
    return n;
}

void main() {
	float S = (26.0-scale)/RENDERSIZE.y;
    vec2 U = gl_FragCoord.xy * S;
    vec2 g;
    float e = 0.0;
    float n = noise(vec3(U,rate*TIME), g);
    float v = sin(twpi*10.0*n);
    if (style == 2) { e += 0.5 ; } 
    g *= twpi*10.0*cos(twpi*10.0*n)*(S * (edge + e))*sqrt(scale);
    v = atan(min(2.0*abs(v) / (abs(g.x)+abs(g.y)),10.0));
    n = floor(n*20.0)/20.0;
    vec4 col = vec4(0.0,0.0,0.0,1.0);
	if (style ==3) { col += (0.5+0.5*cos((6.5+cycle)*n*vec4(cycle,2.1,-2.1,1.0))); }
		else { col += (0.5+0.5*cos(12.0*n+vec4(cycle,2.1,-2.1,1.0))); }
	if (style == 2) { col = (1.0/v)*col ; } 
		else 	if (edge > 0.0) { col *= clamp(v,0.0,1.0); }	
	if (invert) { col.rgb = 1.0-col.rgb; } 
	if (style == 0) { col = vec4(vec3(float(col.r+col.g+col.b)/3.0), col); }
    gl_FragColor = sqrt(max(col,0.0)+gamma);
}
