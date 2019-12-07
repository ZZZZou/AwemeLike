precision highp float;

attribute vec3 attPosition;
attribute vec2 attUV;

uniform vec2 move;
uniform float scale;

varying highp vec2 textureCoordinate;

void main() {
    vec3 coordToUse = attPosition;
    coordToUse *= scale;
    coordToUse.xy += move;

    gl_Position = vec4(coordToUse.xy,0.0,1.0);
    textureCoordinate = attUV;
}
