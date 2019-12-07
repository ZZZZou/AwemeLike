attribute vec3 attPosition;
attribute vec2 attUV;

uniform float texelWidthOffset;
uniform float texelHeightOffset;

varying highp vec2 blurCoordinates[7];
 
void main()
{
     gl_Position = vec4(attPosition, 1.);
    
    vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
    blurCoordinates[0] = attUV;
    
    blurCoordinates[1] = attUV.xy + singleStepOffset * 1.458429;
    blurCoordinates[2] = attUV.xy - singleStepOffset * 1.458429;
    blurCoordinates[3] = attUV.xy + singleStepOffset * 3.403985;
    blurCoordinates[4] = attUV.xy - singleStepOffset * 3.403985;
    blurCoordinates[5] = attUV.xy + singleStepOffset * 5.351806;
    blurCoordinates[6] = attUV.xy - singleStepOffset * 5.351806;
}
