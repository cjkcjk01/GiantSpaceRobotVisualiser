//
// Automatically converted from https:\/\/www.shadertoy.com\/view\/Xlt3R8 by Flyguy.   A 3d
// point based tunnel effect based off the scene from Second Reality.",

uniform float time;
uniform vec2 iResolution;

uniform float circleSize; // Default : 200.0  Min :  1.0  Max : 200.5
uniform float speed;      // Default :   0.2  Min :  0.0  Max :   1.0
uniform float moveX;      // Default :   0.0  Min : -1.0  Max :   1.0
uniform float moveY;      // Default :   0.0  Min : -1.0  Max :   1.0

uniform vec4 pointColorA; // (0.6,0.2,0.2,1.0)
uniform vec4 pointColorB; // (0.8,0.4,0.4,1.0)


//Constants
#define tau 6.2831853071795865

//Parameters
#define tunnelLayers 30

//Square of x
float sq(float x)
{
	return x*x;   
}

//Tunnel/Camera path
vec2 TunnelPath(float x)
{
    vec2 offs = vec2(0, 0);
    
    offs.x = 0.3  * tau * x * moveX;
    offs.y = 0.15 * tau * x * moveY;
    
    return offs;
}

void main() {
    vec2 res = iResolution.xy / iResolution.y;
	vec2 uv = gl_FragCoord.xy / iResolution.y;
    
    uv -= res/2.0;
    
    vec4 color = vec4(0);
    
    float pointSize = circleSize/2.0/iResolution.y;
    
    float camZ = time * speed;
    vec2 camOffs = TunnelPath(camZ);
    
    for(int i = 1;i <= tunnelLayers;i++)
    {
        float pz = 1.0 - (float(i) / float(tunnelLayers));
        
        //Scroll the points towards the screen
        pz -= mod(camZ, 4.0 / float(tunnelLayers));
        
        //Layer x/y offset
        vec2 offs = TunnelPath(camZ + pz) - camOffs;
        
        //Radius of the current ring
        float ringRad = 0.15 * (1.0 / sq(pz * 0.8 + 0.4));
        
        //Only draw points when uv is close to the ring.
        if(abs(length(uv + offs) - ringRad) < pointSize) 
        {
            //Stripes
            vec4 ptColor = (mod(float(i), 2.0) == 0.0) ? pointColorA : pointColorB;
            
            //Distance fade
            float shade = (1.0-pz);
            color = ptColor * shade;
        }
    }
    
	gl_FragColor = color;
}
