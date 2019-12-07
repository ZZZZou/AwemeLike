precision highp float;
uniform sampler2D inputImageTexture;
varying highp vec2 blurCoordinates[15];

void main()
{
    lowp vec4 sum = vec4(0.0);
    sum += texture2D(inputImageTexture, blurCoordinates[0]) * 0.067540;
    sum += texture2D(inputImageTexture, blurCoordinates[1]) * 0.130499;
    sum += texture2D(inputImageTexture, blurCoordinates[2]) * 0.130499;
    sum += texture2D(inputImageTexture, blurCoordinates[3]) * 0.113686;
    sum += texture2D(inputImageTexture, blurCoordinates[4]) * 0.113686;
    sum += texture2D(inputImageTexture, blurCoordinates[5]) * 0.088692;
    sum += texture2D(inputImageTexture, blurCoordinates[6]) * 0.088692;
    sum += texture2D(inputImageTexture, blurCoordinates[7]) * 0.061965;
    sum += texture2D(inputImageTexture, blurCoordinates[8]) * 0.061965;
    sum += texture2D(inputImageTexture, blurCoordinates[9]) * 0.038768;
    sum += texture2D(inputImageTexture, blurCoordinates[10]) * 0.038768;
    sum += texture2D(inputImageTexture, blurCoordinates[11]) * 0.021721;
    sum += texture2D(inputImageTexture, blurCoordinates[12]) * 0.021721;
    sum += texture2D(inputImageTexture, blurCoordinates[13]) * 0.010898;
    sum += texture2D(inputImageTexture, blurCoordinates[14]) * 0.010898;
    gl_FragColor = sum;
}