precision highp float;
precision highp int;

uniform sampler2D inputImageTexture;
uniform float upper;
uniform float lower;

varying highp vec2 textureCoordinate;

void main() {
    if (textureCoordinate.y <= upper && textureCoordinate.y >= lower){
        gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
    }else{
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }   
}
