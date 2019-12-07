precision highp float;

uniform sampler2D inputImageTexture;

varying highp vec2 textureCoordinate;

void main() {
    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
    // gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
