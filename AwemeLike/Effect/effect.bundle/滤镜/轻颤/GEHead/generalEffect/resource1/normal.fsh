precision highp float;

varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform int m_displayWidth;
uniform int m_displayHeight;
uniform float iTime;
void main() {
    //Tweakable parameters
    float waveStrength = 0.001;
    float frequency = 80.0;
    float waveSpeed = 30.0;
    //
    
    vec2 tapPoint = vec2(0.0,0.0);
    float modifiedTime = iTime * waveSpeed;
    float aspectRatio = float(m_displayWidth)/float(m_displayHeight);
    // vec2 distVec = textureCoordinate - vec2(0.0, 1.0);
    // distVec.x *= aspectRatio;
    // float distance = length(distVec);
    float distance = textureCoordinate.y * aspectRatio;
    vec2 newTexCoord = textureCoordinate;
    
    float multiplier = (distance < 2.0) ? 0.5 : 0.0;
    float addend = (sin(frequency*distance-modifiedTime)+1.0) * waveStrength * multiplier;
    newTexCoord += addend;
    
    gl_FragColor = texture2D(inputImageTexture, newTexCoord) ;
}
