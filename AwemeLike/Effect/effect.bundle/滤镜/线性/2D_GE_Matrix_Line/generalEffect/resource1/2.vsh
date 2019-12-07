attribute vec2 attPosition;
attribute vec2 attUV;
varying vec2 TexCoord;

void main(void)
{
    TexCoord = attUV;
    gl_Position = vec4(attPosition.x, attPosition.y, 0.0, 1.0);
}
