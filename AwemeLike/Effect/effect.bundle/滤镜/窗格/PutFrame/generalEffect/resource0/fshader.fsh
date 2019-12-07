precision highp float;

uniform sampler2D grabInputImageTexture;
uniform float radius;
uniform float texelWidth;
varying highp vec2 textureCoordinate;

void main() {
    
	vec2 tc = textureCoordinate;
	float blur = radius * texelWidth; 

    vec4 sum = vec4(0.0);

	sum += texture2D(grabInputImageTexture, vec2(tc.x - 4.0*blur, tc.y)) * 0.0162162162;
	sum += texture2D(grabInputImageTexture, vec2(tc.x - 3.0*blur, tc.y)) * 0.0540540541;
	sum += texture2D(grabInputImageTexture, vec2(tc.x - 2.0*blur, tc.y)) * 0.1216216216;
	sum += texture2D(grabInputImageTexture, vec2(tc.x - 1.0*blur, tc.y)) * 0.1945945946;
	
	sum += texture2D(grabInputImageTexture, vec2(tc.x, tc.y)) * 0.2270270270;
	
	sum += texture2D(grabInputImageTexture, vec2(tc.x + 1.0*blur, tc.y)) * 0.1945945946;
	sum += texture2D(grabInputImageTexture, vec2(tc.x + 2.0*blur, tc.y)) * 0.1216216216;
	sum += texture2D(grabInputImageTexture, vec2(tc.x + 3.0*blur, tc.y)) * 0.0540540541;
	sum += texture2D(grabInputImageTexture, vec2(tc.x + 4.0*blur, tc.y)) * 0.0162162162;

	gl_FragColor = sum;
}
