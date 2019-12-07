precision highp float;

varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

void main() {
    vec3 col = vec3(0.0);
    if (textureCoordinate.x > 0.45 && textureCoordinate.x < 0.55) {
        if (textureCoordinate.y > 0.45 && textureCoordinate.y < 0.55) {
            col = vec3(0.9, 0.3, 0.5);
        }
    }
    
    gl_FragColor = vec4(col, 1.0);
    
}
