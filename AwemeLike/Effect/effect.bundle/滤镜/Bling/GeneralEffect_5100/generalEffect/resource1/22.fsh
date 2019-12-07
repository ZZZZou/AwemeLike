uniform sampler2D inputImageTexture;
varying highp vec2 blurCoordinates[5];

void main()
{
    lowp vec4 sum = vec4(0.0);
    sum += texture2D(inputImageTexture, blurCoordinates[0]) * 0.319224;
    sum += texture2D(inputImageTexture, blurCoordinates[1]) * 0.320561;
    sum += texture2D(inputImageTexture, blurCoordinates[2]) * 0.320561;
    sum += texture2D(inputImageTexture, blurCoordinates[3]) * 0.019827;
    sum += texture2D(inputImageTexture, blurCoordinates[4]) * 0.019827;
    gl_FragColor = sum;
}
