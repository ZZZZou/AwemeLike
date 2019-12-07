precision highp float;
uniform sampler2D inputImageTexture;

varying highp vec2 blurCoordinates[11];
uniform float ratio;


void main() {
    lowp vec4 sum = vec4(0.0);
    sum += texture2D(inputImageTexture, blurCoordinates[0]) * 0.100590;
    sum += texture2D(inputImageTexture, blurCoordinates[1]) * 0.186265;
    sum += texture2D(inputImageTexture, blurCoordinates[2]) * 0.186265;
    sum += texture2D(inputImageTexture, blurCoordinates[3]) * 0.136940;
    sum += texture2D(inputImageTexture, blurCoordinates[4]) * 0.136940;
    sum += texture2D(inputImageTexture, blurCoordinates[5]) * 0.078710;
    sum += texture2D(inputImageTexture, blurCoordinates[6]) * 0.078710;
    sum += texture2D(inputImageTexture, blurCoordinates[7]) * 0.035367;
    sum += texture2D(inputImageTexture, blurCoordinates[8]) * 0.035367;
    sum += texture2D(inputImageTexture, blurCoordinates[9]) * 0.012422;
    sum += texture2D(inputImageTexture, blurCoordinates[10]) * 0.012422;
    gl_FragColor = sum * ratio;

}
