precision highp float;

attribute vec3 attPosition;
attribute vec2 attUV;

uniform float scale;

varying highp vec2 textureCoordinate;

void main() {
    vec2 posToUse = attPosition.xy;
    posToUse *= scale;

    textureCoordinate = attUV;
    gl_Position = vec4(posToUse.xy,0.0,1.0);
}
