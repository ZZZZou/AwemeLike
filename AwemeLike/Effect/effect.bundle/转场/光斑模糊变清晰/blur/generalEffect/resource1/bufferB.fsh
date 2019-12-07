precision highp float;

//uniform sampler2D inputImageTexture;
uniform sampler2D originImageTexture;
varying highp vec2 texcoordinate;
uniform int m_displayWidth;
uniform int m_displayHeight;
uniform float radius;
void main()
{
    vec2 screenSize = vec2(float(m_displayWidth),float(m_displayHeight));
    mediump vec2 x_y= screenSize;
    // vec2 step=vec2(1.0)/x_y;
    vec2 curCoord=texcoordinate*x_y;
    lowp vec3 originalColor=texture2D(originImageTexture,texcoordinate).rgb;
    lowp vec3 color_output=originalColor;
    
    lowp float alpha_mask=1.0;//texture2D(inputImageTexture,texcoordinate).r;;
    //alpha_mask=clamp(pow(alpha_mask,1.0/2.0),0.0,1.0);
    
    vec3 color_pow_sum=color_output;
    vec3 weight_pow_sum=pow(color_pow_sum.rgb,vec3(4.0));//4.0
    weight_pow_sum=clamp(weight_pow_sum,vec3(0.001),vec3(1.0));
    color_pow_sum=color_pow_sum*weight_pow_sum;
    // vec3 color_pow_sum=vec3(0.0);
    // vec3 weight_pow_sum=vec3(0.0);
    
    vec2 x_range=vec2(clamp(curCoord.x-radius,0.0,screenSize.x),clamp(curCoord.x+radius,0.0,screenSize.x));
    vec2 y_range=vec2(clamp(curCoord.y-radius,0.0,screenSize.y),clamp(curCoord.y+radius,0.0,screenSize.y));
    for(float i=x_range.x;i<x_range.y;i+=1.0)
    {
        for(float j=y_range.x;j<y_range.y;j+=1.0)
        {
            vec2 bokehCoord=vec2(i,j);
            float dist=distance(bokehCoord,curCoord);
            float factor = 1.0 - step(radius,dist);
            lowp vec4 color=texture2D(originImageTexture,bokehCoord/x_y);
            vec4 color_pow=pow(color,vec4(4.0))*factor;//4.0
            weight_pow_sum+=color_pow.rgb;
            color_pow_sum+=(color.rgb*color_pow.rgb);
            
        }
    }
    // weight_pow_sum = max(vec3(0.0001),weight_pow_sum);
    
    color_output=color_pow_sum/weight_pow_sum;
    bvec3 bOutOfRange;
    bOutOfRange=greaterThanEqual(color_output,vec3(1.0));
    if(any(bOutOfRange))
    {
        float maxComponoent=max(max(color_output.x,color_output.y),color_output.z);
        color_output=color_output*vec3(1.0/maxComponoent);
    }
//    vec3 origin = texture2D(originImageTexture, texcoordinate).rgb;
//    color_output = mix(color_output, origin, color_output.r);
    gl_FragColor=vec4(color_output, 1.0);
}
