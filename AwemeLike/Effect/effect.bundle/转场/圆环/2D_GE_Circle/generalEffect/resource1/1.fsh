precision highp float;

varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform highp float texelWidthOffset;
uniform highp float texelHeightOffset;
uniform sampler2D circleMap;

uniform float uTime;


const float FPS = 30.9;
const float PERIOD = 8.0;
const float PI = 3.1415926;
const float PI_2 = 6.2831852;

float GetFrameID(float fTime)
{
    float ret = PERIOD * fract(uTime / PERIOD) * FPS;
    if(ret >= 110.0)
        return 91.0 / 110.0;
    return ret / 110.0;
}

float GetAlpha(float fTime)
{
    if(fTime > 0.0 && fTime < 0.5){
        float x = (fTime - 0.0) * FPS;
        float y = 3.864 * x * x - 5.682 * x - 3.182;
        return clamp(y, 0.0, 360.0);
    }

    return 0.0;

}

void main() 
{
    float pixel_x = textureCoordinate.x / texelWidthOffset;
    float pixel_y = textureCoordinate.y / texelHeightOffset;
    float center_x = 0.5 / texelWidthOffset;
    float center_y = 0.5 / texelHeightOffset;

    float rou;
    vec4 vParam = vec4((center_x - pixel_x) * (center_x - pixel_x) + (center_y - pixel_y) * (center_y - pixel_y), 0.0, 0.0, 0.0);
    vParam = sqrt(vParam);
    rou = vParam[0];

    //float foo = GetAlpha(uTime);

    float radius = 1.0 / texelHeightOffset * 0.125;

    float beta;
    if(abs(textureCoordinate.y - 0.5) < 0.0001){
        if(textureCoordinate.x <= 0.5){
            beta = PI * 0.5;
        }
        else{
            beta = PI * 1.5;
        }
    }
    else{
        if(textureCoordinate.x <= 0.5){
            vec4 vParam=vec4((0.5-textureCoordinate.x) / texelWidthOffset / (textureCoordinate.y - 0.5) * texelHeightOffset, 0.0, 0.0, 0.0);
            vParam = atan(vParam);
            beta = vParam[0];
            if(beta < 0.0){
                beta = beta + PI;
            }
        }
        else{
            vec4 vParam=vec4((0.5-textureCoordinate.x) / texelWidthOffset / (textureCoordinate.y - 0.5) * texelHeightOffset, 0.0, 0.0, 0.0);
            vParam = atan(vParam);
            beta = vParam[0];
            if(beta < 0.0){
                beta = beta + PI;
            }
            beta = beta + PI;
        }
    }

    float theta = beta;
    float alpha;

/*     if(rou <= radius)
        alpha = texture2D(circleMap, vec2(0.1, GetFrameID(uTime))).r;
    else if(rou <= radius * 2.0)
        alpha = texture2D(circleMap, vec2(0.3, GetFrameID(uTime))).r;
    else if(rou <= radius * 3.0)
        alpha = texture2D(circleMap, vec2(0.5, GetFrameID(uTime))).r;
    else if(rou <= radius * 4.0)
        alpha = texture2D(circleMap, vec2(0.7, GetFrameID(uTime))).r;
    else
        alpha = texture2D(circleMap, vec2(0.9, GetFrameID(uTime))).r; */

    float uTimeCopy = uTime / 1000.0;
    if(rou <= radius)
        alpha = GetAlpha(uTimeCopy);
    else if(rou <= radius * 2.0)
        alpha = GetAlpha(uTimeCopy - 1.0 / FPS);
    else if(rou <= radius * 3.0)
        alpha = GetAlpha(uTimeCopy - 2.0 / FPS);
    else if(rou <= radius * 4.0)
        alpha = GetAlpha(uTimeCopy - 3.0 / FPS);
    else
        alpha = GetAlpha(uTimeCopy - 4.0 / FPS);

    theta = PI + PI - alpha / 360.0 * PI_2 + beta;
    

    float texel_x = 0.5 / texelWidthOffset - rou * sin(theta);
    float texel_y = 0.5 / texelHeightOffset + rou * cos(theta);  

    vec2 coor = textureCoordinate;
    coor.x = clamp(texel_x * texelWidthOffset, 0.0, 1.0);
    coor.y = clamp(texel_y * texelHeightOffset, 0.0, 1.0);

    gl_FragColor = texture2D(inputImageTexture, coor);
}
