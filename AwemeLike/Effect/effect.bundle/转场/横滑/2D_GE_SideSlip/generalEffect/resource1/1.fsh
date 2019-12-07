precision highp float;

varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

uniform float uTime;

const float base = 200.0;
const float timeLoop = 0.6;
const float linearTime = -0.36;
const float powTimeLoop = 0.24;
const float yOffset = 0.142857;


float GetAmplitude(float fTime){
    float inputParam = timeLoop * fract(fTime / timeLoop) - timeLoop / 2.0;

    if(inputParam <= linearTime ){
        return 0.0;
    }

    if(inputParam < -powTimeLoop / 2.0 && inputParam > linearTime){
        return 25.0 / 42.0 * inputParam + 3.0 / 14.0;
    }

    if(inputParam > -powTimeLoop / 2.0 && inputParam <= 0.0){
        vec4 vParam=vec4(-inputParam, 0.0, 0.0, 0.0);
        vParam = pow(vec4(base), vParam);
        float ret = 1.0 / (1.0 + vParam[0]);
        float gap = 2.0 / 7.0;
        return ret * 2.0 + gap * inputParam / (powTimeLoop / 2.0) * 2.0;
    }

    if(inputParam > powTimeLoop / 2.0){
        return 2.0;
    }

    vec4 vParam=vec4(-inputParam, 0.0, 0.0, 0.0);
    vParam = pow(vec4(base), vParam);
    float ret = 1.0 / (1.0 + vParam[0]);

    vParam=vec4(powTimeLoop / 2.0, 0.0, 0.0, 0.0);
    vParam = pow(vec4(base), vParam);
    float gap = 1.0 / (vParam[0] + 1.0);
    return ret * 2.0 + gap * inputParam / (powTimeLoop / 2.0) * 2.0;

}

void main() {
    lowp vec4 sum = vec4(0.0);

    vec2 singleStepOffset = vec2(-1, 0);
    vec2 pos = textureCoordinate + singleStepOffset * GetAmplitude(uTime);
    if(pos.x < 0.0) {
        pos.x = 1.0 - fract(-pos.x); 
    }
    if(pos.x > 1.0) {
        pos.x = fract(pos.x);
    }
    gl_FragColor = texture2D(inputImageTexture, pos);

}
