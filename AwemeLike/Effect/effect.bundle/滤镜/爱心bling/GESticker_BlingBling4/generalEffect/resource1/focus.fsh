precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform int width;
uniform int height;
uniform float numPattern;
uniform float uTime;

vec3 permute(vec3 x) {
    return mod(((x*34.0)+1.0)*x, vec3(289.0));
}

float snoise(vec2 v)
{
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    // First corner
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    
    // Other corners
    vec2 i1;
    //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
    //i1.y = 1.0 - i1.x;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    // x0 = x0 - 0.0 + 0.0 * C.xx ;
    // x1 = x0 - i1 + 1.0 * C.xx ;
    // x2 = x0 - 1.0 + 2.0 * C.xx ;
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    
    // Permutations
    i = mod(i, vec2(289.0)); // Avoid truncation effects in permutation
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
                     + i.x + vec3(0.0, i1.x, 1.0 ));
    
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    
    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)
    
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    
    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt( a0*a0 + h*h );
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    
    // Compute final noise value at P
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

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

void main() {
    int D2 = width / int(numPattern);
    int D = D2 / 2;
    
    int pixX = int(floor(textureCoordinate.x * float(width) - 0.5 + 0.5));
    int pixY = int(floor(textureCoordinate.y * float(height) - 0.5 + 0.5));
    bool samplePoint = isSamplePoint(pixX, pixY, D);
    vec4 ret = vec4(0.0);
    
    if (samplePoint) {
#if 1
        float dx = 1.0/float(width);
        float dy = 1.0/float(height);
        
#if 1
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(0, 0));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(0, -dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(0, dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(dx, -dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(dx, 0));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(dx, dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(-dx, -dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(-dx, 0));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(-dx, dy));
#else
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(0, -2.0*dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(0, -dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(0, 0));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(0, dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(0, 2.0*dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(dx, -2.0*dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(dx, -dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(dx, 0));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(dx, dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(dx, 2.0*dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(dx*2.0, -2.0*dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(dx*2.0, -dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(dx*2.0, 0));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(dx*2.0, dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(dx*2.0, 2.0*dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(-dx, -2.0*dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(-dx, -dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(-dx, 0));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(-dx, dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(-dx, 2.0*dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(-dx*2.0, -2.0*dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(-dx*2.0, -dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(-dx*2.0, 0));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(-dx*2.0, dy));
        ret += texture2D(inputImageTexture, textureCoordinate + vec2(-dx*2.0, 2.0*dy));
#endif
        
        float intensity = ret.r;
        
        if (intensity > 0.05) {
            //            intensity *= 10.0;
            intensity = min(intensity, 1.0);
            vec3 col = vec3(0.0);
            float timeUnit = floor(mod(uTime, 1000.0) * 0.01) + 1.0;
            
            float val = fract(snoise(vec2(sin(timeUnit) * 50.) * textureCoordinate));
//            float val = (textureCoordinate.x + textureCoordinate.y) * timeUnit;
//            val = sin(val);
            
            if (val < 0.33) {
//                col = vec3(255.0, 191.0, 219.0)*0.00392157;
                col = vec3(0.9, 0.3, 0.5);
            }
            else if (val < 0.66) {
//                col = vec3(255.0,  249.0,  229.0)*0.00392157;
                col = vec3(0.6, 0.3, 1.0);
            }
            else {
//                col = vec3(212.0,  178.0,  255.0)*0.00392157;
                col = vec3(0.9, 0.5, 0.4);
            }
            col = col * intensity;
            ret = vec4(col, 1.0);
        }
#else
        ret.rgb = vec3(1.0);
#endif
        
    }
    
    gl_FragColor = ret;
    gl_FragColor.a = 1.0;
    
}
