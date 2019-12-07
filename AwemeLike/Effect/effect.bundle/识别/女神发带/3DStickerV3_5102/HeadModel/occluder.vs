attribute   vec3 attPosition;
uniform     mat4 mvpMat;

void main()
{
    gl_Position = mvpMat * vec4(attPosition, 1.0);
}
