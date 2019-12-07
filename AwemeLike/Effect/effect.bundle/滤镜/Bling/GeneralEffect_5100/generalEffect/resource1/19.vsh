
attribute vec3 attPosition;
attribute vec2 attUV;

uniform float texelWidthOffset;
uniform float texelHeightOffset;

varying vec2 textureCoordinate;
varying vec2 leftTextureCoordinate;
varying vec2 rightTextureCoordinate;
varying vec2 topTextureCoordinate;
varying vec2 topLeftTextureCoordinate;
varying vec2 topRightTextureCoordinate;
varying vec2 bottomTextureCoordinate;
varying vec2 bottomLeftTextureCoordinate;
varying vec2 bottomRightTextureCoordinate;

void main() {
    gl_Position = vec4(attPosition, 1.);
    vec2 widthStep = vec2(texelWidthOffset, 0.0);
    vec2 heightStep = vec2(0.0, texelHeightOffset);
    vec2 widthHeightStep = vec2(texelWidthOffset, texelHeightOffset);
    vec2 widthNegativeHeightStep = vec2(texelWidthOffset, -texelHeightOffset);
    textureCoordinate = attUV.xy;
    leftTextureCoordinate = attUV.xy - widthStep;
    rightTextureCoordinate = attUV.xy + widthStep;
    topTextureCoordinate = attUV.xy - heightStep;
    topLeftTextureCoordinate = attUV.xy - widthHeightStep;
    topRightTextureCoordinate = attUV.xy + widthNegativeHeightStep;
    bottomTextureCoordinate = attUV.xy + heightStep;
    bottomLeftTextureCoordinate = attUV.xy - widthNegativeHeightStep;
    bottomRightTextureCoordinate = attUV.xy + widthHeightStep;
}
