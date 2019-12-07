precision highp float;

varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D randomMap;

uniform float uTime;
//uniform int stripCnt;
uniform int isVertical;
uniform float period;

uniform int minWidth;
uniform int maxWidth;

float random(float s)
{
    return fract(sin(s)*758.5453123);
}

void main() {
    float randomIdx = floor(mod(uTime, 100.0)); // 0 ~ 99
    vec2 mapUV = vec2(0.0);
    
    if (isVertical == 1) {
        mapUV.y = (randomIdx + 0.5) / 100.; //取第几列随机序列
        mapUV.x = textureCoordinate.x;
    }
    else {
        mapUV.x = (randomIdx + 0.5) / 100.;
        mapUV.y = textureCoordinate.y;
    }
    
    float v = texture2D(randomMap, mapUV).r; // 0 ~ 1
    
    v = 1.3/period + 1.*v;
    
    
    float uintTime = mod(uTime, period);
    
    float s  = v*uintTime;
    vec2 coor = textureCoordinate;
    if (s < 1.0) {
        if (isVertical == 1) {
            if (textureCoordinate.y < s) {
                coor.y = coor.y + (1.0 - s);
            }
            else {
                coor.y = coor.y - s;
            }
        }
        else {
            if (textureCoordinate.x < s) {
                coor.x = coor.x + (1.0 - s);
            }
            else {
                coor.x = coor.x - s;
            }
        }
    }
    coor = clamp(coor, vec2(0.0), vec2(1.0));
    gl_FragColor = texture2D(inputImageTexture, coor);

}
