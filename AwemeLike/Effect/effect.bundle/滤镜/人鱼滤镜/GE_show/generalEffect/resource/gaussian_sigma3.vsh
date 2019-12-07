attribute vec3 attPosition;
attribute vec2 attUV;

uniform float texelWidthOffset;
uniform float texelHeightOffset;
uniform float scale;

varying highp vec2 blurCoordinates[9];
 
void main()
{
     gl_Position = vec4(attPosition, 1.);
    
    vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
    
    blurCoordinates[0] = attUV.xy;
    blurCoordinates[1] = attUV.xy + singleStepOffset * 1.458430 * scale;
    blurCoordinates[2] = attUV.xy - singleStepOffset * 1.458430 * scale;
    blurCoordinates[3] = attUV.xy + singleStepOffset * 3.403985 * scale;
    blurCoordinates[4] = attUV.xy - singleStepOffset * 3.403985 * scale;
    blurCoordinates[5] = attUV.xy + singleStepOffset * 5.351806 * scale;
    blurCoordinates[6] = attUV.xy - singleStepOffset * 5.351806 * scale;
    blurCoordinates[7] = attUV.xy + singleStepOffset * 7.302940 * scale;
    blurCoordinates[8] = attUV.xy - singleStepOffset * 7.302940 * scale;
}
