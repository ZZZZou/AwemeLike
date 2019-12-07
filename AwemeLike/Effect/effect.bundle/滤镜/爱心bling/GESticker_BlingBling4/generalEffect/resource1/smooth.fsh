
varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform sampler2D inputPreviousImageTexture;
uniform sampler2D inputPrePreImageTexture;
uniform int ready;

void main() {
    highp vec4 cur = texture2D(inputImageTexture, textureCoordinate);
    if (ready == 0) {
        gl_FragColor =  cur;
        return;
    }
    highp vec4 previous = texture2D(inputPreviousImageTexture, textureCoordinate);
    highp vec4 prepre = texture2D(inputPrePreImageTexture, textureCoordinate);

    gl_FragColor = cur*0.34 + previous*0.33 + prepre*0.33;
}
