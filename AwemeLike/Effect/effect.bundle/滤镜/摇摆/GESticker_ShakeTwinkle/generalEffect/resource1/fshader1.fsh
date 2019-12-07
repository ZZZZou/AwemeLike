varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

uniform highp float frameShiftDis;
uniform highp float frameShiftDisLeft1;
uniform highp float frameShiftDisLeft2;
uniform highp float frameShiftDisRight1;
uniform highp float frameShiftDisRight2;
uniform highp float frameShiftDisRight3;
uniform highp float mixPercentLeft;
uniform highp float mixPercentRight;
void main() {

    highp vec4 textureColor1 = texture2D(inputImageTexture, vec2(textureCoordinate.x-frameShiftDis, textureCoordinate.y));
    highp vec4 textureColorLeft11 = texture2D(inputImageTexture, vec2(textureCoordinate.x-frameShiftDisLeft1-frameShiftDis, textureCoordinate.y));
    highp vec4 textureColorLeft12 = texture2D(inputImageTexture, vec2(textureCoordinate.x-frameShiftDisLeft2-frameShiftDis, textureCoordinate.y));
    highp vec4 textureMixLeft11 = mix(textureColor1,textureColorLeft11,4.0*mixPercentLeft);
    highp vec4 textureMixLeft12 = mix(textureMixLeft11,textureColorLeft12,2.0*mixPercentLeft);
    
    highp vec4 textureColorRight11 = texture2D(inputImageTexture, vec2(textureCoordinate.x-frameShiftDisRight1-frameShiftDis, textureCoordinate.y));
    highp vec4 textureColorRight12 = texture2D(inputImageTexture, vec2(textureCoordinate.x-frameShiftDisRight2-frameShiftDis, textureCoordinate.y));
    highp vec4 textureColorRight13 = texture2D(inputImageTexture, vec2(textureCoordinate.x-frameShiftDisRight3-frameShiftDis, textureCoordinate.y));
    
    highp vec4 textureMixRight11 = mix(textureColor1,textureColorRight11,4.0*mixPercentRight);
    highp vec4 textureMixRight12 = mix(textureMixRight11,textureColorRight12,3.0*mixPercentRight);
    highp vec4 textureMixRight13 = mix(textureMixRight12,textureColorRight13,2.0*mixPercentRight);
    
    highp vec4 textureColorFinal1 = mix(textureMixLeft12,textureMixRight13,0.5);

    if (frameShiftDis == 0.0) {
        gl_FragColor = textureColor1;
    }else{
        gl_FragColor = textureColorFinal1;
    }
    
}
