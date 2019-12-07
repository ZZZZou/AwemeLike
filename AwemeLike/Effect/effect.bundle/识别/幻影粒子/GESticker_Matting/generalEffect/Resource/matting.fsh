precision highp float; 

varying vec2 textureCoordinate; 
uniform sampler2D mattingTexture;

void main() {
	gl_FragColor = vec4(texture2D(mattingTexture, textureCoordinate).a);
}
