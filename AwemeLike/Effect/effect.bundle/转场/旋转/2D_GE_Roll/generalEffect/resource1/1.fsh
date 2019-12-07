precision highp float;

varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D randomMap;

uniform highp float texelWidthOffset;
uniform highp float texelHeightOffset;

uniform float uTime;

const float fps = 29.9;
const float period = 5.0;
const float PI = 3.1415926;
const float circleScale = 3.0;


float GetAlpha(float fTime)
{
    if(fTime > 0.0 && fTime < 0.5){
        float x = (fTime + 0.035) * fps;
        float y = 0.06265 * x * x * x - 0.7237 * x * x + 18.89 * x - 13.46;
        return clamp(y, 0.0, 360.0);
    }

/*     if(fTime > 1.5 && fTime < 3.0){
        float x = (fTime - 1.5) * fps;
        float y = 0.06265 * x * x * x - 0.7237 * x * x + 18.89 * x - 13.46;
        return clamp(y, 0.0, 359.0);
    }
 */
    //return fract(fTime) * 90.0;
    return 0.0;

}

float random(float s)
{
    return fract(sin(20.0*s)*758.5453123);
}

float getExp(float base, float x)
{
    vec2 para1 = vec2(base, 0.0), para2 = vec2(x, 0.0);

    para1 = pow(para1, para2);
    return para1[0];
}

void main() {

    float pixel_x = textureCoordinate.x / texelWidthOffset;
    float pixel_y = textureCoordinate.y / texelHeightOffset;
    float center_x = 0.5 / texelWidthOffset;
    float center_y = 0.5 / texelHeightOffset;

    float rou;
    //vec4 vParam=vec4((0.5-textureCoordinate.x) * (0.5-textureCoordinate.x) + (textureCoordinate.y - 0.5) * (textureCoordinate.y - 0.5), 0.0, 0.0, 0.0);
    vec4 vParam = vec4((center_x - pixel_x) * (center_x - pixel_x) + (center_y - pixel_y) * (center_y - pixel_y), 0.0, 0.0, 0.0);
    vParam = sqrt(vParam);
    rou = vParam[0];

    float fMaxRou = rou;
    vParam=vec4(1.0 / texelWidthOffset / texelWidthOffset + 1.0 / texelHeightOffset / texelHeightOffset, 0.0, 0.0, 0.0);
    vParam = sqrt(vParam);
    fMaxRou = vParam[0] * 0.5; 

    float randomIdx = floor(mod(uTime, 100.0)); // 0 ~ 99
    vec2 mapUV = vec2(0.0);

    mapUV.y = (randomIdx + 0.5) / 100.;
    mapUV.x = fract(rou / fMaxRou * circleScale); 

    
    float v = texture2D(randomMap, mapUV).r; // 0 ~ 1

    float u_time = uTime * 0.001;
    float alpha = PI + PI - GetAlpha(u_time) / 180.0 * PI;
    //float alpha = PI + PI - u_time / 180.0 * PI;

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
            //vec4 vParam=vec4((0.5-textureCoordinate.x) / (textureCoordinate.y - 0.5), 0.0, 0.0, 0.0);
            vec4 vParam=vec4((0.5-textureCoordinate.x) / texelWidthOffset / (textureCoordinate.y - 0.5) * texelHeightOffset, 0.0, 0.0, 0.0);
            vParam = atan(vParam);
            beta = vParam[0];
            if(beta < 0.0){
                beta = beta + PI;
            }
        }
        else{
           // vec4 vParam=vec4((0.5-textureCoordinate.x) / (textureCoordinate.y - 0.5), 0.0, 0.0, 0.0);
            vec4 vParam=vec4((0.5-textureCoordinate.x) / texelWidthOffset / (textureCoordinate.y - 0.5) * texelHeightOffset, 0.0, 0.0, 0.0);
            vParam = atan(vParam);
            beta = vParam[0];
            if(beta < 0.0){
                beta = beta + PI;
            }
            beta = beta + PI;
        }
    }

    if (alpha > PI * 0.1 && alpha < PI * 0.3){
        alpha -= (getExp(5.0, v - 1.0) - 0.2) * 0.3;
    }
    else if(alpha >= PI * 0.3 &&  alpha < PI * 1.9){
        alpha -= (getExp(5.0, v - 1.0) - 0.2) * 0.4;
    } 
    
    if (alpha <= 0.0){
        alpha = PI + PI + alpha;
    }

    float theta = alpha + beta;

    if(theta > PI + PI){
        theta = theta - PI - PI;
    }
    if(theta < 0.0){
        theta = theta + PI + PI;
    } 

    float texel_x = 0.5 / texelWidthOffset - rou * sin(theta);
    float texel_y = 0.5 / texelHeightOffset + rou * cos(theta);  

    vec2 coor = textureCoordinate;
    coor.x = clamp(texel_x * texelWidthOffset, 0.0, 1.0);
    coor.y = clamp(texel_y * texelHeightOffset, 0.0, 1.0);

    gl_FragColor = texture2D(inputImageTexture, coor);
}
