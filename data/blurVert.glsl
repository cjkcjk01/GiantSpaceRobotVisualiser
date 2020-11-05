uniform mat4 transform;

attribute vec4 vertex;
attribute vec2 texCoord;

varying vec2 vertTexCoord; 

void main() { 
	vertTexCoord = vec2(texCoord.x, 1.0 - texCoord.y); 
	gl_Position = transform * vertex;
}
