precision highp float;

uniform sampler2D inputImageTexture;
uniform float u_time;
uniform int u_screenWidth; 
uniform int u_screenHeight; 
uniform float u_xscale;
uniform float u_yscale;
uniform float u_black;
uniform float u_freq;
varying highp vec2 textureCoordinate;





void main() {
    //distortion
    float x = clamp(textureCoordinate.x + u_xscale * cos(textureCoordinate.y*55.2+ u_time* u_freq), 0.0, 1.0);
    float y = clamp(textureCoordinate.y + u_yscale * sin(textureCoordinate.x), 0.0, 1.0);
    vec3 color = texture2D(inputImageTexture, vec2(x,y)).rgb;
    //black
    float intensity = 1.0;
    if(u_black > 0.0)
    {
        float distance = clamp(abs(textureCoordinate.y-0.5)*2.0, 0.0, u_black);
        intensity = clamp(distance/u_black, 0.0, 1.0);
    }
    if(u_black >= 1.0)
    {
        intensity = 0.0;
    }
    intensity = pow(intensity, 3.0);
    color = mix(color,vec3(0.0),intensity);
    gl_FragColor = vec4(color, 1.0);
    
}