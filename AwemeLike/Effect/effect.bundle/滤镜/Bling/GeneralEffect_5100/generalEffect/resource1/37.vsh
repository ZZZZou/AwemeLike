attribute vec3 attPosition;
attribute vec2 attUV;

uniform float texelWidthOffset;
uniform float texelHeightOffset;
uniform float sharpness;
varying vec2 textureCoordinate;
varying vec2 leftTextureCoordinate;
varying vec2 rightTextureCoordinate;
varying vec2 topTextureCoordinate;
varying vec2 bottomTextureCoordinate;
varying float centerMultiplier;
varying float edgeMultiplier;

void main() {
    gl_Position = vec4(attPosition, 1.0);
    vec2 widthStep = vec2(texelWidthOffset, 0.0);
    vec2 heightStep = vec2(0.0, texelHeightOffset);
    textureCoordinate = attUV.xy;
    leftTextureCoordinate = attUV.xy - widthStep;
    rightTextureCoordinate = attUV.xy + widthStep;
    topTextureCoordinate = attUV.xy + heightStep;
    bottomTextureCoordinate = attUV.xy - heightStep;
    centerMultiplier = 1.0 + 4.0 * sharpness;
    edgeMultiplier = sharpness;
}
