uniform sampler2D texture; 
uniform vec2 texOffset; 
uniform float blurDegree; 

varying vec2 vertTexCoord; 

void main() { 
  gl_FragColor  = texture2D(texture, vertTexCoord - blurDegree *  texOffset); 
  gl_FragColor += texture2D(texture, vertTexCoord - blurDegree * vec2(texOffset.x, -texOffset.y));
  gl_FragColor += texture2D(texture, vertTexCoord + blurDegree * vec2(texOffset.x, -texOffset.y)); 
  gl_FragColor += texture2D(texture, vertTexCoord + blurDegree * texOffset); 
  gl_FragColor *= 0.25; 
}
