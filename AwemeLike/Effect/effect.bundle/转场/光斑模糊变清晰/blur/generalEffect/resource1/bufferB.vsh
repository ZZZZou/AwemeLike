attribute vec3 attPosition;
attribute vec2 attUV;

uniform float texelWidthOffset;
uniform float texelHeightOffset;

varying highp vec2 texcoordinate;
 
void main()
{
     gl_Position = vec4(attPosition, 1.);
     texcoordinate = attUV;

}
