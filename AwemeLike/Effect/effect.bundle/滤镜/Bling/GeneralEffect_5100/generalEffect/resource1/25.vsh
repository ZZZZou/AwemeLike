attribute vec3 attPosition;

varying vec2 textureCoordinate;

void main() {
    gl_Position = vec4( attPosition.x, attPosition.y, 0.0, 1.0 );
    textureCoordinate = vec2( attPosition.x * 0.5 + 0.5, attPosition.y * 0.5 + 0.5 );
}
