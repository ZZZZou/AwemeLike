precision highp float;

varying vec2 textureCoordinate;

const float deltaThreshold = 0.4;

uniform float texelWidth;
uniform float texelHeight;
uniform sampler2D inputImageTexture;

void main() {
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    float textureColorR = textureColor.r;
    
    vec2 LTTextureCoordinate = textureCoordinate + 1.0 * vec2(-texelWidth, texelHeight);
    vec2 LBTextureCoordinate = textureCoordinate + 1.0 * vec2(texelWidth, texelHeight);
    vec2 RTTextureCoordinate = textureCoordinate + 1.0 * vec2(-texelWidth, -texelHeight);
    vec2 RBTextureCoordinate = textureCoordinate + 1.0 * vec2(texelWidth, -texelHeight);
    
    vec2 topTextureCoordinate = textureCoordinate + vec2(0.0, -1.0 * texelHeight);
//    vec2 topLeftTextureCoordinate = textureCoordinate + vec2(-texelWidth, -3.0 * texelHeight);
//    vec2 topRightTextureCoordinate = textureCoordinate + vec2(texelWidth, -3.0 * texelHeight);
    
    vec2 bottomTextureCoordinate = textureCoordinate + vec2(0., 1.0 * texelHeight);
//    vec2 bottomLeftTextureCoordinate = textureCoordinate + vec2(-texelWidth, 3.0 * texelHeight);
//    vec2 bottomRightTextureCoordinate = textureCoordinate + vec2(texelWidth, 3.0 * texelHeight);
    
//    vec2 leftTopTextureCoordinate = textureCoordinate + vec2(-3.0 * texelWidth, -texelHeight);
    vec2 leftTextureCoordinate = textureCoordinate + vec2(-1.0 * texelWidth, 0.);
//    vec2 leftBottomTextureCoordinate = textureCoordinate + vec2(-3.0 * texelWidth, +texelHeight);
    
//    vec2 rightTopTextureCoordinate = textureCoordinate + vec2(3.0 * texelWidth, -texelHeight);
    vec2 rightTextureCoordinate = textureCoordinate + vec2(1.0 * texelWidth, 0.);
//    vec2 rightBottomTextureCoordinate = textureCoordinate + vec2(3.0 * texelWidth, texelHeight);
    
    lowp float LTTextureColor = texture2D(inputImageTexture, LTTextureCoordinate).r;
    lowp float LBTextureColor = texture2D(inputImageTexture, LBTextureCoordinate).r;
    lowp float RTTextureColor = texture2D(inputImageTexture, RTTextureCoordinate).r;
    lowp float RBTextureColor = texture2D(inputImageTexture, RBTextureCoordinate).r;

//    lowp float topLeftTextureColor = texture2D(inputImageTexture, topLeftTextureCoordinate).r;
    lowp float topTextureColor = texture2D(inputImageTexture, topTextureCoordinate).r;
//    lowp float topRightTextureColor = texture2D(inputImageTexture, topRightTextureCoordinate).r;

    lowp float bottomTextureColor = texture2D(inputImageTexture, bottomTextureCoordinate).r;
//    lowp float bottomLeftTextureColor = texture2D(inputImageTexture, bottomLeftTextureCoordinate).r;
//    lowp float bottomRightTextureColor = texture2D(inputImageTexture, bottomRightTextureCoordinate).r;

//    lowp float leftTopTextureColor = texture2D(inputImageTexture, leftTopTextureCoordinate).r;
    lowp float leftTextureColor = texture2D(inputImageTexture, leftTextureCoordinate).r;
//    lowp float leftBottomTextureColor = texture2D(inputImageTexture, leftBottomTextureCoordinate).r;

//    lowp float rightTopTextureColor = texture2D(inputImageTexture, rightTopTextureCoordinate).r;
    lowp float rightTextureColor = texture2D(inputImageTexture, rightTextureCoordinate).r;
//    lowp float rightBottomTextureColor = texture2D(inputImageTexture, rightBottomTextureCoordinate).r;

    float delta1 = abs(LTTextureColor - textureColorR) + abs(LBTextureColor - textureColorR) + abs(RTTextureColor - textureColorR) + abs(RBTextureColor - textureColorR);
//    float delta2 = abs(topLeftTextureColor - textureColorR) + abs(topTextureColor - textureColorR) + abs(topRightTextureColor - textureColorR);
//    float delta3 = abs(bottomTextureColor - textureColorR) + abs(bottomLeftTextureColor - textureColorR) + abs(bottomRightTextureColor - textureColorR);
//    float delta4 = abs(leftTopTextureColor - textureColorR) + abs(leftTextureColor - textureColorR) + abs(leftBottomTextureColor - textureColorR);
//    float delta5 = abs(rightTopTextureColor - textureColorR) + abs(rightTextureColor - textureColorR) + abs(rightBottomTextureColor - textureColorR);
    
    float delta2 = abs(topTextureColor - textureColorR) + abs(bottomTextureColor - textureColorR) + abs(leftTextureColor - textureColorR) + abs(rightTextureColor - textureColorR);

    float delta = (delta1 + delta2) / 8.0;
    
    gl_FragColor = textureColor * (1.0 - step(deltaThreshold, delta)) + vec4(0.,1.0,0.,textureColor.a) * step(deltaThreshold, delta);
}
