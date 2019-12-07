precision highp float;
uniform sampler2D inputImageTexture;
uniform float texelWidthOffset;
uniform float texelHeightOffset;

varying highp vec2 blurCoordinates[9];

void main() {
    lowp vec4 sum = vec4(0.0);
    
    sum += texture2D(inputImageTexture, blurCoordinates[0]) * 0.133571;
    sum += texture2D(inputImageTexture, blurCoordinates[1]) * 0.233308;
    sum += texture2D(inputImageTexture, blurCoordinates[2]) * 0.233308;
    sum += texture2D(inputImageTexture, blurCoordinates[3]) * 0.135928;
    sum += texture2D(inputImageTexture, blurCoordinates[4]) * 0.135928;
    sum += texture2D(inputImageTexture, blurCoordinates[5]) * 0.051383;
    sum += texture2D(inputImageTexture, blurCoordinates[6]) * 0.051383;
    sum += texture2D(inputImageTexture, blurCoordinates[7]) * 0.012595;
    sum += texture2D(inputImageTexture, blurCoordinates[8]) * 0.012595;
    
	gl_FragColor = sum;
}
