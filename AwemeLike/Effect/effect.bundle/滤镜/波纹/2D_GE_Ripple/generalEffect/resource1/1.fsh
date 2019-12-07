precision highp float;

varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D wave_img;
uniform sampler2D offset;

uniform highp float texelWidthOffset;
uniform highp float texelHeightOffset;

const float fps = 29.9;
const float period = 5.0;
const float PI = 3.1415926;
const float rippleSpeed = 0.07;
const float whiteScale = 0.9;

float GetNewOffsetX(float x)
{
    float ret = 0.5 * pow(vec2(x, 1.0), vec2(0.75, 1.0)).x / texelWidthOffset;
    return clamp(ret, 5.0, 35.0) ;
}

float GetNewOffsetY(float x)
{
    float ret = 0.5 * pow(vec2(x, 1.0), vec2(0.75, 1.0)).x / texelHeightOffset;
    return clamp(ret, 5.0, 35.0) ;
}

// 在opencv里计算偏移量时，对水波纹亮度进行指数变换

const float wave_factor = 0.85;
int scale_flag = 0;
const float eps = 0.01;
float scale = 1.0;

void main() {

    vec2 scale_coor = textureCoordinate;
    if(texelWidthOffset / texelHeightOffset < 960. / 540. - eps){
        scale_coor.y = scale_coor.y * texelWidthOffset / texelHeightOffset / 960. * 540.; //更宽，所以短了
    }
    else if(texelWidthOffset / texelHeightOffset > 960. / 540. + eps){
        float tmp = texelWidthOffset / texelHeightOffset / 960. * 540.; //更窄，所以短了
        scale_coor.x = 1.0 / tmp * scale_coor.x;
    }

    vec3 intensity = texture2D(wave_img, scale_coor).xyz;
    vec3 norm = texture2D(offset, scale_coor).rgb;
    float offset_y = (norm.g - 0.5) * 255.0 * texelHeightOffset;
    float offset_x = (norm.r - 0.5) * 255.0 * texelWidthOffset;
    vec2 offCoor;
    offCoor.x = clamp(GetNewOffsetX(offset_x * 0.5) * texelWidthOffset + textureCoordinate.x - 0.015 * textureCoordinate.x, 0.0, 1.0);
    offCoor.y = clamp(GetNewOffsetY(offset_y * 0.5) * texelHeightOffset + textureCoordinate.y - 0.015 * textureCoordinate.y, 0.0, 1.0);

    vec3 color = texture2D(inputImageTexture, offCoor).rgb;
    color.r *= 0.80;
    color.g *= 0.88;
    color.b *= 1.12; 

    vec3 wave_intensity = texture2D(wave_img, scale_coor).xyz;
    color.r += wave_intensity.r * 168.0 / 255.0 * wave_factor;  //89
    color.g += wave_intensity.g * 250.0 / 255.0 * wave_factor; //240
    color.b += wave_intensity.b * 255.0 / 255.0 * wave_factor; //255 
    
    gl_FragColor = vec4(color, 1.0); 

} 
