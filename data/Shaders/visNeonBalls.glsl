/*{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/MsyGRm by phi16.  Neon effect (simple additive-composition)",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": 0,
            "LABEL": "Slider1",
            "MAX": 6.26,
            "MIN": 0,
            "NAME": "Slider1",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "Slider2",
            "MAX": 1.04,
            "MIN": 0,
            "NAME": "Slider2",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "Slider3",
            "MAX": 6.26,
            "MIN": 0,
            "NAME": "Slider3",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "Slider4",
            "MAX": 25,
            "MIN": 0,
            "NAME": "Slider4",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "Slider5",
            "MAX": 4,
            "MIN": 0,
            "NAME": "Slider5",
            "TYPE": "float"
        },
        {
            "DEFAULT": 2.5,
            "LABEL": "Slider6",
            "MAX": 5,
            "MIN": 0,
            "NAME": "Slider6",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "Slider7",
            "MAX": 10,
            "MIN": 0,
            "NAME": "Slider7",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/


float stepping(float t){
    if(t<0.)return -1.+pow(1.+t,2.);
    else return 1.-pow(1.-t,2.);
}
void main() {



	vec2 uv = (gl_FragCoord.xy*2.-RENDERSIZE.xy)/RENDERSIZE.y;
    gl_FragColor = vec4(0);
    uv = normalize(uv) * length(uv);
    for(int i=0;i<12;i++){
        float t = Slider1 + float(i)*3.141592/12.*(5.+1.*stepping(sin(Slider2*3.)));
        vec2 p = vec2(cos(t),sin(t));
        p *= cos(Slider3 + float(i)*3.141592*cos(Slider4/8.));
        vec3 col = cos(vec3(0,1,-1)*3.141592*2./3.+3.141925*(Slider5/2.+float(i)/5.)) * 0.5 + 0.5;
        gl_FragColor += vec4(0.05/length(uv-p*Slider7)*col,1.0);
    }
    gl_FragColor.xyz = pow(gl_FragColor.xyz,vec3(Slider6));
    gl_FragColor.w = 1.0;
}
