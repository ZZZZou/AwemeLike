precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D loveTexture;
uniform int width;
uniform int height;
uniform float numPattern;
uniform float loveSizeRatio;
uniform float uTime;
uniform float aspectRatio;

bool isSamplePoint(int x, int y, int D)
{
    int D2 = D*2;
    int tmp = (x+y) / D2;
    if (tmp * D2 != x+y)
        return false;
    tmp = x/D;
    if (tmp * D != x)
        return false;
    return true;
}

vec2 calNearestSamplePoint(int D)
{
    int pixX = int(floor(textureCoordinate.x * float(width)));
    int pixY = int(floor(textureCoordinate.y * float(height)));
    
    
    int lowX = pixX / D;
    int lowY = pixY / D;

    lowX *= D;
    lowY *= D;
    
    vec2 ret = vec2(0.);
    
    vec2 cur = textureCoordinate * vec2(float(width), float(height));

    if (isSamplePoint(lowX, lowY, D)) {
        vec2 topLeftPix = vec2(float(lowX), float(lowY));
        vec2 buttomRightPix = vec2(float(lowX+D), float(lowY+D));
        if (length(cur - topLeftPix) < length(cur - buttomRightPix)) {
            ret =  topLeftPix;
        } else {
            ret =  buttomRightPix;
        }
    }
    else {
        vec2 topRightPix = vec2(float(lowX + D), float(lowY));
        vec2 buttomLeftPix = vec2(float(lowX), float(lowY+D));
        if (length(cur - topRightPix) < length(cur - buttomLeftPix)) {
            ret =  topRightPix;
        } else {
            ret =  buttomLeftPix;
        }
    }
    ret = (ret + vec2(0.5)) / vec2(float(width), float(height));
    return ret;
}

void main() {
    vec4 ret = vec4(0.0);
    //寻找最近的采样点
    int D2 = width / int(numPattern);
    int D = D2 / 2;

    vec2 centerUV = calNearestSamplePoint(D);

    vec3 centerCol = texture2D(inputImageTexture, centerUV).rgb;
    float v=centerCol.r*0.299+centerCol.g*0.587+centerCol.b*0.114;
    if (v > 0.05) { //因为分数原因 可能会采偏
        //最近的采样点是一个亮点
        vec2 diff = (textureCoordinate - centerUV);
        float diffX = diff.x * float(width); // -D/2 ~ D/2
        float diffY = diff.y * float(height);
        
//        float tmp = centerUV.x * 100. + centerUV.y * 50.;
//        float timeUnit = floor(mod(uTime, 1000.)*0.01);
//        tmp += timeUnit;
//        float noise = sin(tmp) * 0.15 + 1.0;
        
        float normLength = float(D) * loveSizeRatio;
        float ar = sqrt(aspectRatio / 1.7777777);
        
        vec2 loveUV = vec2(diffX / normLength / ar + 0.5, diffY / normLength * ar + 0.5);
        loveUV.y = 1.0 - loveUV.y;
        float p = texture2D(loveTexture, loveUV).a;
        if (p > 0.05) {
            ret = vec4(centerCol*p, 1.0);
        }
    }
    
    gl_FragColor = ret;
    gl_FragColor.a = 1.0;
    

}
