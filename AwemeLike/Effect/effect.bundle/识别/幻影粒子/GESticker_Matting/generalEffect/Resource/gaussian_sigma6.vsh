attribute vec3 attPosition;
attribute vec2 attUV;

uniform float texelWidthOffset;
uniform float texelHeightOffset;
uniform float scale;
varying highp vec2 blurCoordinates[15];
varying highp vec2 texCoords;
void main()
{
    gl_Position = vec4(attPosition, 1.);
    vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
    texCoords = attUV.xy;
    blurCoordinates[0].xy = attUV.xy;
    blurCoordinates[1].xy = attUV.xy + singleStepOffset * 1.489585 * scale;
    blurCoordinates[2].xy = attUV.xy - singleStepOffset * 1.489585 * scale;
    blurCoordinates[3].xy = attUV.xy + singleStepOffset * 3.475713 * scale;
    blurCoordinates[4].xy = attUV.xy - singleStepOffset * 3.475713 * scale;
    blurCoordinates[5].xy = attUV.xy + singleStepOffset * 5.461879 * scale;
    blurCoordinates[6].xy = attUV.xy - singleStepOffset * 5.461879 * scale;
    blurCoordinates[7].xy = attUV.xy + singleStepOffset * 7.448104 * scale;
    blurCoordinates[8].xy = attUV.xy - singleStepOffset * 7.448104 * scale;
    blurCoordinates[9].xy = attUV.xy + singleStepOffset * 9.434408 * scale;
    blurCoordinates[10].xy = attUV.xy - singleStepOffset * 9.434408 * scale;
    blurCoordinates[11].xy = attUV.xy + singleStepOffset * 11.420812 * scale;
    blurCoordinates[12].xy = attUV.xy - singleStepOffset * 11.420812 * scale;
    blurCoordinates[13].xy = attUV.xy + singleStepOffset * 13.407332 * scale;
    blurCoordinates[14].xy = attUV.xy - singleStepOffset * 13.407332 * scale;
}
