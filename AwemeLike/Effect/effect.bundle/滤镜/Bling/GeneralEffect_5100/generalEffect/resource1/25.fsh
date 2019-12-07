precision highp float;
precision highp int;

varying lowp vec2 textureCoordinate;

uniform int iterationCount;
uniform sampler2D inputImageTexture;
uniform float texelWidth;
uniform float texelHeight;
uniform float kawaseIntensity;

vec4 KawaseBlur(vec2 pixelSize, int iteration, vec2 halfSize) {
    vec2 dUV = (pixelSize * vec2( iteration, iteration )) + halfSize;
    vec2 texCoordSample;
    vec4 color;
    texCoordSample.x = textureCoordinate.x - dUV.x;
    texCoordSample.y = textureCoordinate.y + dUV.y;
    color = texture2D( inputImageTexture, texCoordSample );
    texCoordSample.x = textureCoordinate.x + dUV.x;
    texCoordSample.y = textureCoordinate.y + dUV.y;
    color += texture2D( inputImageTexture, texCoordSample );
    texCoordSample.x = textureCoordinate.x + dUV.x;
    texCoordSample.y = textureCoordinate.y - dUV.y;
    color += texture2D( inputImageTexture, texCoordSample );
    texCoordSample.x = textureCoordinate.x - dUV.x;
    texCoordSample.y = textureCoordinate.y - dUV.y;
    color += texture2D( inputImageTexture, texCoordSample );
    color.rgb *= kawaseIntensity;
    return color;
}

void main() {
    vec2 pixelSize = vec2(1.0) / vec2(texelWidth, texelHeight);
    vec2 halfSize = pixelSize / vec2(2.0);
    vec4 color = vec4(0);
    
    for(int i = 1; i <= iterationCount; i++) {
        color = KawaseBlur(pixelSize, i, halfSize);
    }
    
    gl_FragColor = color;
}
