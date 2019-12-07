precision highp float;
uniform sampler2D inputImageTexture;
varying highp vec2 blurCoordinates[15];
varying highp vec2 texCoords;

void main()
{
    float sum = 0.0;
    sum += texture2D(inputImageTexture, blurCoordinates[0].xy).a * 0.067540;
    sum += texture2D(inputImageTexture, blurCoordinates[1].xy).a * 0.130499;
    sum += texture2D(inputImageTexture, blurCoordinates[2].xy).a * 0.130499;
    sum += texture2D(inputImageTexture, blurCoordinates[3].xy).a * 0.113686;
    sum += texture2D(inputImageTexture, blurCoordinates[4].xy).a * 0.113686;
    sum += texture2D(inputImageTexture, blurCoordinates[5].xy).a * 0.088692;
    sum += texture2D(inputImageTexture, blurCoordinates[6].xy).a * 0.088692;
    sum += texture2D(inputImageTexture, blurCoordinates[7].xy).a * 0.061965;
    sum += texture2D(inputImageTexture, blurCoordinates[8].xy).a * 0.061965;
    sum += texture2D(inputImageTexture, blurCoordinates[9].xy).a * 0.038768;
    sum += texture2D(inputImageTexture, blurCoordinates[10].xy).a * 0.038768;
    sum += texture2D(inputImageTexture, blurCoordinates[11].xy).a * 0.021721;
    sum += texture2D(inputImageTexture, blurCoordinates[12].xy).a * 0.021721;
    sum += texture2D(inputImageTexture, blurCoordinates[13].xy).a * 0.010898;
    sum += texture2D(inputImageTexture, blurCoordinates[14].xy).a * 0.010898;

    gl_FragColor.a = sum;
    gl_FragColor.rgb = texture2D(inputImageTexture, texCoords).rgb;
}