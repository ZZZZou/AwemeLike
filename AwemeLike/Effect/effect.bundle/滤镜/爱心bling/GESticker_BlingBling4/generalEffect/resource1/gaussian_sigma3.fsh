precision highp float;
uniform sampler2D inputImageTexture;
uniform float texelWidthOffset;
uniform float texelHeightOffset;
uniform float ratio;

varying highp vec2 blurCoordinates[7];

void main() {
	lowp vec4 sum = vec4(0.0);
    
    sum += texture2D(inputImageTexture, blurCoordinates[0]) * 0.137023;
    sum += texture2D(inputImageTexture, blurCoordinates[1]) * 0.239337;
    sum += texture2D(inputImageTexture, blurCoordinates[2]) * 0.239337;
    sum += texture2D(inputImageTexture, blurCoordinates[3]) * 0.139440;
    sum += texture2D(inputImageTexture, blurCoordinates[4]) * 0.139440;
    sum += texture2D(inputImageTexture, blurCoordinates[5]) * 0.052711;
    sum += texture2D(inputImageTexture, blurCoordinates[6]) * 0.052711;
    
    gl_FragColor = sum * ratio;
}
