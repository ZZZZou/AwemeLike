
attribute vec3 attPosition;
attribute vec2 attUV;

varying vec2 textureCoordinate;
uniform float zoom;

void main() {
    gl_Position = vec4(attPosition, 1.);
    textureCoordinate = (attUV.xy - 0.5) / zoom + 0.5;
}
