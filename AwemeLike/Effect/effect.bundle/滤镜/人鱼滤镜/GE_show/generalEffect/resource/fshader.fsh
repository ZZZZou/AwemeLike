precision highp float;
precision highp int;

uniform sampler2D inputImageTexture;
uniform vec2 shift_r;
uniform vec2 shift_g;
uniform vec2 shift_b;
uniform float alpha;

varying highp vec2 textureCoordinate;

void main() {
    float color_r = texture2D(inputImageTexture, textureCoordinate + shift_r).r;
    float color_g = texture2D(inputImageTexture, textureCoordinate + shift_g).g;
    float color_b = texture2D(inputImageTexture, textureCoordinate + shift_b).b;
    vec3 color_shift = vec3(color_r, color_g, color_b);

    gl_FragColor = vec4(color_shift * alpha, alpha);
}
