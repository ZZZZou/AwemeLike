attribute vec3 attPosition;
attribute vec2 attUV;

uniform float texelWidthOffset;
uniform float texelHeightOffset;
uniform float scale;
varying vec2 blurCoordinates[15];
void main()
{
    gl_Position = vec4(attPosition, 1.);
    
    vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
    blurCoordinates[0] = attUV;
    blurCoordinates[1] = attUV.xy + singleStepOffset * 1.489585 * scale;
    blurCoordinates[2] = attUV.xy - singleStepOffset * 1.489585 * scale;
    blurCoordinates[3] = attUV.xy + singleStepOffset * 3.475713 * scale;
    blurCoordinates[4] = attUV.xy - singleStepOffset * 3.475713 * scale;
    blurCoordinates[5] = attUV.xy + singleStepOffset * 5.461879 * scale;
    blurCoordinates[6] = attUV.xy - singleStepOffset * 5.461879 * scale;
    blurCoordinates[7] = attUV.xy + singleStepOffset * 7.448104 * scale;
    blurCoordinates[8] = attUV.xy - singleStepOffset * 7.448104 * scale;
    blurCoordinates[9] = attUV.xy + singleStepOffset * 9.434408 * scale;
    blurCoordinates[10] = attUV.xy - singleStepOffset * 9.434408 * scale;
    blurCoordinates[11] = attUV.xy + singleStepOffset * 11.420812 * scale;
    blurCoordinates[12] = attUV.xy - singleStepOffset * 11.420812 * scale;
    blurCoordinates[13] = attUV.xy + singleStepOffset * 13.407332 * scale;
    blurCoordinates[14] = attUV.xy - singleStepOffset * 13.407332 * scale;
}
