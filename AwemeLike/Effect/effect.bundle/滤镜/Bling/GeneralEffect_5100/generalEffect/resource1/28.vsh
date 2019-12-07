
attribute vec3 attPosition;
attribute vec2 attUV;

varying vec2 textureCoordinate;
varying vec2 textureCoordinate2;

void main() {
    gl_Position = vec4(attPosition, 1.0);
    textureCoordinate = attUV.xy;
    textureCoordinate2 = attUV.xy;
//    textureCoordinate2 = inputTextureCoordinate2.xy;
}
