precision highp float;
varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

uniform highp float timeStamp;
uniform float colorDis_X;

float random (vec2 st) {
    return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

void main() {
    highp vec4 imageProgress;
    if (timeStamp == 0.0) {
        highp vec4 textureColor = texture2D(inputImageTexture,textureCoordinate);
        imageProgress = textureColor;
    }else if(timeStamp == 1.0){
        highp vec4 textureColor1 = texture2D(inputImageTexture, vec2(textureCoordinate.x,textureCoordinate.y-(1.0-0.27)));
        highp vec4 textureColor2 = texture2D(inputImageTexture, vec2(textureCoordinate.x,textureCoordinate.y+0.27));
        if (textureCoordinate.y>(1.0-0.27)) {
            imageProgress = textureColor1;
        } else {
            imageProgress = textureColor2;
        }
    }else if(timeStamp == 2.0){
        highp vec4 textureColor1 = texture2D(inputImageTexture, vec2(textureCoordinate.x,textureCoordinate.y-(1.0-0.6875)));
        highp vec4 textureColor2 = texture2D(inputImageTexture, vec2(textureCoordinate.x,textureCoordinate.y+0.6875));
        if (textureCoordinate.y>(1.0-0.6875)) {
            imageProgress = textureColor1;
        } else {
            imageProgress = textureColor2;
        }
    }else if(timeStamp == 3.0){
        highp vec4 textureColor1 = texture2D(inputImageTexture, vec2(textureCoordinate.x,textureCoordinate.y-(1.0-0.125)));
        highp vec4 textureColor2 = texture2D(inputImageTexture, vec2(textureCoordinate.x,textureCoordinate.y+0.125));
        if (textureCoordinate.y>(1.0-0.125)) {
            imageProgress = textureColor1;
        } else {
            imageProgress = textureColor2;
        }
    }else if(timeStamp == 4.0){
        highp vec4 textureColor1 = texture2D(inputImageTexture, vec2(textureCoordinate.x,textureCoordinate.y-(1.0-0.09375)));
        highp vec4 textureColor2 = texture2D(inputImageTexture, vec2(textureCoordinate.x,textureCoordinate.y+0.09375));
        if (textureCoordinate.y>(1.0-0.09375)) {
            imageProgress = textureColor1;
        } else {
            imageProgress = textureColor2;
        }
    }else if(timeStamp == 5.0){
        highp vec4 textureColor1 = texture2D(inputImageTexture, vec2(textureCoordinate.x,textureCoordinate.y-(1.0-0.0625)));
        highp vec4 textureColor2 = texture2D(inputImageTexture, vec2(textureCoordinate.x,textureCoordinate.y+0.0625));
        if (textureCoordinate.y>(1.0-0.0625)) {
            imageProgress = textureColor1;
        } else {
            imageProgress = textureColor2;
        }
    }else if(timeStamp == 6.0){
        highp vec4 textureColor1 = texture2D(inputImageTexture, vec2(textureCoordinate.x,textureCoordinate.y-(1.0-0.03125)));
        highp vec4 textureColor2 = texture2D(inputImageTexture, vec2(textureCoordinate.x,textureCoordinate.y+0.03125));
        if (textureCoordinate.y>(1.0-0.03125)) {
            imageProgress = textureColor1;
        } else {
            imageProgress = textureColor2;
        }
    }else{
        highp vec4 textureColor = texture2D(inputImageTexture,textureCoordinate);
        imageProgress = textureColor;
    }
    
    vec2 u_resolution = vec2(720.0,1280.0);
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st = st*colorDis_X;
    vec3 color = imageProgress.rgb;
    if (random(st)>0.9) {
        color = color - vec3(random(st)*0.2);
    }
    gl_FragColor = vec4(color,1.0);
}
