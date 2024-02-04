/*{
  "CREDIT": "by mojovideotech",
  "CATEGORIES": [
    "generator",
    "rainbow",
    "circular",
    "rotation"
  ],
  "DESCRIPTION": "",
  "ISFVSN" : "2",
    "INPUTS": [
    {
        "NAME" :    "scale",
        "TYPE" :    "float",
        "DEFAULT" : 1.0,
        "MIN" :     0.1,
        "MAX" :     2.0
    },
    {
        "NAME" :    "thickness",
        "TYPE" :    "float",
        "DEFAULT" : 1.75,
        "MIN" :     0.5,
        "MAX" :     2.0
    },
    {
        "NAME" :    "twists",
        "TYPE" :    "float",
        "DEFAULT" : 1.0,
        "MIN" :     1.0,
        "MAX" :     5.0
    },
    {
        "NAME" :    "rate",
        "TYPE" :    "float",
        "DEFAULT" : 1.5,
        "MIN" :     -2.0,
        "MAX" :     2.0
    },
    {
        "NAME" :    "gamma",
        "TYPE" :    "float",
        "DEFAULT" : 0.454545,
        "MIN" :     0.25,
        "MAX" :     1.0
    }
    ]
}

*/

////////////////////////////////////////////////////////////
// RainbowRingCubicTwist  by mojovideotech
//
// based on :
// glslsandbox/e#58416.0
//
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0
////////////////////////////////////////////////////////////


#ifdef GL_ES
precision highp float;
#endif


void main() 
{
    float T = TIME * rate;
    vec2 R = RENDERSIZE;  
    vec2 P = (gl_FragCoord.xy - 0.5*R)*(2.1 - scale);
    vec4 S, E, F;
    P = vec2(length(P) / R.y - 0.333, atan(P.y,P.x));  
    P *= vec2(2.6 - thickness,floor(twists));                                                                                                             ;
    S = 0.08*cos(1.5*vec4(0.0, 1.0, 2.0, 3.0) + T + P.y + sin(P.y)*cos(T));
    E = S.yzwx; 
    F = max(P.x - S, E - P.x);
    gl_FragColor = pow(dot(clamp(F*R.y, 0.0, 1.0), 72.0*(S - E))*(S - 0.1), vec4(gamma));
}