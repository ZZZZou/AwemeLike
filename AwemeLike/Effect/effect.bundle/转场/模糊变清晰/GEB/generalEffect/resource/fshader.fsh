precision highp float;

uniform sampler2D inputImageTexture;
uniform float u_scale;
varying highp vec2 textureCoordinate;


void main() {
    //distortion
    vec3 color = texture2D(inputImageTexture, textureCoordinate).rgb;
    gl_FragColor = vec4(color, 1.0);
    
}