precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
//uniform sampler2D patternTexture;
uniform float HLVig;
uniform float threshold;
uniform float scalar;
uniform int isGray;
//uniform float numPattern;

void main() {
    
    vec3 blu = texture2D(inputImageTexture, textureCoordinate).rgb;
    vec3 col = texture2D(inputImageTexture2, textureCoordinate).rgb;
//    vec2 patternCoord = vec2(mod(textureCoordinate.x * numPattern, 1.0), mod(textureCoordinate.y * numPattern, 1.0));
//    float intensity = texture2D(patternTexture, patternCoord).r;
    
    if (isGray == 1) {
        gl_FragColor=vec4(0.0,0.0,0.0,1.0);
        float v=col.r*0.299+col.g*0.587+col.b*0.114;
        float v2=blu.r*0.299+blu.g*0.587+blu.b*0.114+HLVig;
        float th=max(threshold,v2);
        if(v>th){
            v=(v-th)/(1.0-th)*scalar;
//            gl_FragColor=vec4(vec3(v*intensity), 1.0);
            gl_FragColor=vec4(vec3(v * 1.0), 1.0);
        }
    } else {
        vec3 thc = max(vec3(threshold), blu+HLVig);
        col.r = (col.r > thc.r) ? ((col.r-thc.r) / (1.0-thc.r) * scalar) : 0.0;
        col.g = (col.g > thc.g) ? ((col.g-thc.g) / (1.0-thc.g) * scalar) : 0.0;
        col.b = (col.b > thc.b) ? ((col.b-thc.b) / (1.0-thc.b) * scalar) : 0.0;
        
#if 1
        gl_FragColor = vec4(col, 1.0);
        return;
#endif
        gl_FragColor=vec4(0.0);
        
        if (col.r != 0.0 || col.g != 0.0 || col.b != 0.0) {
            if (col.r > col.g)
            {
                if (col.r > col.b)
                {
                    gl_FragColor = vec4(0.9, 0.3, 0.5, 1.0);
                }
                else
                {
                    gl_FragColor = vec4(0.6, 0.3, 1.0, 1.0);
                }
            }
            else
            {
                if (col.g > col.b)
                {
                    gl_FragColor = vec4(0.9, 0.5, 0.4, 1.0);
                }
                else
                {
                    gl_FragColor = vec4(0.6, 0.3, 1.0, 1.0);
                }
            }
        }
//        gl_FragColor = vec4(gl_FragColor.rgb * intensity, 1.0);
        gl_FragColor = vec4(gl_FragColor.rgb * 1.0, 1.0);
    }
}
