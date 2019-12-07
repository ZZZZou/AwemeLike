precision highp float;

varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform float move;
uniform int stay_color;
uniform int display_width;

void main() {
    vec4 shifted = texture2D(inputImageTexture, vec2(textureCoordinate.x + move / float(display_width), textureCoordinate.y));
    vec4 orig = texture2D(inputImageTexture, textureCoordinate);
    gl_FragColor = shifted;
    
    if(stay_color == 1) {
        gl_FragColor.r = orig.r;
    }else if(stay_color == 2){
        gl_FragColor.g = orig.g;
    }else{
        gl_FragColor.b = orig.b;
    }
}
