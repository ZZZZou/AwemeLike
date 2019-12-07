precision highp float;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform float intensity;

varying highp vec2 textureCoordinate;

void main() {
    vec4 color1 = texture2D(inputImageTexture, textureCoordinate);
    vec4 color2 = texture2D(inputImageTexture2, textureCoordinate);
    gl_FragColor = intensity * color1 + (1.0 - intensity) * color2;
}

