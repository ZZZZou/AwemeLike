precision highp float;

attribute vec3 attPosition;
attribute vec2 attUV;

varying vec2 textureCoordinate;
varying vec2 textureCoordinate2;

void main() {
    gl_Position = vec4(attPosition,1.);
    textureCoordinate = attUV.xy;
    textureCoordinate2 = attUV.xy * 0.5 + 0.5;
}
