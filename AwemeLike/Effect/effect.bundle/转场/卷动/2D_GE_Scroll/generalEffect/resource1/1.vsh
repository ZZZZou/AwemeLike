precision highp float;

attribute vec3 attPosition;
attribute vec2 attUV;

varying vec2 textureCoordinate;

uniform highp float texelWidthOffset;
uniform highp float texelHeightOffset;

vec2 GetAbsLoopValue(vec2 v){
    if(v[1] < 0.0){
        return vec2(v[0], v[1] + 1.0);
    }
    if(v[1] > 1.0){
        return vec2(v[0], v[1] - 1.0);
    }
    return vec2(v[0], v[1]);
}

void main() {



    gl_Position = vec4(attPosition,1.0);

    textureCoordinate = attUV;
    

    //textureCoordinate = GetAbsLoopValue(textureCoordinate);

/*     float yOffset = attUV.y + 10.0 * texelHeightOffset ;
    //float yOffset = attUV.y * 0.9 + 10.0 ;sin(uTime*0.2)
     if(yOffset > 1.0){
        yOffset -= 1.0 ;
     }
     if(yOffset < 0.0){
        yOffset += 1.0 ;
     }

    textureCoordinate = vec2(attUV.x, yOffset); */
}
