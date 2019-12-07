precision highp float;

attribute vec3 attPosition;
attribute vec2 attUV;
varying vec2 textureCoordinate;

void main(void) {
    gl_Position = vec4(attPosition, 1.);
    textureCoordinate = attUV;
}