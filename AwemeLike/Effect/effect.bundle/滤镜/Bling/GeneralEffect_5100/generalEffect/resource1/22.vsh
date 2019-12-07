
attribute vec3 attPosition;
attribute vec2 attUV;

uniform float texelWidthOffset;
uniform float texelHeightOffset;
varying vec2 blurCoordinates[5];

void main()
{
    gl_Position = vec4(attPosition, 1.);
    vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
    blurCoordinates[0] = attUV.xy;
    blurCoordinates[1] = attUV.xy + singleStepOffset * 1.276878;
    blurCoordinates[2] = attUV.xy - singleStepOffset * 1.276878;
    blurCoordinates[3] = attUV.xy + singleStepOffset * 3.096215;
    blurCoordinates[4] = attUV.xy - singleStepOffset * 3.096215;
}
