precision highp float;
uniform sampler2D inputImageTexture;

uniform float texelWidthOffset;
uniform float texelHeightOffset;
uniform float u_radius;
varying highp vec2 textureCoordinate;
void main() {

    vec2 dir = vec2(0.5) - textureCoordinate;
    float dist = length(dir);
    dir /= dist;

    float sampleDist = 0.5 * u_radius/60.0;
    const float sampleStrenth = 5.0;

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

    float t = clamp(dist * sampleStrenth, 0.0, 1.0);
    gl_FragColor = mix(color, sum, t);
}
