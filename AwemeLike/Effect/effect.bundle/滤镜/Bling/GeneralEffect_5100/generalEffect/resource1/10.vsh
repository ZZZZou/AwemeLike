
attribute vec3 attPosition;
attribute vec2 attUV;

uniform float texelWidthOffset;
uniform float texelHeightOffset;
varying vec2 centerTextureCoordinate;
varying vec2 oneStepLeftTextureCoordinate;
varying vec2 twoStepsLeftTextureCoordinate;
varying vec2 threeStepsLeftTextureCoordinate;
varying vec2 fourStepsLeftTextureCoordinate;
varying vec2 oneStepRightTextureCoordinate;
varying vec2 twoStepsRightTextureCoordinate;
varying vec2 threeStepsRightTextureCoordinate;
varying vec2 fourStepsRightTextureCoordinate;
void main() {
    gl_Position = vec4(attPosition, 1.);
    vec2 firstOffset = vec2(texelWidthOffset, texelHeightOffset);
    vec2 secondOffset = vec2(2.0 * texelWidthOffset, 2.0 * texelHeightOffset);
    vec2 thirdOffset = vec2(3.0 * texelWidthOffset, 3.0 * texelHeightOffset);
    vec2 fourthOffset = vec2(4.0 * texelWidthOffset, 4.0 * texelHeightOffset);
    centerTextureCoordinate = attUV;
    oneStepLeftTextureCoordinate = attUV - firstOffset;
    twoStepsLeftTextureCoordinate = attUV - secondOffset;
    threeStepsLeftTextureCoordinate = attUV - thirdOffset;
    fourStepsLeftTextureCoordinate = attUV - fourthOffset;
    oneStepRightTextureCoordinate = attUV + firstOffset;
    twoStepsRightTextureCoordinate = attUV + secondOffset;
    threeStepsRightTextureCoordinate = attUV + thirdOffset;
    fourStepsRightTextureCoordinate = attUV + fourthOffset;
}
