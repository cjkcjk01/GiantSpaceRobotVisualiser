precision highp float;

uniform sampler2D texture;
uniform float viewAngle;
uniform float rotation;

varying vec4 vertColor;
varying vec4 vertTexCoord;
varying vec4 pos;

void main() {
	//shift center of the vertTex to the bottom left corner
	vec2 newPos = vertTexCoord.xy - vec2(0.5);
    
	//find the distance of newPos from the bottom left corner
	float distance = length(newPos.xy);
	//find the angle of newPos in relation to the bottom left corner
	float angle = atan(newPos.y, newPos.x);
	
	//map every viewAngle in angle to viewAngle/2, 0 and viewAngle/2
	//e.g. viewAngle = 90 degrees, angle = 0 -> angle = 45, angle = 45 -> angle = 0, angle = 90 -> angle = 45, angle = 135 -> angle = 0, angle = 180 -> angle = 45
	angle = abs(mod(angle, viewAngle) - viewAngle/2.0);
	//add rotation of kaleidoscope to angle
	angle += rotation;
	//set newPos to the position of the new angle
	newPos = distance * vec2(cos(angle), sin(angle));
	//move center of newPos to the center of the screen
	newPos += vec2(0.5);
	//set gl_FragColor to color of the pixel at newPos 
    gl_FragColor = texture2D(texture, newPos) * vertColor;
}