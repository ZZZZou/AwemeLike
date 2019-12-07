attribute vec3 attPosition;
attribute vec2 attUV;

uniform float texelWidthOffset;
uniform float texelHeightOffset;

varying highp vec2 blurCoordinates[11];

void main()
{
    gl_Position = vec4(attPosition, 1.);
    
    vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
    blurCoordinates[0] = attUV;
    blurCoordinates[1] = attUV + singleStepOffset * 1.476580;
    blurCoordinates[2] = attUV - singleStepOffset * 1.476580;
    blurCoordinates[3] = attUV + singleStepOffset * 3.445529;
    blurCoordinates[4] = attUV - singleStepOffset * 3.445529;
    blurCoordinates[5] = attUV + singleStepOffset * 5.414899;
    blurCoordinates[6] = attUV - singleStepOffset * 5.414899;
    blurCoordinates[7] = attUV + singleStepOffset * 7.384912;
    blurCoordinates[8] = attUV - singleStepOffset * 7.384912;
    blurCoordinates[9] = attUV + singleStepOffset * 9.355775;
    blurCoordinates[10] = attUV - singleStepOffset * 9.355775;
}
