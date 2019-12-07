precision highp float;
varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform float u_iwidthoffset;
uniform float u_iheightoffset;
uniform float u_texeloffset;
uniform vec2 u_moveoffset;

lowp vec3 rgb2hsv(lowp vec3 c)
{
    lowp vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    highp vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    highp vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    highp float d = q.x - min(q.w, q.y);
    highp float e = 1.0e-10;
    lowp vec3 hsv = vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
    return hsv;
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float Rand( vec2 c )
{
	return fract( sin( dot( c.xy, vec2( 12.9898, 78.233 ) ) ) * 43758.5453 );
}

void main() {
   
    // color shift
    highp float adjR = 0.12;
    highp float adjG = 0.0;
    highp float adjB = -0.12;

    highp vec2 rCoordinate = vec2(textureCoordinate.x  + adjR * u_iwidthoffset * u_texeloffset,textureCoordinate.y);//vec2(((((x1 - x2) * (adjR) + x2) * 2.0 + 1.0) * 0.5), ((((y1 - y2) * (adjR) + y2) * 2.0 + 1.0) * 0.5));
    highp vec2 gCoordinate = vec2(textureCoordinate.x  + adjG * u_iwidthoffset * u_texeloffset,textureCoordinate.y);//vec2(((((x1 - x2) * (adjG) + x2) * 2.0 + 1.0) * 0.5), ((((y1 - y2) * (adjG) + y2) * 2.0 + 1.0) * 0.5));
    highp vec2 bCoordinate = vec2(textureCoordinate.x  + adjB * u_iwidthoffset * u_texeloffset,textureCoordinate.y);//vec2(((((x1 - x2) * (adjB) + x2) * 2.0 + 1.0) * 0.5), ((((y1 - y2) * (adjB) + y2) * 2.0 + 1.0) * 0.5));

    lowp float rColor = texture2D(inputImageTexture, clamp(rCoordinate+u_moveoffset, 0.0, 1.0)).r;
    lowp float gColor = texture2D(inputImageTexture, clamp(gCoordinate+u_moveoffset, 0.0, 1.0)).g;
    lowp float bColor = texture2D(inputImageTexture, clamp(bCoordinate+u_moveoffset, 0.0, 1.0)).b;
    vec3 final  = vec3(rColor,gColor,bColor);
    //move

    gl_FragColor = vec4(vec3(rColor,gColor,bColor), 1.0);
}
