attribute vec3 attPosition;
attribute vec2 attUV;

uniform vec2 directionalTexelStep;
varying vec2 textureCoordinate;
varying vec2 oneStepBackTextureCoordinate;
varying vec2 twoStepsBackTextureCoordinate;
varying vec2 threeStepsBackTextureCoordinate;
varying vec2 fourStepsBackTextureCoordinate;
varying vec2 oneStepForwardTextureCoordinate;
varying vec2 twoStepsForwardTextureCoordinate;
varying vec2 threeStepsForwardTextureCoordinate;
varying vec2 fourStepsForwardTextureCoordinate;

uniform int isPortrait;

const float ratio = 0.5625;

void main() {
    gl_Position = vec4(attPosition, 1.0);

    vec2 dir = directionalTexelStep;
    if (isPortrait == 0) {
        dir = dir * vec2(ratio, 1.0/ratio);
    }

    textureCoordinate = attUV.xy;
    oneStepBackTextureCoordinate = attUV.xy - dir;;
    twoStepsBackTextureCoordinate = attUV.xy - 2.0 * dir;;
    threeStepsBackTextureCoordinate = attUV.xy - 3.0 * dir;;
    fourStepsBackTextureCoordinate = attUV.xy - 4.0 * dir;;
    oneStepForwardTextureCoordinate = attUV.xy + dir;;
    twoStepsForwardTextureCoordinate = attUV.xy + 2.0 * dir;;
    threeStepsForwardTextureCoordinate = attUV.xy + 3.0 * dir;;
    fourStepsForwardTextureCoordinate = attUV.xy + 4.0 * dir;;
}
