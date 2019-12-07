precision highp float;

attribute vec3 attPosition;
attribute vec2 attUV;

varying vec2 textureCoordinate;
uniform mat4 uScaleMat1;
uniform float timeStampV;
void main() {
    if(timeStampV < 16.0){
        gl_Position = uScaleMat1 * vec4(attPosition,1.);
    }else{
        gl_Position = vec4(attPosition,1.);
    }
    textureCoordinate = attUV.xy;
}
