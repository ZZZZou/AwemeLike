attribute vec3 attPosition;
attribute vec2 attUV;

uniform float texelWidthOffset;
uniform float texelHeightOffset;

varying highp vec2 blurCoordinates[5];
 
void main()
{
     gl_Position = vec4(attPosition, 1.);
    
    vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
    blurCoordinates[0] = attUV;
    blurCoordinates[1] = attUV + singleStepOffset * 1.407333;
    blurCoordinates[2] = attUV - singleStepOffset * 1.407333;
    blurCoordinates[3] = attUV + singleStepOffset * 3.294215;
    blurCoordinates[4] = attUV - singleStepOffset * 3.294215;
}
