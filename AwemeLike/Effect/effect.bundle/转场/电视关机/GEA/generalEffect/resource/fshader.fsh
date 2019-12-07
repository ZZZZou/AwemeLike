precision highp float;

uniform sampler2D inputImageTexture;
uniform float u_time;
uniform int u_screenWidth; 
uniform int u_screenHeight; 
uniform float u_xscale;
uniform float u_yscale;
uniform float u_freq;
uniform int u_black;
varying highp vec2 textureCoordinate;





void main() {
    //distortion
    float x = clamp(textureCoordinate.x + u_xscale * cos(textureCoordinate.y*55.2+ u_time* u_freq), 0.0, 1.0);
    float y = clamp(textureCoordinate.y + u_yscale * sin(textureCoordinate.x*1.2+ u_time* u_freq), 0.0, 1.0);
    vec3 color = texture2D(inputImageTexture, vec2(x,y)).rgb;
    if(u_black > 0){
        color = vec3(0.0);
    }
    gl_FragColor = vec4(color, 1.0);
    
}