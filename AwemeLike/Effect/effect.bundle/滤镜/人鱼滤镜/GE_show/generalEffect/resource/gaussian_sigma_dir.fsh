precision lowp float;
uniform sampler2D inputImageTexture;
uniform sampler2D originInputImageTexture;

uniform float texelWidthOffset;
uniform float texelHeightOffset;

varying highp vec2 textureCoordinate;
void main() {

    vec2 dir = vec2(1.0, 0.0) - textureCoordinate;
    dir = vec2(1.0, -0.6);
    dir = normalize(dir);

    const float sampleDist = 0.2;
    const float sampleStrenth = 1.5;

    vec4 color = texture2D(inputImageTexture, textureCoordinate);
    vec4 sum = color;
    sum += texture2D(inputImageTexture, textureCoordinate - dir * 0.08 * sampleDist);
    sum += texture2D(inputImageTexture, textureCoordinate - dir * 0.05 * sampleDist);
    sum += texture2D(inputImageTexture, textureCoordinate - dir * 0.03 * sampleDist);
    sum += texture2D(inputImageTexture, textureCoordinate - dir * 0.02 * sampleDist);
    sum += texture2D(inputImageTexture, textureCoordinate - dir * 0.01 * sampleDist);
    sum += texture2D(inputImageTexture, textureCoordinate + dir * 0.01 * sampleDist);
    sum += texture2D(inputImageTexture, textureCoordinate + dir * 0.02 * sampleDist);
    sum += texture2D(inputImageTexture, textureCoordinate + dir * 0.03 * sampleDist);
    sum += texture2D(inputImageTexture, textureCoordinate + dir * 0.05 * sampleDist);
    sum += texture2D(inputImageTexture, textureCoordinate + dir * 0.08 * sampleDist);

    sum /= 11.0;

//    gl_FragColor = sum;//
//     gl_FragColor = mix(color, sum, sum.a);
    
    vec4 bgColor = texture2D(originInputImageTexture, textureCoordinate);
    gl_FragColor = vec4(bgColor.rgb * (1.0 - sum.a) + sum.rgb * 1., 1.0);
}
