precision highp float;

attribute vec3 attPosition;
attribute vec2 attUV;
uniform float u_scale;
varying highp vec2 textureCoordinate;

void main() {
    gl_Position = vec4(attPosition * u_scale,1.0);
    textureCoordinate = attUV.xy;
}