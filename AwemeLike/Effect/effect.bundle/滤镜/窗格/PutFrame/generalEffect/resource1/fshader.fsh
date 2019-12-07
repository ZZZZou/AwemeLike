precision highp float;

uniform sampler2D grabInputImageTexture;
uniform sampler2D inputImageTexture;
uniform float radius;
uniform float texelHeight;
uniform float xPos;
uniform float width;
varying highp vec2 textureCoordinate;
const vec3 rgb2gray = vec3(0.299, 0.587, 0.114);

void main() {
    if (textureCoordinate.x < xPos || textureCoordinate.x > xPos + width) {
        vec2 tc = textureCoordinate;
        float blur = radius * texelHeight; 

        vec4 sum = vec4(0.0);
        
        sum += texture2D(grabInputImageTexture, vec2(tc.x, tc.y - 4.0*blur)) * 0.0162162162;
        sum += texture2D(grabInputImageTexture, vec2(tc.x, tc.y - 3.0*blur)) * 0.0540540541;
        sum += texture2D(grabInputImageTexture, vec2(tc.x, tc.y - 2.0*blur)) * 0.1216216216;
        sum += texture2D(grabInputImageTexture, vec2(tc.x, tc.y - 1.0*blur)) * 0.1945945946;
        
        sum += texture2D(grabInputImageTexture, vec2(tc.x, tc.y)) * 0.2270270270;
        
        sum += texture2D(grabInputImageTexture, vec2(tc.x, tc.y + 1.0*blur)) * 0.1945945946;
        sum += texture2D(grabInputImageTexture, vec2(tc.x, tc.y + 2.0*blur)) * 0.1216216216;
        sum += texture2D(grabInputImageTexture, vec2(tc.x, tc.y + 3.0*blur)) * 0.0540540541;
        sum += texture2D(grabInputImageTexture, vec2(tc.x, tc.y + 4.0*blur)) * 0.0162162162;

        gl_FragColor = vec4(vec3(dot(sum.rgb, rgb2gray)), sum.a);
    } else {
        gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
    }
}
